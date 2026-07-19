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
  $line = "$(Get-Date -Format o) | $msg"
  Add-Content -Path $DiagLog -Value $line -Encoding UTF8
  Write-Host $msg -ForegroundColor DarkGray
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
    try {
      $raw = Get-Content -Raw -Path $BoundsPath -Encoding UTF8
      $obj = $raw | ConvertFrom-Json
      return @{ Path = $ExecutionDir; Mode = "REPO-ISOLATED (Project: $($obj.project_name))" }
    } catch {
      throw "workspace-bounds.json exists but failed to parse as UTF-8 JSON: $BoundsPath`n$($_.Exception.Message)"
    }
  } else {
    $parent = Split-Path -Path $ExecutionDir -Parent
    return @{ Path = $parent; Mode = "MULTI-REPO WORKSPACE (Directory: $parent)" }
  }
}

function New-DefaultMcpServers {
  param([string]$WorkspaceRoot, [string]$NpmBin)
  @{
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

function Normalize-McpConfig {
  param([psobject]$ConfigObj, [string]$WorkspaceRoot)

  if (-not $ConfigObj.mcpServers) { throw "MCP config missing top-level 'mcpServers'." }

  foreach ($p in $ConfigObj.mcpServers.PSObject.Properties) {
    $name = $p.Name
    $s = $p.Value

    if (-not $s.command) { throw "MCP server '$name' missing required 'command'." }

    $s.command = Resolve-TokenString -Text ([string]$s.command) -WorkspaceRoot $WorkspaceRoot

    if ($s.args) {
      $resolved = @()
      foreach ($a in $s.args) {
        $resolved += (Resolve-TokenString -Text ([string]$a) -WorkspaceRoot $WorkspaceRoot)
      }
      $s.args = $resolved
    } else {
      $s.args = @()
    }

    if ($null -eq $s.enabled) { $s | Add-Member -NotePropertyName enabled -NotePropertyValue $true }
    $ConfigObj.mcpServers.$name = $s

    Log-Diag "MCP server '$name' => command='$($s.command)' enabled=$($s.enabled)"
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

function Wait-Ollama([int]$MaxSeconds = 20) {
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
  Log-Diag "ExecutionDir=$ExecutionDir"
  Log-Diag "RepoMcpPath=$RepoMcpPath"
  Log-Diag "BoundsPath=$BoundsPath"
  Log-Diag "DataDir=$DataDir"

  $scope = Get-WorkspaceScope -ExecutionDir $ExecutionDir -BoundsPath $BoundsPath
  $TargetScopePath = $scope.Path
  Write-Host "Operating Mode: $($scope.Mode)" -ForegroundColor Yellow
  Log-Diag "TargetScopePath=$TargetScopePath"

  $base = [pscustomobject]@{ mcpServers = (New-DefaultMcpServers -WorkspaceRoot $TargetScopePath -NpmBin $NpmBin) }

  if (Test-Path $RepoMcpPath) {
    Log-Diag "Applying repo MCP overrides..."
    try {
      $repoObj = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json
    } catch {
      throw "open-webui-mcp-routing.json failed to parse as UTF-8 JSON: $RepoMcpPath`n$($_.Exception.Message)"
    }

    if (-not $repoObj.mcpServers) {
      throw "Repo MCP config missing 'mcpServers': $RepoMcpPath"
    }

    foreach ($p in $repoObj.mcpServers.PSObject.Properties) {
      $base.mcpServers | Add-Member -NotePropertyName $p.Name -NotePropertyValue $p.Value -Force
      Log-Diag "Override server loaded: $($p.Name)"
    }
  } else {
    Log-Diag "No repo MCP override found; using defaults."
  }

  $final = Normalize-McpConfig -ConfigObj $base -WorkspaceRoot $TargetScopePath
  Assert-McpCommandsExist -ConfigObj $final

  $json = $final | ConvertTo-Json -Depth 20
  Write-Utf8NoBom -Path $McpOutPath -Content $json
  Log-Diag "Resolved MCP config written to $McpOutPath"

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
    Log-Diag "Starting ollama serve..."
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  }

  if (-not (Wait-Ollama -MaxSeconds 25)) {
    throw "Ollama health check failed after timeout at http://localhost:11434/api/tags"
  }
  Log-Diag "Ollama health check passed."

  $WebUICandidates = @(
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"),
    (Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui")
  )
  $WebUIExe = $WebUICandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $WebUIExe) {
    throw "Open WebUI executable not found in env 'open-webui-gov'. Tried: $($WebUICandidates -join '; ')"
  }
  Log-Diag "WebUIExe=$WebUIExe"

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
  Write-Host "[FAIL] launch.ps1 error: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Diagnostic log: $DiagLog" -ForegroundColor Red
  throw
}