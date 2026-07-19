# ==============================================================================
# launch.ps1 - Hardened Local Open WebUI + MCP launcher (non-blocking logging)
# Goal: keep MCP proof moving even if WebUI/import/log-summary fail.
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$DebugForeground,
    [switch]$PruneLegacyLogs = $true,
    [switch]$AllowMissingMcpCommands,
    [switch]$McpOnly,
    [string]$OpenWebUiPython = $env:OPENWEBUI_PYTHON,
    [switch]$AutoInstallOpenWebUi
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

function Resolve-PythonExecutable {
    param([string]$Preferred)

    if (-not [string]::IsNullOrWhiteSpace($Preferred)) {
        try {
            if (Test-Path $Preferred) { return (Resolve-Path $Preferred).Path }
            $prefCmd = Get-Command $Preferred -ErrorAction SilentlyContinue
            if ($prefCmd) { return $prefCmd.Source }
        } catch {}
    }

    $py = Get-Command python -ErrorAction SilentlyContinue
    if ($py) { return $py.Source }

    $pyLauncher = Get-Command py -ErrorAction SilentlyContinue
    if ($pyLauncher) { return "py" }

    return $null
}

function Assert-WebUiPythonConfigured {
    param(
        [switch]$IsMcpOnly,
        [string]$ConfiguredPython
    )
    if ($IsMcpOnly.IsPresent) { return }
    if ([string]::IsNullOrWhiteSpace($ConfiguredPython)) {
        throw "Non-McpOnly mode requires -OpenWebUiPython (or OPENWEBUI_PYTHON) for deterministic launch."
    }
}

function Invoke-Python {
    param(
        [Parameter(Mandatory=$true)][string]$PythonExe,
        [Parameter(Mandatory=$true)][string[]]$Args
    )
    & $PythonExe @Args 2>&1
}

function Test-PythonVersion {
    param([Parameter(Mandatory=$true)][string]$PythonExe)
    try {
        $v = Invoke-Python -PythonExe $PythonExe -Args @("--version")
        return [pscustomobject]@{ ok = $true; message = ($v -join " ") }
    } catch {
        return [pscustomobject]@{ ok = $false; message = $_.Exception.Message }
    }
}

function Get-PythonExecutableFromInterpreter {
    param([Parameter(Mandatory=$true)][string]$PythonExe)
    try {
        $out = Invoke-Python -PythonExe $PythonExe -Args @("-c", "import sys; print(sys.executable)")
        return ($out -join " ").Trim()
    } catch {
        return ""
    }
}

function Test-OpenWebUiInstalled {
    param([Parameter(Mandatory=$true)][string]$PythonExe)
    try {
        $out = Invoke-Python -PythonExe $PythonExe -Args @("-m","pip","show","open-webui")
        return [pscustomobject]@{ ok = $true; message = ($out -join " ") }
    } catch {
        return [pscustomobject]@{ ok = $false; message = $_.Exception.Message }
    }
}

function Install-OpenWebUi {
    param([Parameter(Mandatory=$true)][string]$PythonExe)
    try {
        $upgradePip = Invoke-Python -PythonExe $PythonExe -Args @("-m","pip","install","--upgrade","pip")
        $installPkg = Invoke-Python -PythonExe $PythonExe -Args @("-m","pip","install","open-webui")
        return [pscustomobject]@{
            ok = $true
            message = "pip upgrade/install completed"
            detail = (($upgradePip + $installPkg) -join " ")
        }
    } catch {
        return [pscustomobject]@{ ok = $false; message = $_.Exception.Message; detail = "" }
    }
}

function Test-OpenWebUiImport {
    param([Parameter(Mandatory=$true)][string]$PythonExe)
    try {
        $output = Invoke-Python -PythonExe $PythonExe -Args @("-c", "import open_webui; print('open_webui import OK')")
        return [pscustomobject]@{ ok = $true; message = ($output -join " ") }
    } catch {
        return [pscustomobject]@{ ok = $false; message = $_.Exception.Message }
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

# reset latest-only files first (non-blocking)
$latestFiles = @($DiagLog, $WebUiOutLog, $WebUiErrLog, $RunSummary, $ResolvedMcp)
foreach ($f in $latestFiles) {
    try {
        if (Test-Path $f) { Remove-Item -Path $f -Force -ErrorAction SilentlyContinue }
        New-Item -ItemType File -Path $f -Force | Out-Null
    } catch {
        Write-Host ("[WARN] Failed to reset log artifact: " + $f)
    }
}

# prune legacy logs (non-blocking)
if ($PruneLegacyLogs.IsPresent -or $PruneLegacyLogs) {
    try {
        $legacyPatterns = @("open-webui-*.log","launch-diag-*.log","run-summary-*.md","terminal-run-*.log")
        foreach ($pattern in $legacyPatterns) {
            Get-ChildItem -Path $LocalAiDir -Filter $pattern -ErrorAction SilentlyContinue |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
        Write-Diag "Legacy timestamped logs pruned."
    } catch {
        Write-Diag ("WARNING: Legacy log pruning failed (non-blocking): " + $_.Exception.Message)
    }
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

# write resolved MCP config (non-blocking)
try {
    ($resolvedObject | ConvertTo-Json -Depth 20) | Set-Content -Path $ResolvedMcp -Encoding UTF8
    Write-Diag ("Resolved MCP config written: " + $ResolvedMcp)
} catch {
    Write-Diag ("WARNING: Failed writing resolved MCP config (non-blocking): " + $_.Exception.Message)
}

# validate commands (gate)
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

# MCP smoke (non-blocking but tracked for status)
$mcpSmokeResults = @()
foreach ($serverName in $resolvedMcpServers.Keys) {
    $smoke = Test-McpCommandExecution -Name $serverName -CommandPath ([string]$resolvedMcpServers[$serverName].command)
    $mcpSmokeResults += $smoke
    Write-Diag ("MCP smoke " + $smoke.server + " ok=" + $smoke.ok + " msg=" + $smoke.message)
}

# runtime env
$env:ENABLE_MCP = "true"
$env:MCP_CONFIG_PATH = $ResolvedMcp
$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:ENABLE_PERSISTENT_CONFIG = "false"
Write-Diag "Environment prepared for Open WebUI launch."

# Ollama health (non-blocking)
$ollamaCheck = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 4
Write-Diag ("Ollama health ok=" + $ollamaCheck.ok)

# WebUI track (optional)
$launchMode = "not-started"
$webuiCheck = [pscustomobject]@{ ok = $false; status = ""; message = "launch not attempted" }
$pythonExe = $null
$openWebUiImport = [pscustomobject]@{ ok = $false; message = "not checked" }

if ($McpOnly.IsPresent) {
    Write-Diag "MCP-only mode enabled. Skipping Open WebUI launch."
} else {
    Assert-WebUiPythonConfigured -IsMcpOnly:$McpOnly.IsPresent -ConfiguredPython $OpenWebUiPython
    $pythonExe = Resolve-PythonExecutable -Preferred $OpenWebUiPython

    if ($null -eq $pythonExe) {
        throw ("Configured Open WebUI python could not be resolved: " + $OpenWebUiPython)
    } else {
        Write-Diag ("Python executable selected: " + $pythonExe)

        $pyVer = Test-PythonVersion -PythonExe $pythonExe
        Write-Diag ("Python version check ok=" + $pyVer.ok + " msg=" + $pyVer.message)

        $actualExe = Get-PythonExecutableFromInterpreter -PythonExe $pythonExe
        if (-not [string]::IsNullOrWhiteSpace($actualExe)) {
            Write-Diag ("Python runtime sys.executable=" + $actualExe)
        }

        $pkgCheck = Test-OpenWebUiInstalled -PythonExe $pythonExe
        Write-Diag ("open-webui package installed=" + $pkgCheck.ok)

        if ((-not $pkgCheck.ok) -and $AutoInstallOpenWebUi.IsPresent) {
            Write-Diag "Auto-install enabled. Attempting to install open-webui..."
            $installResult = Install-OpenWebUi -PythonExe $pythonExe
            Write-Diag ("open-webui install ok=" + $installResult.ok + " msg=" + $installResult.message)
        } elseif (-not $pkgCheck.ok) {
            Write-Diag ("Install hint: `"" + $pythonExe + "`" -m pip install open-webui")
        }

        $openWebUiImport = Test-OpenWebUiImport -PythonExe $pythonExe
        Write-Diag ("open_webui import ok=" + $openWebUiImport.ok + " msg=" + $openWebUiImport.message)
    }

    if ($openWebUiImport.ok) {
        if ($DebugForeground.IsPresent) {
            try {
                $launchMode = $pythonExe + " -m open_webui serve (foreground)"
                & $pythonExe -m open_webui serve
                exit 0
            } catch {
                $launchMode = "open-webui.exe serve (foreground fallback)"
                & open-webui.exe serve
                exit 0
            }
        } else {
            try {
                $launchMode = $pythonExe + " -m open_webui serve"
                Start-Process -FilePath $pythonExe -ArgumentList "-m open_webui serve" -RedirectStandardOutput $WebUiOutLog -RedirectStandardError $WebUiErrLog -WindowStyle Hidden | Out-Null
            } catch {
                $launchMode = "open-webui.exe serve (fallback)"
                Start-Process -FilePath "open-webui.exe" -ArgumentList "serve" -RedirectStandardOutput $WebUiOutLog -RedirectStandardError $WebUiErrLog -WindowStyle Hidden | Out-Null
            }
        }

        Start-Sleep -Seconds 6
        $webuiCheck = Test-HttpEndpoint -Url "http://localhost:8080" -TimeoutSec 4
        Write-Diag ("Open WebUI health ok=" + $webuiCheck.ok)
    } else {
        Write-Diag "WARNING: Skipping Open WebUI launch due to failed import gate."
        Write-Diag ("Deterministic fix command: `"" + $pythonExe + "`" -m pip install open-webui")
    }
}

# Final status:
# PASS if MCP validation passed and all MCP smokes ok.
$mcpSmokeAllOk = $true
foreach ($sm in $mcpSmokeResults) {
    if (-not $sm.ok) { $mcpSmokeAllOk = $false }
}

$finalStatus = "FAIL"
if (($unresolvedCount -eq 0) -and $mcpSmokeAllOk) {
    $finalStatus = "PASS"
}

# summary/log artifacts are non-blocking
$summaryWriter = Join-Path $ScriptDir "write-summary.ps1"
try {
    if (Test-Path $summaryWriter) {
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
    } else {
        Write-Diag ("WARNING: Summary writer missing: " + $summaryWriter + " (non-blocking)")
    }
} catch {
    Write-Diag ("WARNING: Summary generation failed (non-blocking): " + $_.Exception.Message)
}

if ($webuiCheck.ok) {
    Write-Diag "SUCCESS: Open WebUI reachable at http://localhost:8080"
    Start-Process "http://localhost:8080" | Out-Null
} else {
    Write-Diag "INFO: WebUI not reachable or not launched; MCP POC can still be valid."
}

Write-Diag ("FINAL STATUS: " + $finalStatus)
exit 0