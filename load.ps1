# ==============================================================================
# load.ps1 - Simple entrypoint for local AI workstation POC
# Stack: Positron + Continue + Ollama + MCP
# ==============================================================================
[CmdletBinding()]
param(
    [string]$TargetModel = "qwen2.5-coder:32b-instruct",
    [switch]$InstallMcpServers,
    [switch]$AutoPullModel,
    [switch]$SkipDeploy,
    [switch]$AllowMissingMcpCommands
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$RepoRoot = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$DeployScript = Join-Path $RepoRoot "inst\local-workstation\deploy.ps1"
$LaunchScript = Join-Path $RepoRoot "inst\local-workstation\launch.ps1"
$SummaryPath = Join-Path $RepoRoot "dev\sessions\local-ai\latest-run-summary.md"
$DiagPath = Join-Path $RepoRoot "dev\sessions\local-ai\latest-launch-diag.log"

if (-not (Test-Path $DeployScript)) { throw "Missing deploy script: $DeployScript" }
if (-not (Test-Path $LaunchScript)) { throw "Missing launch script: $LaunchScript" }

Write-Host ""
Write-Host "=== Local AI Workstation POC Loader ===" -ForegroundColor Cyan
Write-Host ("RepoRoot: " + $RepoRoot)
Write-Host ("TargetModel: " + $TargetModel)
Write-Host ""

if (-not $SkipDeploy.IsPresent) {
    Write-Host "[1/2] Running deploy preflight..." -ForegroundColor Cyan

    $deploySplat = @{
        TargetModel = $TargetModel
    }
    if ($InstallMcpServers.IsPresent) { $deploySplat.InstallMcpServers = $true }
    if ($AutoPullModel.IsPresent)     { $deploySplat.AutoPullModel = $true }

    & $DeployScript @deploySplat
}
else {
    Write-Host "[1/2] Skipping deploy preflight by request." -ForegroundColor Yellow
}

Write-Host "[2/2] Running launch validator..." -ForegroundColor Cyan

$launchSplat = @{
    TargetModel = $TargetModel
}
if ($AutoPullModel.IsPresent)          { $launchSplat.AutoPullModel = $true }
if ($AllowMissingMcpCommands.IsPresent){ $launchSplat.AllowMissingMcpCommands = $true }

& $LaunchScript @launchSplat

Write-Host ""
Write-Host "=== Run artifacts ===" -ForegroundColor Cyan
if (Test-Path $SummaryPath) {
    Write-Host ("Summary: " + $SummaryPath) -ForegroundColor Green
} else {
    Write-Host ("Summary not found yet: " + $SummaryPath) -ForegroundColor Yellow
}
if (Test-Path $DiagPath) {
    Write-Host ("Diag log: " + $DiagPath) -ForegroundColor Green
}
Write-Host ""

if (Test-Path $SummaryPath) {
    try { Start-Process $SummaryPath | Out-Null } catch {}
}