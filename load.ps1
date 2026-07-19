# ==============================================================================
# load.ps1 - Hardened repo-root orchestrator for local workstation scripts
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$Deploy,
    [switch]$DebugForeground,
    [switch]$AllowMissingMcpCommands
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path $PSScriptRoot).Path
$WorkstationDir = Join-Path $RepoRoot "inst\local-workstation"
$LocalAiDir = Join-Path $RepoRoot "dev\sessions\local-ai"

if (-not (Test-Path $WorkstationDir)) {
    throw ("Workstation directory not found: " + $WorkstationDir)
}

if (-not (Test-Path $LocalAiDir)) {
    New-Item -ItemType Directory -Path $LocalAiDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$terminalLog = Join-Path $LocalAiDir ("terminal-run-" + $timestamp + ".log")

Start-Transcript -Path $terminalLog -Force | Out-Null

$exitCode = 0

try {
    $deployPath = Join-Path $WorkstationDir "deploy.ps1"
    $launchPath = Join-Path $WorkstationDir "launch.ps1"

    if ($Deploy.IsPresent) {
        Write-Host "[LOAD] Running deploy.ps1 ..." -ForegroundColor Cyan
        if (-not (Test-Path $deployPath)) {
            throw ("deploy.ps1 not found: " + $deployPath)
        }
        & $deployPath
    } else {
        Write-Host "[LOAD] Skipping deploy.ps1 (use -Deploy to include it)." -ForegroundColor Yellow
    }

    if (-not (Test-Path $launchPath)) {
        throw ("launch.ps1 not found: " + $launchPath)
    }

    # Parser preflight check for launch.ps1
    $tokens = $null
    $parseErrors = @()
    [System.Management.Automation.Language.Parser]::ParseFile($launchPath, [ref]$tokens, [ref]$parseErrors) | Out-Null

    if ($parseErrors.Count -gt 0) {
        Write-Host "[LOAD] launch.ps1 parse failed. Refusing to run." -ForegroundColor Red
        foreach ($e in $parseErrors) {
            $line = $e.Extent.StartLineNumber
            $col = $e.Extent.StartColumnNumber
            Write-Host ("[LOAD] ParseError L{0}:C{1} - {2}" -f $line, $col, $e.Message) -ForegroundColor Red
        }
        throw "launch.ps1 failed parser preflight."
    }

    Write-Host "[LOAD] Running launch.ps1 ..." -ForegroundColor Cyan

    $launchArgs = @()
    if ($DebugForeground.IsPresent) { $launchArgs += "-DebugForeground" }
    if ($AllowMissingMcpCommands.IsPresent) { $launchArgs += "-AllowMissingMcpCommands" }

    if ($launchArgs.Count -gt 0) {
        & $launchPath @launchArgs
    } else {
        & $launchPath
    }

    Write-Host "[LOAD] launch.ps1 completed." -ForegroundColor Green
}
catch {
    $exitCode = 1
    Write-Host ("[LOAD] ERROR: " + $_.Exception.Message) -ForegroundColor Red
    throw
}
finally {
    Stop-Transcript | Out-Null
    if ($exitCode -ne 0) {
        Write-Host ("[LOAD] FAILED. Transcript: " + $terminalLog) -ForegroundColor Red
    } else {
        Write-Host ("[LOAD] DONE. Transcript: " + $terminalLog) -ForegroundColor Green
    }
}