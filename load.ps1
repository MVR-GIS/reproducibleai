# ==============================================================================
# LOAD.PS1: Canonical runner for deploy + launch from repo root
# ==============================================================================
$ErrorActionPreference = "Stop"

# Force execution relative to THIS file's location (repo root)
$RepoRoot = $PSScriptRoot
Set-Location $RepoRoot

$SessionDir = Join-Path $RepoRoot "dev\sessions\local-ai"
if (-not (Test-Path $SessionDir)) {
  New-Item -ItemType Directory -Force -Path $SessionDir | Out-Null
}

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = Join-Path $SessionDir "terminal-run-$ts.log"

Start-Transcript -Path $TranscriptPath -Force
try {
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  & (Join-Path $RepoRoot "inst\local-workstation\deploy.ps1")
  & (Join-Path $RepoRoot "inst\local-workstation\launch.ps1")
}
finally {
  Stop-Transcript
}

Write-Host "Transcript: $TranscriptPath" -ForegroundColor Green
Write-Host "All logs directory: $SessionDir" -ForegroundColor Green