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
$McpOutPath     = Join-Path $DataDir "mcp_config.json"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

$Stamp    = Get-Date -Format "yyyyMMdd-HHmmss"
$WebUILog = Join-Path $LogDir "open-webui-$Stamp.log"

function Resolve-TokenString {
  param([string]$Text, [string]$WorkspaceRoot)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }
  $x = $Text.Replace('${APPDATA}', $env:APPDATA)
  $x = $x.Replace('${WORKSPACE_ROOT}', ($WorkspaceRoot -replace '\\','/'))
  $x = $x.Replace('${USERPROFILE}', $env:USERPROFILE)
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

function New-DefaultMcpServers {
  param([string]$WorkspaceRoot, [string]$NpmBin)

  $fs  = Join-Path $NpmBin "mcp-server-filesystem.cmd"
  $git = Join-Path $NpmBin "mcp-server-git.cmd"

  return @{
    local_filesystem = @{
      command = $fs
      args    = @($WorkspaceRoot -replace '\\','/')
      enabled = $true
    }
    local_git = @{
      command = $git
      args    = @()
      enabled = $true
    }
  }
}

function Normalize-McpConfig {
  param(
    [psobject]$ConfigObj,
    [string]$WorkspaceRoot
  )

  if (-not $ConfigObj.mcpServers) {
    throw "MCP config missing top-level 'mcpServers'."
  }

  foreach ($p in $ConfigObj.mcpServers.PSObject.Properties) {
    $name = $p.Name
    $server = $p.Value

    if (-not $server.command) {
      throw "MCP server '$name' missing required 'command'."
    }

    $server.command = Resolve-TokenString -Text ([string]$server.command) -WorkspaceRoot $WorkspaceRoot

    if ($server.args) {
      $resolved = @()
      foreach ($a in $server.args) {
        $resolved += (Resolve-TokenString -Text ([string]$a) -WorkspaceRoot $WorkspaceRoot)
      }
      $server.args = $resolved
    } else {
      $server.args = @()
    }

    if ($null -eq $server.enabled) {
      $server | Add-Member -NotePropertyName enabled -NotePropertyValue $true
    }

    $ConfigObj.mcpServers.$name = $server
  }

  return $ConfigObj
}

function Assert-McpCommandsExist {
  param([psobject]$ConfigObj)

  foreach ($p in $ConfigObj.mcpServers.PSObject.Properties) {
    $name = $p.Name
    $srv = $p.Value

    if ($srv.enabled -eq $false) { continue }

    if (-not (Test-Path $srv.command)) {
      throw "Enabled MCP server '$name' command not found: $($srv.command)"
    }
  }
}

function Write-Utf8NoBom {
  param([string]$Path, [string]$Content)
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Test-OllamaHealth {
  try {
    $resp = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
    return $true
  } catch {
    return $false
  }
}

$scope = Get-WorkspaceScope -ExecutionDir $ExecutionDir -BoundsPath $BoundsPath
$TargetScopePath = $scope.Path
$ContextMode     = $scope.Mode

Write-Host "Initializing Local AI Orchestration Ecosystem" -ForegroundColor Cyan
Write-Host "Operating Mode: $ContextMode" -ForegroundColor Yellow

# 1) Build config via merge strategy:
#    defaults -> repo overrides
$defaultObj = [pscustomobject]@{
  mcpServers = (New-DefaultMcpServers -WorkspaceRoot $TargetScopePath -NpmBin $NpmBin)
}

if (Test-Path $RepoMcpPath) {
  Write-Host "Applying repo MCP overrides from: $RepoMcpPath" -ForegroundColor Cyan
  $repoRaw = Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8
  $repoObj = $repoRaw | ConvertFrom-Json

  if (-not $repoObj.mcpServers) {
    throw "Repo MCP config exists but has no mcpServers object: $RepoMcpPath"
  }

  foreach ($p in $repoObj.mcpServers.PSObject.Properties) {
    $defaultObj.mcpServers | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
  }
} else {
  Write-Host "No repo MCP override config found. Using defaults only." -ForegroundColor Yellow
}

$finalObj = Normalize-McpConfig -ConfigObj $defaultObj -WorkspaceRoot $TargetScopePath
Assert-McpCommandsExist -ConfigObj $finalObj

$json = $finalObj | ConvertTo-Json -Depth 20
Write-Utf8NoBom -Path $McpOutPath -Content $json
Write-Host "Resolved MCP config written: $McpOutPath" -ForegroundColor Green

# 2) Runtime env
$env:DATA_DIR = $DataDir
$env:MCP_CONFIG_PATH = $McpOutPath
$env:ENABLE_MCP = "true"

$env:OLLAMA_BASE_URL = "http://localhost:11434"
$env:OLLAMA_MODELS   = Join-Path $LocalStackDir "ollama\models"

$env:ENABLE_OPENAI_API    = "false"
$env:OPENAI_API_BASE_URL  = ""
$env:OPENAI_API_BASE_URLS = ""
$env:OPENAI_API_KEYS      = ""

$env:RAG_EMBEDDING_ENGINE     = "ollama"
$env:ENABLE_PERSISTENT_CONFIG = "false"
$env:WEBUI_AUTH               = "false"

# 3) Clean start
Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
  Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  Start-Sleep -Seconds 3
}

if (-not (Test-OllamaHealth)) {
  throw "Ollama health check failed at http://localhost:11434/api/tags"
}
Write-Host "Ollama health check OK." -ForegroundColor Green

# 4) Resolve Open WebUI executable
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