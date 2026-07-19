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

function Get-WorkspaceScope {
  param([string]$ExecutionDir, [string]$BoundsPath)
  if (Test-Path $BoundsPath) {
    $obj = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
    return @{ Path = $ExecutionDir; Mode = "REPO-ISOLATED (Project: $($obj.project_name))" }
  } else {
    $parent = Split-Path -Path $ExecutionDir -Parent
    return @{ Path = $parent; Mode = "MULTI-REPO WORKSPACE (Directory: $parent)" }
  }
}

function New-DefaultMcpConfig {
  param([string]$WorkspaceRoot, [string]$NpmBin)
  [pscustomobject]@{
    mcpServers = [pscustomobject]@{
      local_filesystem = [pscustomobject]@{
        command = (Join-Path $NpmBin "mcp-server-filesystem.cmd")
        args    = @($WorkspaceRoot -replace '\\','/')
        enabled = $true
      }
      local_git = [pscustomobject]@{
        command = (Join-Path $NpmBin "mcp-server-git.cmd")
        args    = @()
        enabled = $true
      }
    }
  }
}

function Normalize-McpConfig {
  param([psobject]$ConfigObj, [string]$WorkspaceRoot)

  if (-not $ConfigObj.mcpServers) { throw "MCP config missing top-level 'mcpServers'." }

  foreach ($p in $ConfigObj.mcpServers.PSObject.Properties) {
    $name = $p.Name
    $s = $p.Value

    if ($null -eq $s.enabled) { $s | Add-Member -NotePropertyName enabled -NotePropertyValue $true -Force }
    if ($s.enabled -eq $false) { continue }

    if (-not $s.command) { throw "Enabled MCP server '$name' missing required 'command'." }
    $s.command = Resolve-TokenString -Text ([string]$s.command) -WorkspaceRoot $WorkspaceRoot

    if ($null -eq $s.args) {
      $s | Add-Member -NotePropertyName args -NotePropertyValue @() -Force
    } else {
      $resolvedArgs = @()
      foreach ($a in $s.args) { $resolvedArgs += (Resolve-TokenString -Text ([string]$a -as [string]) -WorkspaceRoot $WorkspaceRoot) }
      $s.args = $resolvedArgs
    }

    $ConfigObj.mcpServers.$name = $s
    Log-Diag "MCP[$name] command=$($s.command)"
  }

  return $ConfigObj
}

function Assert-McpCommandsExist {
  param([psobject]$ConfigObj)
  foreach ($p in $ConfigObj.mcpServers.PSObject.Properties) {
    $name = $p.Name
    $s = $p.Value
    if ($s.enabled -eq $false) { continue }
    if (-not (Test-Path $s.command)) {
      throw "Enabled MCP server '$name' command not found: $($s.command)"
    }
  }
}

function Write-Utf8NoBom([string]$Path, [string]$Content) {
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
  $scope = Get-WorkspaceScope -ExecutionDir $ExecutionDir -BoundsPath $BoundsPath
  $TargetScopePath = $scope.Path
  Write-Host "Operating Mode: $($scope.Mode)" -ForegroundColor Yellow

  $cfg = New-DefaultMcpConfig -WorkspaceRoot $TargetScopePath -NpmBin $NpmBin
  if (Test-Path $RepoMcpPath) {
    $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json
    if (-not $repo.mcpServers) { throw "Repo MCP config missing 'mcpServers': $RepoMcpPath" }
    foreach ($p in $repo.mcpServers.PSObject.Properties) {
      $cfg.mcpServers | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
    }
  }

  $cfg = Normalize-McpConfig -ConfigObj $cfg -WorkspaceRoot $TargetScopePath
  Assert-McpCommandsExist -ConfigObj $cfg

  $json = $cfg | ConvertTo-Json -Depth 30
  Write-Utf8NoBom -Path $McpOutPath -Content $json
  Log-Diag "Resolved MCP config path: $McpOutPath"
  Log-Diag "Resolved MCP config content: $json"

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

  Log-Diag "ENV MCP_CONFIG_PATH=$env:MCP_CONFIG_PATH"
  Log-Diag "ENV ENABLE_MCP=$env:ENABLE_MCP"
  Log-Diag "ENV DATA_DIR=$env:DATA_DIR"

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