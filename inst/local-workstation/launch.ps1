# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (Native STDIO MCP)
# ==============================================================================
param(
  [switch]$DebugForeground
)

$ErrorActionPreference = "Stop"

$ExecutionDir  = (Get-Location).Path
$ConfigDir     = Join-Path $ExecutionDir "dev\config"
$LogDir        = Join-Path $ExecutionDir "dev\sessions\local-ai"
$LocalStackDir = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
$DataDir       = Join-Path $LocalStackDir "open-webui-data"
$NpmBin        = Join-Path $env:APPDATA "npm"

$BoundsPath    = Join-Path $ConfigDir "workspace-bounds.json"
$RepoMcpPath   = Join-Path $ConfigDir "open-webui-mcp-routing.json"
$McpOutPath    = Join-Path $DataDir "mcp_config.json"

if (-not (Test-Path $LogDir))  { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

$Stamp    = Get-Date -Format "yyyyMMdd-HHmmss"
$DiagLog  = Join-Path $LogDir "launch-diag-$Stamp.log"
$WebUILog = Join-Path $LogDir "open-webui-$Stamp.log"

function Log([string]$m) {
  Add-Content -Path $DiagLog -Value "$(Get-Date -Format o) | $m" -Encoding utf8
}

function Resolve-Token([string]$txt, [string]$workspaceRoot) {
  if ([string]::IsNullOrWhiteSpace($txt)) { return $txt }
  $x = $txt.Replace('${APPDATA}', $env:APPDATA)
  $x = $x.Replace('${USERPROFILE}', $env:USERPROFILE)
  $x = $x.Replace('${WORKSPACE_ROOT}', ($workspaceRoot -replace '\\','/'))
  return $x
}

function Write-Utf8NoBom([string]$path, [string]$content) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $enc)
}

function Get-WorkspaceRoot {
  if (Test-Path $BoundsPath) {
    try {
      $null = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
      return $ExecutionDir
    } catch {
      throw "workspace-bounds.json invalid UTF-8 JSON: $($_.Exception.Message)"
    }
  }
  return (Split-Path -Path $ExecutionDir -Parent)
}

function Wait-Url([string]$url, [int]$seconds = 30) {
  $deadline = (Get-Date).AddSeconds($seconds)
  do {
    try {
      $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { return $true }
    } catch { Start-Sleep -Seconds 1 }
  } while ((Get-Date) -lt $deadline)
  return $false
}

try {
  $workspaceRoot = Get-WorkspaceRoot
  Log "workspaceRoot=$workspaceRoot"

  $cfg = @{
    mcpServers = @{
      local_filesystem = @{
        command = Join-Path $NpmBin "mcp-server-filesystem.cmd"
        args    = @($workspaceRoot -replace '\\','/')
      }
      local_git = @{
        command = Join-Path $NpmBin "mcp-server-git.cmd"
        args    = @()
      }
    }
  }

  if (Test-Path $RepoMcpPath) {
    Log "Applying overrides from $RepoMcpPath"
    $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json -AsHashtable
    if ($repo.ContainsKey("mcpServers")) {
      foreach ($kv in $repo.mcpServers.GetEnumerator()) {
        $cfg.mcpServers[$kv.Key] = $kv.Value
      }
    }
  }

  foreach ($name in @($cfg.mcpServers.Keys)) {
    $s = $cfg.mcpServers[$name]
    if (-not $s.ContainsKey("command")) { throw "MCP server '$name' missing command" }
    $s.command = Resolve-Token $s.command $workspaceRoot

    if (-not $s.ContainsKey("args") -or $null -eq $s.args) {
      $s.args = @()
    } else {
      $resolvedArgs = @()
      foreach ($a in $s.args) { $resolvedArgs += (Resolve-Token ([string]$a) $workspaceRoot) }
      $s.args = $resolvedArgs
    }

    if (-not (Test-Path $s.command)) { throw "MCP command not found for '$name': $($s.command)" }
    $cfg.mcpServers[$name] = $s
    Log "MCP[$name] command=$($s.command)"
  }

  $json = $cfg | ConvertTo-Json -Depth 30
  Write-Utf8NoBom -path $McpOutPath -content $json
  Log "Wrote MCP config: $McpOutPath"

  $env:DATA_DIR = $DataDir
  $env:MCP_CONFIG_PATH = $McpOutPath
  $env:ENABLE_MCP = "true"
  $env:OLLAMA_BASE_URL = "http://localhost:11434"
  $env:OLLAMA_MODELS   = Join-Path $LocalStackDir "ollama\models"
  $env:RAG_EMBEDDING_ENGINE = "ollama"
  $env:ENABLE_OPENAI_API = "false"
  $env:OPENAI_API_BASE_URL = ""
  $env:OPENAI_API_BASE_URLS = ""
  $env:OPENAI_API_KEYS = ""
  $env:ENABLE_PERSISTENT_CONFIG = "false"
  $env:WEBUI_AUTH = "false"

  Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 1

  if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  }

  if (-not (Wait-Url "http://localhost:11434/api/tags" 25)) {
    throw "Ollama not reachable at http://localhost:11434/api/tags"
  }

  $WebUIExe = Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov\Scripts\open-webui.exe"
  if (-not (Test-Path $WebUIExe)) { throw "open-webui.exe not found: $WebUIExe" }

  if ($DebugForeground) {
    Write-Host "[DEBUG] Running Open WebUI in foreground. Ctrl+C to stop." -ForegroundColor Yellow
    Write-Host "[DEBUG] If this errors, copy terminal output from here." -ForegroundColor Yellow
    & $WebUIExe serve
    exit $LASTEXITCODE
  }

  $p = Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
    -RedirectStandardOutput $WebUILog `
    -RedirectStandardError $WebUILog `
    -WindowStyle Hidden `
    -PassThru

  Start-Sleep -Seconds 2
  if ($p.HasExited) {
    $tail = (Get-Content -Path $WebUILog -Tail 80 -ErrorAction SilentlyContinue) -join "`n"
    throw "Open WebUI exited immediately. Log tail:`n$tail"
  }

  if (-not (Wait-Url "http://localhost:8080" 40)) {
    $tail = (Get-Content -Path $WebUILog -Tail 120 -ErrorAction SilentlyContinue) -join "`n"
    throw "Open WebUI not reachable on :8080. Log tail:`n$tail"
  }

  Write-Host "[SUCCESS] Local workstation launched and healthy." -ForegroundColor Green
  Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
  Write-Host "Diag log: $DiagLog" -ForegroundColor Yellow
  Write-Host "WebUI log: $WebUILog" -ForegroundColor Yellow
  Start-Process "http://localhost:8080"
}
catch {
  Write-Host "[FAIL] launch.ps1: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Diag log: $DiagLog" -ForegroundColor Red
  throw
}