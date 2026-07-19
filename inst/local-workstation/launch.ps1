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

function Get-WorkspaceRoot {
  param([string]$ExecutionDir, [string]$BoundsPath)
  if (Test-Path $BoundsPath) {
    try {
      $obj = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
      Log-Diag "Mode=REPO-ISOLATED project_name=$($obj.project_name)"
      return $ExecutionDir
    } catch {
      throw "Failed parsing workspace-bounds.json as UTF-8 JSON: $($_.Exception.Message)"
    }
  } else {
    $parent = Split-Path -Path $ExecutionDir -Parent
    Log-Diag "Mode=MULTI-REPO root=$parent"
    return $parent
  }
}

function New-ServerObj {
  param(
    [string]$Command,
    [array]$Args,
    [bool]$Enabled = $true
  )
  # Return deterministic plain hashtable shape for JSON stability
  return @{
    command = $Command
    args    = @($Args)
    enabled = $Enabled
  }
}

function Build-BaseConfig {
  param([string]$WorkspaceRoot, [string]$NpmBin)
  $fs = Join-Path $NpmBin "mcp-server-filesystem.cmd"
  $git = Join-Path $NpmBin "mcp-server-git.cmd"

  return @{
    mcpServers = @{
      local_filesystem = New-ServerObj -Command $fs -Args @($WorkspaceRoot -replace '\\','/') -Enabled $true
      local_git        = New-ServerObj -Command $git -Args @() -Enabled $true
    }
  }
}

function Merge-RepoOverrides {
  param([hashtable]$BaseConfig, [string]$RepoMcpPath)

  if (-not (Test-Path $RepoMcpPath)) {
    Log-Diag "No repo MCP override file found."
    return $BaseConfig
  }

  try {
    $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json -AsHashtable
  } catch {
    throw "Failed parsing open-webui-mcp-routing.json as UTF-8 JSON: $($_.Exception.Message)"
  }

  if (-not $repo.ContainsKey("mcpServers")) {
    throw "Repo MCP override exists but missing top-level 'mcpServers'."
  }

  foreach ($kv in $repo.mcpServers.GetEnumerator()) {
    $BaseConfig.mcpServers[$kv.Key] = $kv.Value
    Log-Diag "Override applied for server: $($kv.Key)"
  }

  return $BaseConfig
}

function Normalize-Config {
  param([hashtable]$Cfg, [string]$WorkspaceRoot)

  foreach ($name in @($Cfg.mcpServers.Keys)) {
    $s = $Cfg.mcpServers[$name]

    if (-not $s.ContainsKey("enabled")) { $s["enabled"] = $true }
    if ($s["enabled"] -eq $false) { $Cfg.mcpServers[$name] = $s; continue }

    if (-not $s.ContainsKey("command")) {
      throw "Enabled server '$name' missing command."
    }

    $s["command"] = Resolve-TokenString -Text ([string]$s["command"]) -WorkspaceRoot $WorkspaceRoot

    if (-not $s.ContainsKey("args") -or $null -eq $s["args"]) {
      $s["args"] = @()
    } else {
      $resolvedArgs = @()
      foreach ($a in $s["args"]) {
        $resolvedArgs += (Resolve-TokenString -Text ([string]$a) -WorkspaceRoot $WorkspaceRoot)
      }
      $s["args"] = $resolvedArgs
    }

    $Cfg.mcpServers[$name] = $s
    Log-Diag "Normalized server '$name' command=$($s["command"])"
  }

  return $Cfg
}

function Validate-ServerCommands {
  param([hashtable]$Cfg)
  foreach ($name in @($Cfg.mcpServers.Keys)) {
    $s = $Cfg.mcpServers[$name]
    if ($s["enabled"] -eq $false) { continue }
    if (-not (Test-Path $s["command"])) {
      throw "Enabled server '$name' command not found: $($s["command"])"
    }
  }
}

function Write-Utf8NoBom {
  param([string]$Path, [string]$Content)
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $enc)
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

  $cfg = Build-BaseConfig -WorkspaceRoot $WorkspaceRoot -NpmBin $NpmBin
  $cfg = Merge-RepoOverrides -BaseConfig $cfg -RepoMcpPath $RepoMcpPath
  $cfg = Normalize-Config -Cfg $cfg -WorkspaceRoot $WorkspaceRoot
  Validate-ServerCommands -Cfg $cfg

  $json = $cfg | ConvertTo-Json -Depth 50 -Compress:$false
  Write-Utf8NoBom -Path $McpOutPath -Content $json
  Log-Diag "Wrote resolved MCP config to $McpOutPath"
  Log-Diag "MCP JSON: $json"

  $env:DATA_DIR = $DataDir
  $env:MCP_CONFIG_PATH = $McpOutPath
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