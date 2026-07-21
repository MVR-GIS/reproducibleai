# ==============================================================================
# launch.ps1 - Bare-metal Continue + Ollama + MCP launcher/validator
# Target stack: Positron + Continue + Ollama + MCP server array
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$PruneLegacyLogs = $true,
    [switch]$AllowMissingMcpCommands,
    [string]$TargetModel = "qwen2.5-coder:32b-instruct",
    [switch]$SkipModelCheck,
    [switch]$AutoPullModel
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path

$LocalAiDir = Join-Path $RepoRoot "dev\sessions\local-ai"
$ConfigDir = Join-Path $RepoRoot "dev\config"

$ContinueRoutingPath = Join-Path $ConfigDir "continue-mcp-routing.json"
$LegacyRoutingPath = Join-Path $ConfigDir "open-webui-mcp-routing.json"

if (-not (Test-Path $LocalAiDir)) { New-Item -ItemType Directory -Path $LocalAiDir -Force | Out-Null }
if (-not (Test-Path $ConfigDir))  { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }

$DiagLog = Join-Path $LocalAiDir "latest-launch-diag.log"
$RunSummary = Join-Path $LocalAiDir "latest-run-summary.md"
$ResolvedMcp = Join-Path $LocalAiDir "latest-continue-mcp.resolved.json"
$RepoResolvedMcp = Join-Path $ConfigDir "continue-mcp.servers.resolved.json"

function Write-Diag {
    param([string]$Message)
    try {
        $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
        Add-Content -Path $DiagLog -Value $line
    } catch {}
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

function Test-McpCommandExecution {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$CommandPath
    )

    if (-not (Test-Path $CommandPath)) {
        return [pscustomobject]@{ server = $Name; ok = $false; message = "command path not found" }
    }

    try {
        $arg = '/c ""' + $CommandPath + '" --help"'
        $p = Start-Process -FilePath "cmd.exe" -ArgumentList $arg -WindowStyle Hidden -PassThru -ErrorAction Stop
        Start-Sleep -Milliseconds 900

        if (-not $p.HasExited) {
            try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
            return [pscustomobject]@{ server = $Name; ok = $true; message = "started (terminated after smoke interval)" }
        }

        return [pscustomobject]@{ server = $Name; ok = $true; message = ("exited code " + $p.ExitCode) }
    } catch {
        return [pscustomobject]@{ server = $Name; ok = $false; message = $_.Exception.Message }
    }
}

function Ensure-OllamaRunning {
    $health = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 3
    if ($health.ok) { return $health }

    Write-Diag "Ollama endpoint not reachable. Attempting to start 'ollama serve'..."
    try {
        Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -ErrorAction Stop | Out-Null
        Start-Sleep -Seconds 3
    } catch {
        Write-Diag ("WARNING: Failed to launch ollama serve: " + $_.Exception.Message)
    }

    return (Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 4)
}

function Test-ModelPresent {
    param([Parameter(Mandatory=$true)][string]$ModelName)
    try {
        $list = & ollama list 2>&1
        $joined = ($list -join "`n")
        return ($joined -match [regex]::Escape($ModelName))
    } catch {
        return $false
    }
}

# reset latest-only files
$latestFiles = @($DiagLog, $RunSummary, $ResolvedMcp, $RepoResolvedMcp)
foreach ($f in $latestFiles) {
    try {
        if (Test-Path $f) { Remove-Item -Path $f -Force -ErrorAction SilentlyContinue }
        New-Item -ItemType File -Path $f -Force | Out-Null
    } catch {
        Write-Host ("[WARN] Failed to reset artifact: " + $f)
    }
}

if ($PruneLegacyLogs.IsPresent -or $PruneLegacyLogs) {
    try {
        $legacyPatterns = @("open-webui-*.log","latest-open-webui*.log","launch-diag-*.log","run-summary-*.md","terminal-run-*.log")
        foreach ($pattern in $legacyPatterns) {
            Get-ChildItem -Path $LocalAiDir -Filter $pattern -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
        Write-Diag "Legacy timestamped/Open-WebUI logs pruned."
    } catch {
        Write-Diag ("WARNING: Legacy log pruning failed (non-blocking): " + $_.Exception.Message)
    }
}

# default MCP
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

# load override (continue first, legacy fallback)
$overrideMcp = $null
$overrideSource = ""

if (Test-Path $ContinueRoutingPath) {
    try {
        $raw = Get-Content -Raw -Path $ContinueRoutingPath
        if (-not [string]::IsNullOrWhiteSpace($raw)) {
            $overrideMcp = $raw | ConvertFrom-Json
            $overrideSource = $ContinueRoutingPath
        }
    } catch {
        Write-Diag ("WARNING: Continue override parse failed; ignoring. Error: " + $_.Exception.Message)
    }
}

if (($null -eq $overrideMcp) -and (Test-Path $LegacyRoutingPath)) {
    try {
        $rawLegacy = Get-Content -Raw -Path $LegacyRoutingPath
        if (-not [string]::IsNullOrWhiteSpace($rawLegacy)) {
            $overrideMcp = $rawLegacy | ConvertFrom-Json
            $overrideSource = $LegacyRoutingPath
        }
    } catch {
        Write-Diag ("WARNING: Legacy override parse failed; ignoring. Error: " + $_.Exception.Message)
    }
}

if ($overrideSource -ne "") {
    Write-Diag ("Loaded MCP override: " + $overrideSource)
} else {
    Write-Diag "No MCP override found. Using defaults."
}

# merge
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

# write resolved outputs
($resolvedObject | ConvertTo-Json -Depth 20) | Set-Content -Path $ResolvedMcp -Encoding UTF8
($resolvedObject | ConvertTo-Json -Depth 20) | Set-Content -Path $RepoResolvedMcp -Encoding UTF8
Write-Diag ("Resolved MCP config written: " + $ResolvedMcp)
Write-Diag ("Repo MCP handoff written: " + $RepoResolvedMcp)

# MCP validation
$mcpValidation = @()
$unresolvedCount = 0
foreach ($serverName in $resolvedMcpServers.Keys) {
    $cmd = [string]$resolvedMcpServers[$serverName].command
    $ok = $false
    $check = ""

    if ([string]::IsNullOrWhiteSpace($cmd)) {
        $ok = $false; $check = "missing command"
    } elseif (Test-Path $cmd) {
        $ok = $true; $check = "Test-Path"
    } else {
        $gc = Get-Command $cmd -ErrorAction SilentlyContinue
        if ($gc) { $ok = $true; $check = "Get-Command" } else { $ok = $false; $check = "not found" }
    }

    if (-not $ok) { $unresolvedCount++ }

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

# MCP smoke
$mcpSmokeResults = @()
foreach ($serverName in $resolvedMcpServers.Keys) {
    $smoke = Test-McpCommandExecution -Name $serverName -CommandPath ([string]$resolvedMcpServers[$serverName].command)
    $mcpSmokeResults += $smoke
    Write-Diag ("MCP smoke " + $smoke.server + " ok=" + $smoke.ok + " msg=" + $smoke.message)
}

# Ollama
$ollamaCheck = Ensure-OllamaRunning
Write-Diag ("Ollama health ok=" + $ollamaCheck.ok + " status=" + $ollamaCheck.status + " msg=" + $ollamaCheck.message)

$modelCheckOk = $true
if (-not $SkipModelCheck.IsPresent) {
    $modelCheckOk = Test-ModelPresent -ModelName $TargetModel
    if ($modelCheckOk) {
        Write-Diag ("Model present: " + $TargetModel)
    } else {
        Write-Diag ("WARNING: Model not present: " + $TargetModel)
        if ($AutoPullModel.IsPresent) {
            Write-Diag ("AutoPullModel enabled. Pulling: " + $TargetModel)
            try {
                & ollama pull $TargetModel 2>&1 | ForEach-Object { Write-Diag $_ }
                $modelCheckOk = Test-ModelPresent -ModelName $TargetModel
            } catch {
                Write-Diag ("WARNING: Model pull failed: " + $_.Exception.Message)
            }
        } else {
            Write-Diag ("Pull suggestion: ollama pull " + $TargetModel)
        }
    }
}

# final status
$mcpSmokeAllOk = $true
foreach ($sm in $mcpSmokeResults) {
    if (-not $sm.ok) { $mcpSmokeAllOk = $false }
}

$finalStatus = "FAIL"
if (($unresolvedCount -eq 0) -and $mcpSmokeAllOk -and $ollamaCheck.ok -and $modelCheckOk) {
    $finalStatus = "PASS"
}

# summary
$summaryLines = @()
$summaryLines += "# Local AI Launch Summary"
$summaryLines += ""
$summaryLines += "- Timestamp: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
$summaryLines += "- Repo root: $RepoRoot"
$summaryLines += "- Final status: **$finalStatus**"
$summaryLines += "- Target model: $TargetModel"
$summaryLines += "- Ollama reachable: $($ollamaCheck.ok)"
$summaryLines += "- Model check passed: $modelCheckOk"
$summaryLines += "- Unresolved MCP commands: $unresolvedCount"
$summaryLines += ""
$summaryLines += "## MCP validation"
foreach ($v in $mcpValidation) {
    $summaryLines += "- $($v.server): ok=$($v.ok), check=$($v.check), cmd=`"$($v.command)`""
}
$summaryLines += ""
$summaryLines += "## MCP smoke"
foreach ($s in $mcpSmokeResults) {
    $summaryLines += "- $($s.server): ok=$($s.ok), msg=$($s.message)"
}
$summaryLines += ""
$summaryLines += "## Artifacts"
$summaryLines += "- Diag log: $DiagLog"
$summaryLines += "- Resolved MCP (session): $ResolvedMcp"
$summaryLines += "- Resolved MCP (repo handoff): $RepoResolvedMcp"

$summaryLines | Set-Content -Path $RunSummary -Encoding UTF8
Write-Diag ("Run summary written: " + $RunSummary)
Write-Diag ("FINAL STATUS: " + $finalStatus)

if ($finalStatus -eq "PASS") {
    Write-Host "[LAUNCH] PASS - Continue/Ollama/MCP POC validation succeeded." -ForegroundColor Green
} else {
    Write-Host "[LAUNCH] FAIL - Review latest-launch-diag.log and latest-run-summary.md." -ForegroundColor Yellow
}

exit 0