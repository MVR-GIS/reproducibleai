# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (Native STDIO MCP)
# ==============================================================================
$ErrorActionPreference = "Stop"

$ExecutionDir = Get-Location | Select-Object -ExpandProperty Path
$LocalStackDir = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
$DataDir = Join-Path $LocalStackDir "open-webui-data"
$NpmBin = Join-Path $env:APPDATA "npm"
$FsCmd = Join-Path $NpmBin "mcp-server-filesystem.cmd"
$GitCmd = Join-Path $NpmBin "mcp-server-git.cmd"

# 1) Determine scope
$ConfigPath = Join-Path $ExecutionDir "dev\config\workspace-bounds.json"
$TargetScopePath = ""
$ContextMode = ""

if (Test-Path $ConfigPath) {
    $RepoConfig = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
    $TargetScopePath = $ExecutionDir
    $ContextMode = "REPO-ISOLATED (Project: $($RepoConfig.project_name))"
} else {
    $TargetScopePath = Split-Path -Path $ExecutionDir -Parent
    $ContextMode = "MULTI-REPO WORKSPACE (Directory: $TargetScopePath)"
}

Write-Host "Initializing Local AI Orchestration Ecosystem" -ForegroundColor Cyan
Write-Host "Operating Mode: $ContextMode" -ForegroundColor Yellow

# 2) Preflight checks
if (-not (Test-Path $FsCmd)) { throw "Missing MCP filesystem server: $FsCmd" }
if (-not (Test-Path $GitCmd)) { throw "Missing MCP git server: $GitCmd" }

if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
}

# 3) Build MCP config dynamically
$McpConfigPath = Join-Path $DataDir "mcp_config.json"
$DynamicMcpConfig = @{
    mcpServers = @{
        local_filesystem = @{
            command = $FsCmd
            args    = @($TargetScopePath.Replace("\", "/"))
        }
        local_git = @{
            command = $GitCmd
            args    = @()
        }
    }
}

$DynamicMcpConfig | ConvertTo-Json -Depth 8 | Out-File $McpConfigPath -Encoding utf8 -Force
Write-Host "MCP config written: $McpConfigPath" -ForegroundColor Green

# 4) Runtime environment for Open WebUI
$env:DATA_DIR = $DataDir
$env:MCP_CONFIG_PATH = $McpConfigPath
$env:ENABLE_MCP = "true"

$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:OLLAMA_MODELS = Join-Path $LocalStackDir "ollama\models"

$env:ENABLE_OPENAI_API = "false"
$env:OPENAI_API_BASE_URL = ""
$env:OPENAI_API_BASE_URLS = ""
$env:OPENAI_API_KEYS = ""

$env:RAG_EMBEDDING_ENGINE = "ollama"
$env:ENABLE_PERSISTENT_CONFIG = "false"
$env:WEBUI_AUTH = "false"

# 5) Ensure clean Open WebUI start
Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

# 6) Resolve Open WebUI executable
$WebUIExeCandidates = @(
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"),
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui")
)

$WebUIExe = $WebUIExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $WebUIExe) {
    throw "Could not find Open WebUI executable in open-webui-gov env."
}

# 7) Log output for debugging
$LogDir = Join-Path $ExecutionDir "dev\sessions\local-ai"
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
}
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$WebUILog = Join-Path $LogDir "open-webui-$Stamp.log"

Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
    -RedirectStandardOutput $WebUILog `
    -RedirectStandardError $WebUILog `
    -WindowStyle Hidden

Write-Host "`n[SUCCESS] Local workstation launched." -ForegroundColor Green
Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
Write-Host "Log file: $WebUILog" -ForegroundColor Yellow
Start-Process "http://localhost:8080"
