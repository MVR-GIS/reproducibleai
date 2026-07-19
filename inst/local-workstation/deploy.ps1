# ==============================================================================
# DEPLOY-STACK.PS1: Complete Workspace Installer & Core Model Provisioner
# ==============================================================================
$ErrorActionPreference = "Stop"

# 1. HARDEN CAPABILITIES AND CALIBRATE Handshake MATRICES
Write-Host "Configuring cryptographic handshake and certificate parameters..." -ForegroundColor Cyan
$env:SSL_CERT_RECTYPE = "win"
$env:UV_CERT_BUNDLE = "win"

$LocalStackDir = "$env:USERPROFILE\AppData\Local\LocalAIStack"
if (-not (Test-Path $LocalStackDir)) { New-Item -ItemType Directory -Force -Path $LocalStackDir | Out-Null }

$PossibleCertPath = "$env:USERPROFILE\.config\reproducibleai\dod_root.pem"
if (Test-Path $PossibleCertPath) {
    $env:AWS_CA_BUNDLE = $PossibleCertPath
    $env:REQUESTS_CA_BUNDLE = $PossibleCertPath
    $env:NODE_EXTRA_CA_CERTS = $PossibleCertPath
}

# 2. VERSION TARGET DEFINITIONS
$OpenWebUIVersion = "0.10.2"
$OllamaVersion = "0.31.2"
$UserLocalBin = "$env:USERPROFILE\.local\bin"
$UserUV = "$UserLocalBin\uv.exe"

# 3. VERIFY BASE RUNTIME UTILITIES
Write-Host "Validating standalone user-space 'uv' engine..." -ForegroundColor Cyan
if (-not (Test-Path $UserUV)) {
    $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    $InstallScript = Invoke-WebRequest -Uri "https://astral.sh" -UserAgent $UserAgent -UseBasicParsing
    Invoke-Expression $InstallScript.Content
}

# 4. IDEMPOTENT OLLAMA STORAGE SYNC
Write-Host "Initializing temporary Ollama runtime layer to cache models..." -ForegroundColor Cyan

# FORCE MODEL WEIGHTS INTENDED ROOT LOCATION: Bypasses ~/.ollama path usage completely
$env:OLLAMA_MODELS = "$LocalStackDir\ollama\models"
if (-not (Test-Path $env:OLLAMA_MODELS)) { New-Item -ItemType Directory -Force -Path $env:OLLAMA_MODELS | Out-Null }

if (Get-Process "ollama" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

# Spin up a temporary daemon pointing directly to our isolated path targets
$TempOllamaServe = Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3

Write-Host "Downloading and caching Qwen 2.5 Coder 32B Instruct weights..." -ForegroundColor Yellow
& ollama pull qwen2.5-coder:32b-instruct

Write-Host "Safely cleaning down deployment runtime hooks..." -ForegroundColor Cyan
Stop-Process -Id $TempOllamaServe.Id -Force

# 5. ISOLATED CONDALAYER ENVIRONMENT MANAGEMENT COMPILATION
Write-Host "Validating trusted Miniforge layer..." -ForegroundColor Cyan
$CondaBin = "$env:USERPROFILE\AppData\Local\miniforge3\Scripts\conda.exe"
if (-not (Test-Path $CondaBin)) {
    $CondaBin = Get-Command "conda" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

$EnvTargetName = "open-webui-gov"
$EnvCheck = & $CondaBin env list | Out-String
if (-not ($EnvCheck -match $EnvTargetName)) {
    & $CondaBin create --name $EnvTargetName python=3.11 --yes --quiet
}

$CondaPipExe = "$env:USERPROFILE\AppData\Local\miniforge3\envs\$EnvTargetName\Scripts\pip.exe"
Write-Host "Compiling full Open WebUI application framework..." -ForegroundColor Yellow
& $CondaPipExe install "open-webui==$OpenWebUIVersion" --no-cache-dir

Write-Host "`n[SUCCESS] Toolchain and core models successfully deployed and locked." -ForegroundColor Green
