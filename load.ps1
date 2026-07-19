# ==============================================================================
# LOAD.PS1: Canonical test harness for local workstation scripts
# ==============================================================================
param(
  [switch]$Deploy,
  [switch]$DebugForeground
)

$ErrorActionPreference = "Stop"

$RepoRoot = $PSScriptRoot
Set-Location $RepoRoot

$SessionDir = Join-Path $RepoRoot "dev\sessions\local-ai"
if (-not (Test-Path $SessionDir)) {
  New-Item -ItemType Directory -Force -Path $SessionDir | Out-Null
}

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $SessionDir "terminal-run-$ts.log"
$LatestTranscript = Join-Path $SessionDir "latest-terminal-run.log"

$DeployScript = Join-Path $RepoRoot "inst\local-workstation\deploy.ps1"
$LaunchScript = Join-Path $RepoRoot "inst\local-workstation\launch.ps1"

Start-Transcript -Path $TranscriptPath -Force
try {
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

  if ($Deploy) {
    Write-Host "[LOAD] Running deploy.ps1 ..." -ForegroundColor Cyan
    & $DeployScript
  } else {
    Write-Host "[LOAD] Skipping deploy.ps1 (use -Deploy to include it)." -ForegroundColor DarkYellow
  }

  Write-Host "[LOAD] Running launch.ps1 ..." -ForegroundColor Cyan
  if ($DebugForeground) {
    & $LaunchScript -DebugForeground
  } else {
    & $LaunchScript
  }
}
finally {
  Stop-Transcript
}

# Update "latest" pointer copy for easy diagnostics
Copy-Item -Path $TranscriptPath -Destination $LatestTranscript -Force

Write-Host "[LOAD] Transcript: $TranscriptPath" -ForegroundColor Green
Write-Host "[LOAD] Latest transcript pointer: $LatestTranscript" -ForegroundColor Green
Write-Host "[LOAD] Logs directory: $SessionDir" -ForegroundColor Green
Write-Host "[LOAD] Tip: use .\load.ps1 -Deploy after dependency/version changes only." -ForegroundColor DarkGray