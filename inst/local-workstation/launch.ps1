# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (Native STDIO MCP)
# ==============================================================================
$ErrorActionPreference = "Stop"

$ExecutionDir   = (Get-Location).Path
$LocalStackDir  = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
$DataDir        = Join-Path $LocalStackDir "open-webui-data"
$NpmBin         = Join-Path $env:APPDATA "npm"
$LogDir         = Join-Path $ExecutionDir "dev\sessions\local-ai"
$ConfigDir      = Join-Path $ExecutionDir "dev\config"
$RepoMcpPath    = Join-Path $ConfigDir "open-webui-mcp-routing.json"
$BoundsPath     = Join-Path $ConfigDir "workspace-bounds.json"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

$Stamp      = Get-Date -Format "yyyyMMdd-HHmmss"
$WebUILog   = Join-Path $LogDir "open-webui-$Stamp.log"
$McpOutPath = Join-Path $DataDir "mcp_config.json"

function Resolve-TokenString {
  param([string]$Text, [string]$WorkspaceRoot)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }
  $x = $Text.Replace('${APPDATA}', $env:APPDATA)
  $x = $x.Replace('${WORKSPACE_ROOT}', ($WorkspaceRoot -replace '\\','/'))
  return $x
}

function Get-WorkspaceScope {
  param([string]$ExecutionDir, [string]$BoundsPath)
  if (Test-Path $BoundsPath) {
    $raw = Get-Content -Raw -Path $BoundsPath -Encoding UTF8
    $obj = $raw | ConvertFrom-Json
    return @{
      Path = $ExecutionDir
      Mode = "REPO-ISOLATED (Project: $($obj.project_name))"
    }
  } else {
    $parent = Split-Path -Path $ExecutionDir -Parent
    return @{
      Path = $parent
      Mode = "MULTI-REPO WORKSPACE (Directory: $parent)"
    }
  }
}

function Get-DefaultMcpConfig {
  param([string]$WorkspaceRoot, [string]$NpmBin)
  $fs = Join-Path $NpmBin "mcp-server-filesystem.cmd"
  $git = Join-Path $NpmBin "mcp-server-git.cmd"
  return @{
    mcpServers = @{
      local_filesystem = @{
        command = $fs
        args    = @($WorkspaceRoot -replace '\\','/')
      }
      local_git = @{
        command = $git
        args    = @()
      }
    }
  }
}

$scope = Get-WorkspaceScope -ExecutionDir $ExecutionDir -BoundsPath $BoundsPath
$TargetScopePath = $scope.Path
$ContextMode     = $scope.Mode

Write-Host "Initializing Local AI Orchestration Ecosystem" -ForegroundColor Cyan
Write-Host "Operating Mode: $ContextMode" -ForegroundColor Yellow

# Build MCP config (repo file preferred)
if (Test-Path $RepoMcpPath) {
  Write-Host "Loading MCP config from repo: $RepoMcpPath" -ForegroundColor Cyan
  $raw = Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8
  $mcp = $raw | ConvertFrom-Json
} else {
  Write-Host "Repo MCP config missing. Using defaults." -ForegroundColor Yellow
  $mcp = Get-DefaultMcpConfig -WorkspaceRoot $TargetScopePath -NpmBin $NpmBin
}

# Resolve tokens + validate each server command
foreach ($p in $mcp.mcpServers.PSObject.Properties) {
  $server = $p.Value
  $server.command = Resolve-TokenString -Text ([string]$server.command) -WorkspaceRoot $TargetScopePath

  if ($server.args) {
    $resolved = @()
    foreach ($a in $server.args) {
      $resolved += (Resolve-TokenString -Text ([string]$a) -WorkspaceRoot $TargetScopePath)
    }
    $server.args = $resolved
  }

  if (-not (Test-Path $server.command)) {
    throw "MCP command not found for server '$($p.Name)': $($server.command)"
  }
}

# Persist resolved MCP config as UTF-8 (no BOM)
$json = $mcp | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText($McpOutPath, $json, New-Object System.Text.UTF8Encoding($false))
Write-Host "Resolved MCP config: $McpOutPath" -ForegroundColor Green

# Runtime env
$env:DATA_DIR = $DataDir
$env:MCP_CONFIG_PATH = $McpOutPath
$env:ENABLE_MCP = "true"

$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:OLLAMA_MODELS   = Join-Path $LocalStackDir "ollama\models"

$env:ENABLE_OPENAI_API   = "false"
$env:OPENAI_API_BASE_URL = ""
$env:OPENAI_API_BASE_URLS = ""
$env:OPENAI_API_KEYS = ""

$env:RAG_EMBEDDING_ENGINE    = "ollama"
$env:ENABLE_PERSISTENT_CONFIG = "false"
$env:WEBUI_AUTH = "false"

# Kill stale Open WebUI
Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Ensure ollama serving
if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
  Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  Start-Sleep -Seconds 3
}

# Resolve open-webui exe
$WebUICandidates = @(
  (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"),
  (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui")
)
$WebUIExe = $WebUICandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $WebUIExe) { throw "Open WebUI executable not found in env open-webui-gov." }

Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
  -RedirectStandardOutput $WebUILog `
  -RedirectStandardError $WebUILog `
  -WindowStyle Hidden

Write-Host "`n[SUCCESS] Local workstation launched." -ForegroundColor Green
Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
Write-Host "Open WebUI log: $WebUILog" -ForegroundColor Yellow
Start-Process "http://localhost:8080"
