# ==============================================================================
# launch.ps1 - Hardened Local Open WebUI + MCP launcher
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$DebugForeground,
    [switch]$PruneLegacyLogs = $true,
    [switch]$AllowMissingMcpCommands
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$LocalAiDir = Join-Path $RepoRoot "dev\sessions\local-ai"
$ConfigDir = Join-Path $RepoRoot "dev\config"
$RoutingPath = Join-Path $ConfigDir "open-webui-mcp-routing.json"

if (-not (Test-Path $LocalAiDir)) { New-Item -ItemType Directory -Path $LocalAiDir -Force | Out-Null }
if (-not (Test-Path $ConfigDir))  { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }

$DiagLog = Join-Path $LocalAiDir "latest-launch-diag.log"
$WebUiOutLog = Join-Path $LocalAiDir "latest-open-webui.out.log"
$WebUiErrLog = Join-Path $LocalAiDir "latest-open-webui.err.log"
$RunSummary = Join-Path $LocalAiDir "latest-run-summary.md"
$ResolvedMcp = Join-Path $LocalAiDir "latest-mcp-config.resolved.json"

function Write-Diag {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $DiagLog -Value $line
    Write-Host $Message
}

function Resolve-TokenizedString {
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [Parameter(Mandatory=$true)][string]$WorkspaceRoot,
        [switch]$ForCommandPath
    )

    $result = $Text

    if ($ForCommandPath.IsPresent) {
        $result = $result.Replace('${APPDATA}', $env:APPDATA)
        $result = $result.Replace('${USERPROFILE}', $env:USERPROFILE)
        $result = $result.Replace('${WORKSPACE_ROOT}', $WorkspaceRoot)
        return $result.Replace('/', '\')
    }

    $appDataUnix = ($env:APPDATA -replace '\\','/')
    $userProfileUnix = ($env:USERPROFILE -replace '\\','/')
    $workspaceUnix = ($WorkspaceRoot -replace '\\','/')

    $result = $result.Replace('${APPDATA}', $appDataUnix)
    $result = $result.Replace('${USERPROFILE}', $userProfileUnix)
    $result = $result.Replace('${WORKSPACE_ROOT}', $workspaceUnix)
    return $result
}

function Test-HttpEndpoint {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [int]$TimeoutSec = 4
    )
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec $TimeoutSec
        return [pscustomobject]@{ ok = $true; status = $resp.StatusCode; message = "OK" }
    } catch {
        return [pscustomobject]@{ ok = $false; status = ""; message = $_.Exception.Message }
    }
}

# reset latest-only files first
$latestFiles = @($DiagLog, $WebUiOutLog, $WebUiErrLog, $RunSummary, $ResolvedMcp)
foreach ($f in $latestFiles) {
    if (Test-Path $f) { Remove-Item -Path $f -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType File -Path $f -Force | Out-Null
}

# prune legacy logs
if ($PruneLegacyLogs.IsPresent -or $PruneLegacyLogs) {
    $legacyPatterns = @("open-webui-*.log","launch-diag-*.log","run-summary-*.md","terminal-run-*.log")
    foreach ($pattern in $legacyPatterns) {
        Get-ChildItem -Path $LocalAiDir -Filter $pattern -ErrorAction SilentlyContinue |
            Remove-Item -Force -ErrorAction SilentlyContinue
    }
    Write-Diag "Legacy timestamped logs pruned."
}

# defaults
$defaultMcp = [ordered]@{
    mcpServers = [ordered]@{
        local_filesystem = [ordered]@{
            command = '${APPDATA}/npm/mcp-server-filesystem.cmd'
            args = @('${WORKSPACE_ROOT}')
        }
        local_git = [ordered]@{
            command = '${APPDATA}/npm/mcp-server-git.cmd'
            args = @()
        }
    }
}

# optional override
$overrideMcp = $null
if (Test-Path $RoutingPath) {
    try {
        $overrideRaw = Get-Content -Raw -Path $RoutingPath
        if (-not [string]::IsNullOrWhiteSpace($overrideRaw)) {
            $overrideMcp = $overrideRaw | ConvertFrom-Json
            Write-Diag ("Loaded MCP override: " + $RoutingPath)
        }
    } catch {
        Write-Diag ("WARNING: MCP override parse failed. Using defaults. Error: " + $_.Exception.Message)
    }
} else {
    Write-Diag ("No MCP override file found at " + $RoutingPath + ". Using defaults.")
}

# merge servers
$mergedServers = [ordered]@{}
foreach ($p in $defaultMcp.mcpServers.PSObject.Properties) { $mergedServers[$p.Name] = $p.Value }
if ($overrideMcp -and $overrideMcp.mcpServers) {
    foreach ($p in $overrideMcp.mcpServers.PSObject.Properties) { $mergedServers[$p.Name] = $p.Value }
}

# resolve tokens
$resolvedMcpServers = [ordered]@{}
foreach ($serverName in $mergedServers.Keys) {
    $sv = $mergedServers[$serverName]
    $cmdRaw = ""
    $argsRaw = @()

    if ($sv.PSObject.Properties["command"]) { $cmdRaw = [string]$sv.command }
    if ($sv.PSObject.Properties["args"])    { $argsRaw = @($sv.args) }

    $cmdResolved = Resolve-TokenizedString -Text $cmdRaw -WorkspaceRoot $RepoRoot -ForCommandPath

    $argsResolved = @()
    foreach ($a in $argsRaw) {
        $argsResolved += (Resolve-TokenizedString -Text ([string]$a) -WorkspaceRoot $RepoRoot)
    }

    $resolvedMcpServers[$serverName] = [ordered]@{
        command = $cmdResolved
        args = $argsResolved
    }
}

$resolvedObject = [ordered]@{ mcpServers = $resolvedMcpServers }
($resolvedObject | ConvertTo-Json -Depth 20) | Set-Content -Path $ResolvedMcp -Encoding UTF8
Write-Diag ("Resolved MCP config written: " + $ResolvedMcp)

# validate commands
$mcpValidation = @()
$unresolvedCount = 0

foreach ($serverName in $resolvedMcpServers.Keys) {
    $cmd = [string]$resolvedMcpServers[$serverName].command
    $ok = $false
    $check = ""

    if ([string]::IsNullOrWhiteSpace($cmd)) {
        $ok = $false
        $check = "missing command"
    } elseif (Test-Path $cmd) {
        $ok = $true
        $check = "Test-Path"
    } else {
        $gc = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($gc) { $ok = $true; $check = "Get-Command" } else { $ok = $false; $check = "not found" }
    }

    if (-not $ok) { $unresolvedCount = $unresolvedCount + 1 }

    $mcpValidation += [pscustomobject]@{
        server = $serverName
        command = $cmd
        ok = $ok
        check = $check
    }

    Write-Diag ("MCP " + $serverName + " ok=" + $ok + " check=" + $check + " cmd=" + $cmd)
}

if (($unresolvedCount -gt 0) -and (-not $AllowMissingMcpCommands.IsPresent)) {
    throw ("MCP validation failed; unresolved commands: " + $unresolvedCount)
}

# runtime env
$env:ENABLE_MCP = "true"
$env:MCP_CONFIG_PATH = $ResolvedMcp
$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:ENABLE_PERSISTENT_CONFIG = "false"

Write-Diag "Environment prepared for Open WebUI launch."

# health check: ollama
$ollamaCheck = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 4
Write-Diag ("Ollama health ok=" + $ollamaCheck.ok)

# launch Open WebUI
$launchMode = ""

if ($DebugForeground.IsPresent) {
    try {
        $launchMode = "python -m open_webui serve (foreground)"
        & python -m open_webui serve
        exit 0
    } catch {
        $launchMode = "open-webui.exe serve (foreground)"
        & open-webui.exe serve
        exit 0
    }
} else {
    try {
        $launchMode = "python -m open_webui serve"
        Start-Process -FilePath "python" -ArgumentList "-m open_webui serve" -RedirectStandardOutput $WebUiOutLog -RedirectStandardError $WebUiErrLog -WindowStyle Hidden | Out-Null
    } catch {
        $launchMode = "open-webui.exe serve"
        Start-Process -FilePath "open-webui.exe" -ArgumentList "serve" -RedirectStandardOutput $WebUiOutLog -RedirectStandardError $WebUiErrLog -WindowStyle Hidden | Out-Null
    }
}

Start-Sleep -Seconds 6
$webuiCheck = Test-HttpEndpoint -Url "http://localhost:8080" -TimeoutSec 4
Write-Diag ("Open WebUI health ok=" + $webuiCheck.ok)

$finalStatus = "FAIL"
if (($unresolvedCount -eq 0) -and $webuiCheck.ok) { $finalStatus = "PASS" }

$summaryWriter = Join-Path $ScriptDir "write-summary.ps1"
if (-not (Test-Path $summaryWriter)) {
    throw ("Missing summary writer: " + $summaryWriter)
}

& $summaryWriter `
    -RunSummary $RunSummary `
    -ResolvedMcp $ResolvedMcp `
    -RepoRoot $RepoRoot `
    -LaunchMode $launchMode `
    -FinalStatus $finalStatus `
    -DiagLog $DiagLog `
    -WebUiOutLog $WebUiOutLog `
    -WebUiErrLog $WebUiErrLog `
    -UnresolvedCount $unresolvedCount `
    -McpValidation $mcpValidation `
    -OllamaCheck $ollamaCheck `
    -WebUiCheck $webuiCheck

Write-Diag ("Run summary written: " + $RunSummary)

if ($webuiCheck.ok) {
    Write-Diag "SUCCESS: Open WebUI reachable at http://localhost:8080"
    Start-Process "http://localhost:8080" | Out-Null
} else {
    Write-Diag "WARNING: Open WebUI not reachable yet. Check logs."
}