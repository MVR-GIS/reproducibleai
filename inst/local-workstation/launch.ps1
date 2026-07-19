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

$McpOutPathPrimary = Join-Path $DataDir "mcp_config.json"
$McpOutPathAlt     = Join-Path $DataDir "mcp.json"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

$Stamp    = Get-Date -Format "yyyyMMdd-HHmmss"
$WebUILog = Join-Path $LogDir "open-webui-$Stamp.log"
$DiagLog  = Join-Path $LogDir "launch-diag-$Stamp.log"

function Log-Diag([string]$msg) {
  Add-Content -Path $DiagLog -Value "$(Get-Date -Format o) | $msg" -Encoding UTF8
}

function Resolve-TokenString {
  param([string]$Text, [string]$WorkspaceRoot)
  if ([string]::IsNullOrWhiteSpace($Text)) { return $Text }
  $x = $Text.Replace('${APPDATA}', $env:APPDATA)
  $x = $x.Replace('${WORKSPACE_ROOT}', ($WorkspaceRoot -replace '\\','/'))
  $x = $x.Replace('${USERPROFILE}', $env:USERPROFILE)
  return $x
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
}

function Get-WorkspaceRoot {
  param([string]$ExecutionDir, [string]$BoundsPath)
  if (Test-Path $BoundsPath) {
    $obj = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
    return $ExecutionDir
  } else {
    return (Split-Path -Path $ExecutionDir -Parent)
  }
}

function New-DefaultConfig {
  param([string]$WorkspaceRoot, [string]$NpmBin)
  @{
    mcpServers = @{
      local_filesystem = @{
        command = (Join-Path $NpmBin "mcp-server-filesystem.cmd")
        args    = @($WorkspaceRoot -replace '\\','/')
        enabled = $true
      }
      local_git = @{
        command = (Join-Path $NpmBin "mcp-server-git.cmd")
        args    = @()
        enabled = $true
      }
    }
  }
}

function Merge-RepoConfig {
  param([hashtable]$Cfg, [string]$RepoMcpPath)
  if (-not (Test-Path $RepoMcpPath)) { return $Cfg }

  $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json -AsHashtable
  if (-not $repo.ContainsKey("mcpServers")) {
    throw "Repo MCP config missing top-level mcpServers: $RepoMcpPath"
  }

  foreach ($kv in $repo.mcpServers.GetEnumerator()) {
    $Cfg.mcpServers[$kv.Key] = $kv.Value
  }

  return $Cfg
}

function Normalize-And-Validate {
  param([hashtable]$Cfg, [string]$WorkspaceRoot)

  foreach ($name in @($Cfg.mcpServers.Keys)) {
    $s = $Cfg.mcpServers[$name]

    if (-not $s.ContainsKey("enabled")) { $s["enabled"] = $true }
    if ($s["enabled"] -eq $false) { continue }

    if (-not $s.ContainsKey("command")) {
      throw "Enabled MCP server '$name' missing command."
    }

    $s["command"] = Resolve-TokenString -Text ([string]$s["command"]) -WorkspaceRoot $WorkspaceRoot

    if (-not $s.ContainsKey("args") -or $null -eq $s["args"]) {
      $s["args"] = @()
    } else {
      $resolved = @()
      foreach ($a in $s["args"]) {
        $resolved += (Resolve-TokenString -Text ([string]$a) -WorkspaceRoot $WorkspaceRoot)
      }
      $s["args"] = $resolved
    }

    if (-not (Test-Path $s["command"])) {
      throw "Enabled MCP server '$name' command not found: $($s["command"])"
    }

    $Cfg.mcpServers[$name] = $s
    Log-Diag "MCP[$name] command=$($s["command"]) args=$([string]::Join(',', $s["args"]))"
  }

  return $Cfg
}

function Wait-Ollama([int]$MaxSeconds = 25) {
  $deadline = (Get-Date).AddSeconds($MaxSeconds)
  do {
    try {
      Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 3 | Out-Null
      return $true
    } catch {
      Start-Sleep -Seconds 1
    }
  } while ((Get-Date) -lt $deadline)
  return $false
}

try {
  $WorkspaceRoot = Get-WorkspaceRoot -ExecutionDir $ExecutionDir -BoundsPath $BoundsPath
  Log-Diag "WorkspaceRoot=$WorkspaceRoot"

  $cfg = New-DefaultConfig -WorkspaceRoot $WorkspaceRoot -NpmBin $NpmBin
  $cfg = Merge-RepoConfig -Cfg $cfg -RepoMcpPath $RepoMcpPath
  $cfg = Normalize-And-Validate -Cfg $cfg -WorkspaceRoot $WorkspaceRoot

  $json = $cfg | ConvertTo-Json -Depth 50
  Write-Utf8NoBom -Path $McpOutPathPrimary -Content $json
  Write-Utf8NoBom -Path $McpOutPathAlt -Content $json

  # Runtime env
  $env:DATA_DIR = $DataDir

  # Set multiple MCP env vars for compatibility across Open WebUI variants
  $env:MCP_CONFIG_PATH = $McpOutPathPrimary
  $env:MCP_CONFIG_FILE = $McpOutPathPrimary
  $env:OPEN_WEBUI_MCP_CONFIG_PATH = $McpOutPathPrimary
  $env:OPENWEBUI_MCP_CONFIG_PATH = $McpOutPathPrimary

  $env:ENABLE_MCP = "true"
  $env:OLLAMA_BASE_URL = "http://localhost:11434"
  $env:OLLAMA_MODELS   = Join-Path $LocalStackDir "ollama\models"

  $env:ENABLE_OPENAI_API = "false"
  $env:OPENAI_API_BASE_URL = ""
  $env:OPENAI_API_BASE_URLS = ""
  $env:OPENAI_API_KEYS = ""

  $env:RAG_EMBEDDING_ENGINE = "ollama"
  $env:ENABLE_PERSISTENT_CONFIG = "false"
  $env:WEBUI_AUTH = "false"

  Log-Diag "MCP env vars set:"
  Log-Diag "  MCP_CONFIG_PATH=$env:MCP_CONFIG_PATH"
  Log-Diag "  MCP_CONFIG_FILE=$env:MCP_CONFIG_FILE"
  Log-Diag "  OPEN_WEBUI_MCP_CONFIG_PATH=$env:OPEN_WEBUI_MCP_CONFIG_PATH"
  Log-Diag "  OPENWEBUI_MCP_CONFIG_PATH=$env:OPENWEBUI_MCP_CONFIG_PATH"

  # Clean restart
  Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1

  if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  }

  if (-not (Wait-Ollama -MaxSeconds 25)) {
    throw "Ollama health check failed at http://localhost:11434/api/tags"
  }

  $WebUIExe = Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"
  if (-not (Test-Path $WebUIExe)) { throw "Open WebUI executable not found: $WebUIExe" }

  Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
    -RedirectStandardOutput $WebUILog `
    -RedirectStandardError $WebUILog `
    -WindowStyle Hidden

  Write-Host "[SUCCESS] Local workstation launched." -ForegroundColor Green
  Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
  Write-Host "WebUI log: $WebUILog" -ForegroundColor Yellow
  Write-Host "Diag log: $DiagLog" -ForegroundColor Yellow
  Start-Process "http://localhost:8080"
}
catch {
  Write-Host "[FAIL] launch.ps1: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Diag log: $DiagLog" -ForegroundColor Red
  throw
}