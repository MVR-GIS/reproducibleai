# ==============================================================================
# DEPLOY-STACK.PS1: Complete Workspace Installer & Core Model Provisioner
# ==============================================================================
$ErrorActionPreference = "Stop"

Write-Host "Configuring certificate and environment parameters..." -ForegroundColor Cyan
$env:SSL_CERT_RECTYPE = "win"
$env:UV_CERT_BUNDLE = "win"

$LocalStackDir = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
if (-not (Test-Path $LocalStackDir)) { New-Item -ItemType Directory -Force -Path $LocalStackDir | Out-Null }

$PossibleCertPath = Join-Path $env:USERPROFILE ".config\reproducibleai\dod_root.pem"
if (Test-Path $PossibleCertPath) {
    $env:AWS_CA_BUNDLE = $PossibleCertPath
    $env:REQUESTS_CA_BUNDLE = $PossibleCertPath
    $env:NODE_EXTRA_CA_CERTS = $PossibleCertPath
}

$OpenWebUIVersion = "0.10.2"
$EnvTargetName = "open-webui-gov"
$ModelToCache = "qwen2.5-coder:32b-instruct"

# 1) Locate conda
Write-Host "Locating conda..." -ForegroundColor Cyan
$CondaCandidates = @(
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\Scripts\conda.exe"),
    (Get-Command "conda" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source)
) | Where-Object { $_ -and (Test-Path $_) }

$CondaBin = $CondaCandidates | Select-Object -First 1
if (-not $CondaBin) { throw "Conda not found. Install Miniforge or ensure conda is on PATH." }

# 2) Ensure env exists
Write-Host "Ensuring conda env '$EnvTargetName' exists..." -ForegroundColor Cyan
$EnvCheck = & $CondaBin env list | Out-String
if (-not ($EnvCheck -match $EnvTargetName)) {
    & $CondaBin create --name $EnvTargetName python=3.11 --yes --quiet
}

$CondaRoot = Split-Path (Split-Path $CondaBin -Parent) -Parent
$CondaPipExe = Join-Path $CondaRoot "envs\$EnvTargetName\Scripts\pip.exe"
if (-not (Test-Path $CondaPipExe)) {
    throw "pip.exe not found for env '$EnvTargetName': $CondaPipExe"
}

# 3) Install Open WebUI
Write-Host "Installing Open WebUI $OpenWebUIVersion..." -ForegroundColor Yellow
& $CondaPipExe install "open-webui==$OpenWebUIVersion" --no-cache-dir

# 4) Prepare Ollama model storage and cache model
$env:OLLAMA_MODELS = Join-Path $LocalStackDir "ollama\models"
if (-not (Test-Path $env:OLLAMA_MODELS)) { New-Item -ItemType Directory -Force -Path $env:OLLAMA_MODELS | Out-Null }

if (Get-Process "ollama" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Host "Starting temporary Ollama daemon..." -ForegroundColor Cyan
$TempOllamaServe = Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3

Write-Host "Caching model: $ModelToCache" -ForegroundColor Yellow
& ollama pull $ModelToCache

Write-Host "Stopping temporary Ollama daemon..." -ForegroundColor Cyan
Stop-Process -Id $TempOllamaServe.Id -Force -ErrorAction SilentlyContinue

Write-Host "`n[SUCCESS] Deployment completed." -ForegroundColor Green
