# ==============================================================================
# LAUNCH.PS1: Pure Production Local AI Workspace Orchestrator (Native STDIO)
# ==============================================================================
$ErrorActionPreference = "Stop"

$ExecutionDir = Get-Location | Select-Object -ExpandProperty Path
$LocalStackDir = "$env:USERPROFILE\AppData\Local\LocalAIStack"

# 1. PARSE OPERATIONAL BOUNDARIES (Single Repo vs Workspace Context)
$ConfigPath = "$ExecutionDir\dev\config\workspace-bounds.json"
$TargetScopePath = ""
$ContextMode = ""

if (Test-Path $ConfigPath) {
    # Repo-Level Context Detected: Limit AI file operations to THIS specific folder
    $RepoConfig = Get-Content -Raw -Path $ConfigPath | ConvertFrom-Json
    $TargetScopePath = $ExecutionDir
    $ContextMode = "REPO-ISOLATED (Project: $($RepoConfig.project_name))"
} else {
    # Workspace-Level Context: Fallback to the parent folder containing multiple repos
    $TargetScopePath = Split-Path -Path $ExecutionDir -Parent
    $ContextMode = "MULTI-REPO WORKSPACE (Directory: $TargetScopePath)"
}

Write-Host "Initializing Local AI Orchestration Ecosystem" -ForegroundColor Cyan
Write-Host "Operating Mode: $ContextMode" -ForegroundColor Yellow

# 2. RE-GENERATE DYNAMIC USER PATHINGS
$env:DATA_DIR = "$LocalStackDir\open-webui-data"
if (-not (Test-Path $env:DATA_DIR)) { New-Item -ItemType Directory -Force -Path $env:DATA_DIR | Out-Null }

$DynamicMcpConfig = @{
    mcpServers = @{
        local_filesystem = @{
            command = "C:/Users/$env:USERNAME/AppData/Roaming/npm/mcp-server-filesystem.cmd"
            args    = @( $TargetScopePath.Replace("\", "/") )
        }
        local_git = @{
            command = "C:/Users/$env:USERNAME/AppData/Roaming/npm/mcp-server-git.cmd"
            args    = @()
        }
    }
}
$DynamicMcpConfig | ConvertTo-Json -Depth 5 | Out-File "$env:DATA_DIR\mcp_config.json" -Encoding utf8 -Force
Write-Host "Successfully synchronized repo tool configurations to local AI stack execution path." -ForegroundColor Green

# 3. PASS CONFIGURATIONS TO OPEN WEBUI VIA SYSTEM ENVIRONMENT VARIABLES
# Connect Open WebUI to your local compute engine for text models
$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:OLLAMA_MODELS = "$LocalStackDir\ollama\models"

# Disable the OpenAI API panel completely to prevent loop conflicts
$env:ENABLE_OPENAI_API = "false"
$env:OPENAI_API_BASE_URL = ""
$env:OPENAI_API_BASE_URLS = ""
$env:OPENAI_API_KEYS = ""

# Enable MCP system capabilities natively
$env:ENABLE_MCP = "true"
$env:RAG_EMBEDDING_ENGINE = "ollama"

# Prevent cached SQLite configurations from overriding launch environment variables
$env:ENABLE_PERSISTENT_CONFIG = "false"
$env:WEBUI_AUTH = "false" 

# Kill any lingering background open-webui servers from old tests to prevent port jamming
Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Start your local model server background process thread if offline
if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

# Execute the isolated frontend server framework via your verified Miniforge environment
$WebUIExe = "$env:USERPROFILE\AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"
Start-Process -FilePath $WebUIExe -ArgumentList "serve" -WindowStyle Hidden

Write-Host "`n[SUCCESS] Local Vibe-Coding Core actively routing." -ForegroundColor Green
Write-Host "Launch Dashboard Link: http://localhost:8080" -ForegroundColor Yellow
Start-Process "http://localhost:8080"
