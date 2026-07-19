# ==============================================================================
# launch.ps1 - Local Open WebUI + MCP POC launcher (repo-anchored, latest-only logs)
# ==============================================================================
$ErrorActionPreference = "Stop"

param(
    [switch]$DebugForeground,
    [switch]$PruneLegacyLogs = $true,
    [switch]$AllowMissingMcpCommands = $false
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$LocalAiDir  = Join-Path $RepoRoot "dev\sessions\local-ai"
$ConfigDir   = Join-Path $RepoRoot "dev\config"
$RoutingPath = Join-Path $ConfigDir "open-webui-mcp-routing.json"

if (-not (Test-Path $LocalAiDir)) { New-Item -ItemType Directory -Force -Path $LocalAiDir | Out-Null }
if (-not (Test-Path $ConfigDir))  { New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null }

$DiagLog     = Join-Path $LocalAiDir "latest-launch-diag.log"
$WebUiOutLog = Join-Path $LocalAiDir "latest-open-webui.out.log"
$WebUiErrLog = Join-Path $LocalAiDir "latest-open-webui.err.log"
$RunSummary  = Join-Path $LocalAiDir "latest-run-summary.md"
$ResolvedMcp = Join-Path $LocalAiDir "latest-mcp-config.resolved.json"

@($DiagLog, $WebUiOutLog, $WebUiErrLog, $RunSummary, $ResolvedMcp) | ForEach-Object {
    if (Test-Path $_) { Remove-Item -Force $_ -ErrorAction SilentlyContinue }
    New-Item -ItemType File -Path $_ -Force | Out-Null
}

function Write-Diag {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $DiagLog -Value $line
    Write-Host $Message
}

if ($PruneLegacyLogs) {
    $legacyPatterns = @("open-webui-*.log","launch-diag-*.log","run-summary-*.md","terminal-run-*.log")
    foreach ($p in $legacyPatterns) {
        Get-ChildItem -Path $LocalAiDir -Filter $p -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

function Resolve-TokenizedString {
    param([string]$Text,[string]$WorkspaceRoot,[switch]$ForCommandPath)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }

    $r = $Text
    if ($ForCommandPath) {
        $r = $r -replace [regex]::Escape('${APPDATA}'), $env:APPDATA
        $r = $r -replace [regex]::Escape('${USERPROFILE}'), $env:USERPROFILE
        $r = $r -replace [regex]::Escape('${WORKSPACE_ROOT}'), $WorkspaceRoot
        return ($r -replace '/', '\')
    }

    $r = $r -replace [regex]::Escape('${APPDATA}'), ($env:APPDATA -replace '\\','/')
    $r = $r -replace [regex]::Escape('${USERPROFILE}'), ($env:USERPROFILE -replace '\\','/')
    $r = $r -replace [regex]::Escape('${WORKSPACE_ROOT}'), ($WorkspaceRoot -replace '\\','/')
    return $r
}

$defaultMcp = [ordered]@{
    mcpServers = [ordered]@{
        local_filesystem = [ordered]@{
            command = '${APPDATA}/npm/mcp-server-filesystem.cmd'
            args    = @('${WORKSPACE_ROOT}')
        }
        local_git = [ordered]@{
            command = '${APPDATA}/npm/mcp-server-git.cmd'
            args    = @()
        }
    }
}

$overrideMcp = $null
if (Test-Path $RoutingPath) {
    try {
        $overrideRaw = Get-Content -Raw -Path $RoutingPath
        if (-not [string]::IsNullOrWhiteSpace($overrideRaw)) {
            $overrideMcp = $overrideRaw | ConvertFrom-Json
            Write-Diag ("Loaded overrides from " + $RoutingPath)
        }
    } catch {
        Write-Diag ("WARNING: Failed to parse override file. Using defaults. Error: " + $_.Exception.Message)
    }
} else {
    Write-Diag ("No override file found at " + $RoutingPath + "; using defaults.")
}

$mergedServers = [ordered]@{}
foreach ($s in $defaultMcp.mcpServers.PSObject.Properties) { $mergedServers[$s.Name] = $s.Value }
if ($overrideMcp -and $overrideMcp.mcpServers) {
    foreach ($s in $overrideMcp.mcpServers.PSObject.Properties) { $mergedServers[$s.Name] = $s.Value }
}
$resolved = [pscustomobject]@{ mcpServers = [pscustomobject]$mergedServers }

foreach ($s in $resolved.mcpServers.PSObject.Properties) {
    if ($s.Value.command) {
        $s.Value.command = Resolve-TokenizedString -Text ([string]$s.Value.command) -WorkspaceRoot $RepoRoot -ForCommandPath
    }
    if ($s.Name -eq "local_filesystem" -and $s.Value.args) {
        $argsFixed = @()
        foreach ($a in $s.Value.args) {
            $argsFixed += (Resolve-TokenizedString -Text ([string]$a) -WorkspaceRoot $RepoRoot)
        }
        $s.Value.args = $argsFixed
    }
}

$resolvedJson = $resolved | ConvertTo-Json -Depth 20
Set-Content -Path $ResolvedMcp -Value $resolvedJson -Encoding UTF8
Write-Diag ("Resolved MCP config written to " + $ResolvedMcp)

$mcpValidation = @()
$unresolvedCount = 0
foreach ($s in $resolved.mcpServers.PSObject.Properties) {
    $name = $s.Name
    $cmd  = [string]$s.Value.command
    $ok   = $false
    $how  = ""

    if ([string]::IsNullOrWhiteSpace($cmd)) {
        $ok = $false; $how = "missing command"
    } elseif (Test-Path $cmd) {
        $ok = $true; $how = "Test-Path"
    } else {
        $gc = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($gc) { $ok = $true; $how = "Get-Command" } else { $ok = $false; $how = "not found" }
    }

    if (-not $ok) { $unresolvedCount++ }

    $mcpValidation += [pscustomobject]@{
        server  = $name
        command = $cmd
        ok      = $ok
        check   = $how
    }

    Write-Diag ("MCP " + $name + " ok=" + $ok + " check=" + $how + " cmd=" + $cmd)
}

if (($unresolvedCount -gt 0) -and (-not $AllowMissingMcpCommands)) {
    throw ("MCP validation failed; unresolved commands: " + $unresolvedCount)
}

$env:ENABLE_MCP = "true"
$env:MCP_CONFIG_PATH = $ResolvedMcp
$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:ENABLE_PERSISTENT_CONFIG = "false"

Write-Diag "Set ENABLE_MCP=true"
Write-Diag ("Set MCP_CONFIG_PATH=" + $ResolvedMcp)
Write-Diag ("Set OLLAMA_BASE_URL=" + $env:OLLAMA_BASE_URL)
Write-Diag "Set ENABLE_PERSISTENT_CONFIG=false"

function Test-HttpEndpoint {
    param([string]$Url,[int]$TimeoutSec = 3)
    try {
        $r = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec $TimeoutSec
        return [pscustomobject]@{ ok = $true; status = $r.StatusCode; message = "OK" }
    } catch {
        return [pscustomobject]@{ ok = $false; status = ""; message = $_.Exception.Message }
    }
}

$ollamaCheck = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 3
Write-Diag ("Ollama check: ok=" + $ollamaCheck.ok + " status=" + $ollamaCheck.status + " msg=" + $ollamaCheck.message)

$launchMode = ""
if ($DebugForeground) {
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

Start-Sleep -Seconds 5
$webuiCheck = Test-HttpEndpoint -Url "http://localhost:8080" -TimeoutSec 3
Write-Diag ("Open WebUI check: ok=" + $webuiCheck.ok + " status=" + $webuiCheck.status + " msg=" + $webuiCheck.message)

$finalStatus = "FAIL"
if (($unresolvedCount -eq 0) -and $webuiCheck.ok) { $finalStatus = "PASS" }

$summaryWriter = Join-Path $PSScriptRoot "write-summary.ps1"
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

Write-Diag ("Run summary written to " + $RunSummary)

if ($webuiCheck.ok) {
    Write-Diag "SUCCESS: Open WebUI is reachable at http://localhost:8080"
    Start-Process "http://localhost:8080" | Out-Null
} else {
    Write-Diag "WARNING: Open WebUI not reachable yet. Check logs."
}