# ==============================================================================
# launch.ps1 - Local Open WebUI + MCP POC launcher (repo-anchored, latest-only logs)
# ==============================================================================
$ErrorActionPreference = "Stop"

param(
    [switch]$DebugForeground,
    [switch]$PruneLegacyLogs = $true
)

# ------------------------------------------------------------------------------
# Paths (anchor to script location, not CWD)
# ------------------------------------------------------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Resolve-Path (Join-Path $ScriptDir "..\..") | Select-Object -ExpandProperty Path

$LocalAiDir   = Join-Path $RepoRoot "dev\sessions\local-ai"
$ConfigDir    = Join-Path $RepoRoot "dev\config"
$RoutingPath  = Join-Path $ConfigDir "open-webui-mcp-routing.json"

if (-not (Test-Path $LocalAiDir)) { New-Item -ItemType Directory -Force -Path $LocalAiDir | Out-Null }
if (-not (Test-Path $ConfigDir))  { New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null }

$DiagLog      = Join-Path $LocalAiDir "latest-launch-diag.log"
$WebUiLog     = Join-Path $LocalAiDir "latest-open-webui.log"
$RunSummary   = Join-Path $LocalAiDir "latest-run-summary.md"
$ResolvedMcp  = Join-Path $LocalAiDir "latest-mcp-config.resolved.json"

# reset latest-only files
@($DiagLog, $WebUiLog, $RunSummary, $ResolvedMcp) | ForEach-Object {
    if (Test-Path $_) { Remove-Item -Force $_ }
    New-Item -ItemType File -Path $_ -Force | Out-Null
}

function Write-Diag {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $DiagLog -Value $line
    Write-Host $Message
}

# ------------------------------------------------------------------------------
# Optional legacy log pruning
# ------------------------------------------------------------------------------
if ($PruneLegacyLogs) {
    Write-Diag "Pruning legacy timestamped logs in $LocalAiDir"
    $legacyPatterns = @(
        "open-webui-*.log",
        "launch-diag-*.log",
        "run-summary-*.md",
        "terminal-run-*.log"
    )
    foreach ($p in $legacyPatterns) {
        Get-ChildItem -Path $LocalAiDir -Filter $p -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}

# ------------------------------------------------------------------------------
# Token resolution helpers
# ------------------------------------------------------------------------------
function Resolve-TokenizedString {
    param([string]$Text, [string]$WorkspaceRoot)

    if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }

    $r = $Text
    $r = $r -replace [regex]::Escape('${APPDATA}'),     ($env:APPDATA -replace '\\','/')
    $r = $r -replace [regex]::Escape('${USERPROFILE}'), ($env:USERPROFILE -replace '\\','/')
    $r = $r -replace [regex]::Escape('${WORKSPACE_ROOT}'), ($WorkspaceRoot -replace '\\','/')
    return $r
}

function Resolve-McpObject {
    param($Obj, [string]$WorkspaceRoot)

    if ($null -eq $Obj) { return $null }

    if ($Obj -is [string]) {
        return Resolve-TokenizedString -Text $Obj -WorkspaceRoot $WorkspaceRoot
    }

    if ($Obj -is [System.Collections.IEnumerable] -and -not ($Obj -is [string])) {
        $out = @()
        foreach ($i in $Obj) { $out += (Resolve-McpObject -Obj $i -WorkspaceRoot $WorkspaceRoot) }
        return $out
    }

    if ($Obj.PSObject -and $Obj.PSObject.Properties) {
        $h = [ordered]@{}
        foreach ($p in $Obj.PSObject.Properties) {
            $h[$p.Name] = Resolve-McpObject -Obj $p.Value -WorkspaceRoot $WorkspaceRoot
        }
        return [pscustomobject]$h
    }

    return $Obj
}

# ------------------------------------------------------------------------------
# MCP defaults + optional overrides
# ------------------------------------------------------------------------------
Write-Diag "Building MCP server config from defaults + optional overrides"

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
            Write-Diag "Loaded overrides from $RoutingPath"
        }
    } catch {
        Write-Diag "WARNING: Failed to parse $RoutingPath. Using defaults only. Error: $($_.Exception.Message)"
    }
} else {
    Write-Diag "No override file found at $RoutingPath; using defaults only"
}

# merge by server name (override replaces same-name defaults)
$mergedServers = [ordered]@{}
foreach ($s in $defaultMcp.mcpServers.PSObject.Properties) {
    $mergedServers[$s.Name] = $s.Value
}
if ($overrideMcp -and $overrideMcp.mcpServers) {
    foreach ($s in $overrideMcp.mcpServers.PSObject.Properties) {
        $mergedServers[$s.Name] = $s.Value
    }
}

$merged = [pscustomobject]@{ mcpServers = [pscustomobject]$mergedServers }
$resolved = Resolve-McpObject -Obj $merged -WorkspaceRoot $RepoRoot
$resolvedJson = $resolved | ConvertTo-Json -Depth 20
Set-Content -Path $ResolvedMcp -Value $resolvedJson -Encoding UTF8
Write-Diag "Resolved MCP config written to $ResolvedMcp"

# ------------------------------------------------------------------------------
# Validate MCP command resolvability
# ------------------------------------------------------------------------------
$mcpValidation = @()
foreach ($s in $resolved.mcpServers.PSObject.Properties) {
    $name = $s.Name
    $cmd  = $s.Value.command
    $ok   = $false
    $how  = ""

    if ([string]::IsNullOrWhiteSpace($cmd)) {
        $ok = $false
        $how = "missing command"
    } else {
        if ($cmd -match '[/\\]' -or $cmd -match '^[A-Za-z]:') {
            if (Test-Path $cmd) {
                $ok = $true
                $how = "Test-Path"
            } else {
                # try a normalized windows path fallback
                $winCmd = $cmd -replace '/', '\'
                if (Test-Path $winCmd) {
                    $ok = $true
                    $how = "Test-Path(normalized)"
                    $s.Value.command = $winCmd
                } else {
                    $ok = $false
                    $how = "path not found"
                }
            }
        } else {
            $gc = Get-Command $cmd -ErrorAction SilentlyContinue
            if ($gc) {
                $ok = $true
                $how = "Get-Command"
            } else {
                $ok = $false
                $how = "command not found on PATH"
            }
        }
    }

    $mcpValidation += [pscustomobject]@{
        server = $name
        command = $s.Value.command
        ok = $ok
        check = $how
    }
    Write-Diag ("MCP server '{0}': ok={1} via {2}" -f $name, $ok, $how)
}

# rewrite resolved file if normalization changed commands
$resolved | ConvertTo-Json -Depth 20 | Set-Content -Path $ResolvedMcp -Encoding UTF8

# ------------------------------------------------------------------------------
# Environment variables for Open WebUI runtime
# ------------------------------------------------------------------------------
$env:ENABLE_MCP = "true"
$env:MCP_CONFIG_PATH = $ResolvedMcp
$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:ENABLE_PERSISTENT_CONFIG = "false"

Write-Diag "Set ENABLE_MCP=true"
Write-Diag "Set MCP_CONFIG_PATH=$ResolvedMcp"
Write-Diag "Set OLLAMA_BASE_URL=$($env:OLLAMA_BASE_URL)"
Write-Diag "Set ENABLE_PERSISTENT_CONFIG=false"

# ------------------------------------------------------------------------------
# Health check helper
# ------------------------------------------------------------------------------
function Test-HttpEndpoint {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [int]$TimeoutSec = 3
    )
    try {
        $r = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec $TimeoutSec
        return [pscustomobject]@{ ok = $true; status = $r.StatusCode; message = "OK" }
    } catch {
        return [pscustomobject]@{ ok = $false; status = ""; message = $_.Exception.Message }
    }
}

# Ollama readiness
$ollamaCheck = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 3
Write-Diag "Ollama check: ok=$($ollamaCheck.ok) status=$($ollamaCheck.status) msg=$($ollamaCheck.message)"

# ------------------------------------------------------------------------------
# Launch Open WebUI
# ------------------------------------------------------------------------------
$openWebUiProc = $null
$launchMode = ""
if ($DebugForeground) {
    Write-Diag "DebugForeground enabled: launching in foreground"
    try {
        $launchMode = "python -m open_webui serve (foreground)"
        & python -m open_webui serve
        exit 0
    } catch {
        Write-Diag "Foreground python launch failed: $($_.Exception.Message)"
        Write-Diag "Trying foreground open-webui.exe serve"
        $launchMode = "open-webui.exe serve (foreground)"
        & open-webui.exe serve
        exit 0
    }
} else {
    try {
        $launchMode = "python -m open_webui serve"
        $openWebUiProc = Start-Process -FilePath "python" -ArgumentList "-m open_webui serve" -RedirectStandardOutput $WebUiLog -RedirectStandardError $WebUiLog -PassThru -WindowStyle Hidden
        Write-Diag "Launched Open WebUI with python module mode (PID=$($openWebUiProc.Id))"
    } catch {
        Write-Diag "Primary launch failed: $($_.Exception.Message)"
        $launchMode = "open-webui.exe serve"
        $openWebUiProc = Start-Process -FilePath "open-webui.exe" -ArgumentList "serve" -RedirectStandardOutput $WebUiLog -RedirectStandardError $WebUiLog -PassThru -WindowStyle Hidden
        Write-Diag "Launched Open WebUI with executable mode (PID=$($openWebUiProc.Id))"
    }
}

# wait briefly, then check web UI
Start-Sleep -Seconds 5
$webuiCheck = Test-HttpEndpoint -Url "http://localhost:8080" -TimeoutSec 3
Write-Diag "Open WebUI check: ok=$($webuiCheck.ok) status=$($webuiCheck.status) msg=$($webuiCheck.message)"

# ------------------------------------------------------------------------------
# Write concise run summary (NO here-string to avoid UI mangling)
# ------------------------------------------------------------------------------
$mcpPreview = Get-Content -Raw -Path $ResolvedMcp

$validationLines = @()
foreach ($row in $mcpValidation) {
    $validationLines += "- $($row.server): ok=$($row.ok), check=$($row.check), command=`"$($row.command)`""
}
$validationTable = ($validationLines -join "`n")

$summaryLines = @()
$summaryLines += "# Local AI Launch Run Summary"
$summaryLines += ""
$summaryLines += "- Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summaryLines += "- Repo root: $RepoRoot"
$summaryLines += "- Launch mode: $launchMode"
$summaryLines += ""
$summaryLines += "## Health checks"
$summaryLines += "- Ollama (`http://localhost:11434/api/tags`): ok=$($ollamaCheck.ok), status=$($ollamaCheck.status), msg=$($ollamaCheck.message)"
$summaryLines += "- Open WebUI (`http://localhost:8080`): ok=$($webuiCheck.ok), status=$($webuiCheck.status), msg=$($webuiCheck.message)"
$summaryLines += ""
$summaryLines += "## MCP validation"
$summaryLines += $validationTable
$summaryLines += ""
$summaryLines += "## Active files"
$summaryLines += "- Diagnostic log: $DiagLog"
$summaryLines += "- Open WebUI log: $WebUiLog"
$summaryLines += "- Run summary: $RunSummary"
$summaryLines += "- Resolved MCP config: $ResolvedMcp"
$summaryLines += ""
$summaryLines += "## MCP JSON preview"
$summaryLines += "```json"
$summaryLines += $mcpPreview
$summaryLines += "```"

$summary = $summaryLines -join "`n"

Set-Content -Path $RunSummary -Value $summary -Encoding UTF8
Write-Diag "Run summary written to $RunSummary"

if ($webuiCheck.ok) {
    Write-Diag "SUCCESS: Open WebUI is reachable at http://localhost:8080"
    Start-Process "http://localhost:8080" | Out-Null
} else {
    Write-Diag "WARNING: Open WebUI not reachable yet. Check $WebUiLog and $DiagLog"
}