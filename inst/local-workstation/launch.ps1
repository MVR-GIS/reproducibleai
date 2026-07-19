# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (Native STDIO MCP)
# ==============================================================================
$ErrorActionPreference = "Stop"

$ExecutionDir = Get-Location | Select-Object -ExpandProperty Path
$LocalStackDir = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
$DataDir = Join-Path $LocalStackDir "open-webui-data"
$NpmBin = Join-Path $env:APPDATA "npm"

$LogDir = Join-Path $ExecutionDir "dev\sessions\local-ai"
if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$WebUILog = Join-Path $LogDir "open-webui-$Stamp.log"

function Resolve-Tokens {
    param([string]$InputText, [string]$WorkspaceRoot)

    if ([string]::IsNullOrEmpty($InputText)) { return $InputText }
    $resolved = $InputText.Replace('${APPDATA}', $env:APPDATA)
    $resolved = $resolved.Replace('${WORKSPACE_ROOT}', $WorkspaceRoot.Replace('\','/'))
    return $resolved
}

# 1) Determine scope
$BoundsPath = Join-Path $ExecutionDir "dev\config\workspace-bounds.json"
$TargetScopePath = ""
$ContextMode = ""

if (Test-Path $BoundsPath) {
    $RepoConfig = Get-Content -Raw -Path $BoundsPath -Encoding UTF8 | ConvertFrom-Json
    $TargetScopePath = $ExecutionDir
    $ContextMode = "REPO-ISOLATED (Project: $($RepoConfig.project_name))"
} else {
    $TargetScopePath = Split-Path -Path $ExecutionDir -Parent
    $ContextMode = "MULTI-REPO WORKSPACE (Directory: $TargetScopePath)"
}

Write-Host "Initializing Local AI Orchestration Ecosystem" -ForegroundColor Cyan
Write-Host "Operating Mode: $ContextMode" -ForegroundColor Yellow

# 2) Ensure data dir
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

# 3) Build MCP config (prefer repo config, fallback to defaults)
$RepoMcpPath = Join-Path $ExecutionDir "dev\config\open-webui-mcp-routing.json"
$McpConfigPath = Join-Path $DataDir "mcp_config.json"

if (Test-Path $RepoMcpPath) {
    Write-Host "Loading MCP config from repo: $RepoMcpPath" -ForegroundColor Cyan
    $RepoMcp = Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8 | ConvertFrom-Json

    foreach ($serverProp in $RepoMcp.mcpServers.PSObject.Properties) {
        $serverName = $serverProp.Name
        $serverObj = $serverProp.Value

        if ($serverObj.command) {
            $serverObj.command = Resolve-Tokens -InputText $serverObj.command -WorkspaceRoot $TargetScopePath
        }

        if ($serverObj.args) {
            $resolvedArgs = @()
            foreach ($a in $serverObj.args) {
                $resolvedArgs += (Resolve-Tokens -InputText ([string]$a) -WorkspaceRoot $TargetScopePath)
            }
            $serverObj.args = $resolvedArgs
        }

        $RepoMcp.mcpServers.$serverName = $serverObj
    }

    $FinalMcpConfig = $RepoMcp
} else {
    Write-Host "No repo MCP config found. Using fallback defaults." -ForegroundColor Yellow
    $FsCmd = Join-Path $NpmBin "mcp-server-filesystem.cmd"
    $GitCmd = Join-Path $NpmBin "mcp-server-git.cmd"

    $FinalMcpConfig = @{
        mcpServers = @{
            local_filesystem = @{
                command = $FsCmd
                args    = @($TargetScopePath.Replace("\","/"))
            }
            local_git = @{
                command = $GitCmd
                args    = @()
            }
        }
    }
}

# 4) Preflight MCP command paths
foreach ($serverProp in $FinalMcpConfig.mcpServers.PSObject.Properties) {
    $cmdPath = $serverProp.Value.command
    if (-not (Test-Path $cmdPath)) {
        throw "MCP server command not found for '$($serverProp.Name)': $cmdPath"
    }
}

# 5) Persist resolved MCP config as UTF-8
$FinalMcpConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $McpConfigPath -Encoding utf8 -Force
Write-Host "Resolved MCP config written to: $McpConfigPath" -ForegroundColor Green

# 6) Runtime environment
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

# 7) Clean restart + ensure ollama
Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

# 8) Resolve Open WebUI executable
$WebUIExeCandidates = @(
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"),
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui")
)
$WebUIExe = $WebUIExeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $WebUIExe) {
    throw "Could not find Open WebUI executable in env 'open-webui-gov'."
}

# 9) Start Open WebUI with log redirection
Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
    -RedirectStandardOutput $WebUILog `
    -RedirectStandardError $WebUILog `
    -WindowStyle Hidden

Write-Host "`n[SUCCESS] Local workstation launched." -ForegroundColor Green
Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
Write-Host "WebUI log: $WebUILog" -ForegroundColor Yellow
Start-Process "http://localhost:8080"
