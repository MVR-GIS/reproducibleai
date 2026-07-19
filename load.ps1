# Convenience runner with transcript
if (-not (Test-Path .\dev\sessions\local-ai)) {
  New-Item -ItemType Directory -Force -Path .\dev\sessions\local-ai | Out-Null
}
$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$TranscriptPath = ".\dev\sessions\local-ai\terminal-run-$ts.log"

Start-Transcript -Path $TranscriptPath -Force
try {
  Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
  .\inst\local-workstation\deploy.ps1
  .\inst\local-workstation\launch.ps1
}
finally {
  Stop-Transcript
}
Write-Host "Transcript saved to: $TranscriptPath" -ForegroundColor Green