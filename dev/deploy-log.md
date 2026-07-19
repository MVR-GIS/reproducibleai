> # ==============================================================================
> # DEPLOY-STACK.PS1: Complete Workspace Installer & Core Model Provisioner
> # ==============================================================================
> $ErrorActionPreference = "Stop"
> 
> # 1. HARDEN CAPABILITIES AND CALIBRATE Handshake MATRICES
> Write-Host "Configuring cryptographic handshake and certificate parameters..." -ForegroundColor Cyan
Configuring cryptographic handshake and certificate parameters...
> $env:SSL_CERT_RECTYPE = "win"
> $env:UV_CERT_BUNDLE = "win"
> 
> $LocalStackDir = "$env:USERPROFILE\AppData\Local\LocalAIStack"
> if (-not (Test-Path $LocalStackDir)) { New-Item -ItemType Directory -Force -Path $LocalStackDir | Out-Null }
> 
> $PossibleCertPath = "$env:USERPROFILE\.config\reproducibleai\dod_root.pem"
> if (Test-Path $PossibleCertPath) {
>>     $env:AWS_CA_BUNDLE = $PossibleCertPath
>>     $env:REQUESTS_CA_BUNDLE = $PossibleCertPath
>>     $env:NODE_EXTRA_CA_CERTS = $PossibleCertPath
>> }
> 
> # 2. VERSION TARGET DEFINITIONS
> $OpenWebUIVersion = "0.10.2"
> $OllamaVersion = "0.31.2"
> $UserLocalBin = "$env:USERPROFILE\.local\bin"
> $UserUV = "$UserLocalBin\uv.exe"
> 
> # 3. VERIFY BASE RUNTIME UTILITIES
> Write-Host "Validating standalone user-space 'uv' engine..." -ForegroundColor Cyan
Validating standalone user-space 'uv' engine...
> if (-not (Test-Path $UserUV)) {
>>     $UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
>>     $InstallScript = Invoke-WebRequest -Uri "https://astral.sh" -UserAgent $UserAgent -UseBasicParsing      
>>     Invoke-Expression $InstallScript.Content
>> }
> 
> # 4. IDEMPOTENT OLLAMA STORAGE SYNC
> Write-Host "Initializing temporary Ollama runtime layer to cache models..." -ForegroundColor Cyan
Initializing temporary Ollama runtime layer to cache models...
> 
> # FORCE MODEL WEIGHTS INTENDED ROOT LOCATION: Bypasses ~/.ollama path usage completely
> $env:OLLAMA_MODELS = "$LocalStackDir\ollama\models"
> if (-not (Test-Path $env:OLLAMA_MODELS)) { New-Item -ItemType Directory -Force -Path $env:OLLAMA_MODELS | Out-Null }
> 
> if (Get-Process "ollama" -ErrorAction SilentlyContinue) {
>>     Stop-Process -Name "ollama" -Force -ErrorAction SilentlyContinue
>>     Start-Sleep -Seconds 1
>> }
> 
> # Spin up a temporary daemon pointing directly to our isolated path targets
> $TempOllamaServe = Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden -PassThru
> Start-Sleep -Seconds 3
> 
> Write-Host "Downloading and caching Qwen 2.5 Coder 32B Instruct weights..." -ForegroundColor Yellow
Downloading and caching Qwen 2.5 Coder 32B Instruct weights...
> & ollama pull qwen2.5-coder:32b-instruct
pulling manifest
pulling ac3d1ba8aa77: 100% ▕█████████████████████████████████████████████████▏  19 GB
pulling 66b9ea09bd5b: 100% ▕█████████████████████████████████████████████████▏   68 B
pulling 1e65450c3067: 100% ▕█████████████████████████████████████████████████▏ 1.6 KB
pulling 832dd9e00a68: 100% ▕█████████████████████████████████████████████████▏  11 KB
pulling f0676bd3c336: 100% ▕█████████████████████████████████████████████████▏  488 B
verifying sha256 digest
writing manifest
success
> 
> Write-Host "Safely cleaning down deployment runtime hooks..." -ForegroundColor Cyan
Safely cleaning down deployment runtime hooks...
> Stop-Process -Id $TempOllamaServe.Id -Force
> 
> # 5. ISOLATED CONDALAYER ENVIRONMENT MANAGEMENT COMPILATION
> Write-Host "Validating trusted Miniforge layer..." -ForegroundColor Cyan
Validating trusted Miniforge layer...
> $CondaBin = "$env:USERPROFILE\AppData\Local\miniforge3\Scripts\conda.exe"
> if (-not (Test-Path $CondaBin)) {
>>     $CondaBin = Get-Command "conda" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source    
>> }
> 
> $EnvTargetName = "open-webui-gov"
> $EnvCheck = & $CondaBin env list | Out-String
> if (-not ($EnvCheck -match $EnvTargetName)) {
>>     & $CondaBin create --name $EnvTargetName python=3.11 --yes --quiet
>> }
> 
> $CondaPipExe = "$env:USERPROFILE\AppData\Local\miniforge3\envs\$EnvTargetName\Scripts\pip.exe"
> Write-Host "Compiling full Open WebUI application framework..." -ForegroundColor Yellow
Compiling full Open WebUI application framework...
> & $CondaPipExe install "open-webui==$OpenWebUIVersion" --no-cache-dir
Requirement already satisfied: open-webui==0.10.2 in C:\Users\B5PMMMPD\AppData\Local\miniforge3\envs\open-webui-gov\Lib\site-packages (0.10.2)
Requirement already satisfied: shellingham>=1.3.0 in C:\Users\B5PMMMPD\AppData\Local\miniforge3\envs\open-webui-gov\Lib\site-packages (from typer>=0.9.0->chromadb==1.5.9->open-webui==0.10.2) (1.5.4)
...
Requirement already satisfied: MarkupSafe>=2.0 in C:\Users\B5PMMMPD\AppData\Local\miniforge3\envs\open-webui-gov\Lib\site-packages (from jinja2->torch>=2.0.0->accelerate==1.13.0->open-webui==0.10.2) (3.0.3)
> 
> Write-Host "`n[SUCCESS] Toolchain and core models successfully deployed and locked." -ForegroundColor Green

[SUCCESS] Toolchain and core models successfully deployed and locked.