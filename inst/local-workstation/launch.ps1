# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (Native STDIO MCP)
# ==============================================================================
param(
  [switch]$DebugForeground
)

$ErrorActionPreference = "Stop"

# Anchor to repo root regardless of current working directory
$ExecutionDir = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ExecutionDir = $ExecutionDir.Path

$ConfigDir     = Join-Path $ExecutionDir "dev\config"
$LogDir        = Join-Path $ExecutionDir "dev\sessions\local-ai"
$LocalStackDir = Join-Path $env:USERPROFILE "AppData\Local\LocalAIStack"
$DataDir       = Join-Path $LocalStackDir "open-webui-data"
$NpmBin        = Join-Path $env:APPDATA "npm"

$BoundsPath    = Join-Path $ConfigDir "workspace-bounds.json"
$RepoMcpPath   = Join-Path $ConfigDir "open-webui-mcp-routing.json"
$McpOutPath    = Join-Path $DataDir "mcp_config.json"

$CondaEnvRoot  = Join-Path $env:USERPROFILE "AppData\Local\miniforge3\envs\open-webui-gov"
$WebUIExe      = Join-Path $CondaEnvRoot "Scripts\open-webui.exe"
$PythonExe     = Join-Path $CondaEnvRoot "python.exe"

if (-not (Test-Path $LogDir))  { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

$Stamp             = Get-Date -Format "yyyyMMdd-HHmmss"
$DiagLog           = Join-Path $LogDir "launch-diag-$Stamp.log"
$WebUILog          = Join-Path $LogDir "open-webui-$Stamp.log"
$RunSummary        = Join-Path $LogDir "run-summary-$Stamp.md"
$LatestRunSummary  = Join-Path $LogDir "latest-run-summary.md"

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
      $bounds = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
      Log "Workspace mode: REPO-ISOLATED project_name=$($bounds.project_name)"
      return $ExecutionDir
    } catch {
      throw "workspace-bounds.json invalid UTF-8 JSON: $($_.Exception.Message)"
    }
  }

  $parent = Split-Path -Path $ExecutionDir -Parent
  Log "Workspace mode: MULTI-REPO root=$parent"
  return $parent
}

function Wait-Url([string]$url, [int]$seconds = 30) {
  $deadline = (Get-Date).AddSeconds($seconds)
  do {
    try {
      $r = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
      if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { return $true }
    } catch {
      Start-Sleep -Seconds 1
    }
  } while ((Get-Date) -lt $deadline)
  return $false
}

function Get-TcpListenerPid([int]$Port) {
  try {
    $c = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction Stop | Select-Object -First 1
    if ($null -ne $c) { return [int]$c.OwningProcess }
  } catch {}
  return $null
}

function Assert-PortFree([int]$Port, [string]$Name) {
  $pid = Get-TcpListenerPid -Port $Port
  if ($null -ne $pid) {
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    $pname = if ($proc) { $proc.ProcessName } else { "unknown" }
    throw "$Name port $Port already in use by PID=$pid ($pname)."
  }
}

function Stop-StaleWebUIProcesses {
  param([string]$PythonPath)

  Log "Stopping stale Open WebUI processes..."

  # Stop open-webui.exe wrappers
  Get-Process -Name "open-webui" -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      Stop-Process -Id $_.Id -Force -ErrorAction Stop
      Log "Stopped process open-webui PID=$($_.Id)"
    } catch {
      Log "Failed stopping open-webui PID=$($_.Id): $($_.Exception.Message)"
    }
  }

  # Stop python processes running open_webui from target env
  $pyDir = [System.IO.Path]::GetDirectoryName($PythonPath).ToLowerInvariant()
  $candidates = Get-CimInstance Win32_Process -Filter "Name='python.exe'" -ErrorAction SilentlyContinue
  foreach ($p in $candidates) {
    $cmd = [string]$p.CommandLine
    if ([string]::IsNullOrWhiteSpace($cmd)) { continue }
    $cmdLower = $cmd.ToLowerInvariant()

    $isTargetEnvPython = $cmdLower.Contains($pyDir)
    $isOpenWebUI = $cmdLower.Contains("open_webui") -or $cmdLower.Contains("open-webui")

    if ($isTargetEnvPython -and $isOpenWebUI) {
      try {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction Stop
        Log "Stopped python OpenWebUI PID=$($p.ProcessId) CMD=$cmd"
      } catch {
        Log "Failed stopping python PID=$($p.ProcessId): $($_.Exception.Message)"
      }
    }
  }

  Start-Sleep -Seconds 1
}

function Test-CommandResolvable {
  param([string]$CommandText)

  if ([string]::IsNullOrWhiteSpace($CommandText)) { return $false }

  # If looks like path, use Test-Path
  $looksLikePath =
    $CommandText.Contains('\') -or
    $CommandText.Contains('/') -or
    $CommandText.Contains(':') -or
    $CommandText.EndsWith(".cmd") -or
    $CommandText.EndsWith(".exe") -or
    $CommandText.EndsWith(".bat") -or
    $CommandText.EndsWith(".ps1")

  if ($looksLikePath) {
    return (Test-Path $CommandText)
  }

  # Otherwise resolve via PATH
  $resolved = Get-Command $CommandText -ErrorAction SilentlyContinue
  return ($null -ne $resolved)
}

function Build-McpConfig([string]$workspaceRoot) {
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
    Log "Applying MCP overrides from $RepoMcpPath"
    try {
      $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json -AsHashtable
    } catch {
      throw "open-webui-mcp-routing.json invalid UTF-8 JSON: $($_.Exception.Message)"
    }

    if ($repo.ContainsKey("mcpServers")) {
      foreach ($kv in $repo.mcpServers.GetEnumerator()) {
        $cfg.mcpServers[$kv.Key] = $kv.Value
      }
    } else {
      throw "Repo MCP config missing top-level 'mcpServers': $RepoMcpPath"
    }
  } else {
    Log "No repo MCP override file found. Using defaults."
  }

  foreach ($name in @($cfg.mcpServers.Keys)) {
    $s = $cfg.mcpServers[$name]
    if (-not $s.ContainsKey("command")) { throw "MCP server '$name' missing command." }

    $s.command = Resolve-Token $s.command $workspaceRoot

    if (-not $s.ContainsKey("args") -or $null -eq $s.args) {
      $s.args = @()
    } else {
      $resolvedArgs = @()
      foreach ($a in $s.args) {
        $resolvedArgs += (Resolve-Token ([string]$a) $workspaceRoot)
      }
      $s.args = $resolvedArgs
    }

    if (-not (Test-CommandResolvable -CommandText ([string]$s.command))) {
      throw "MCP command not resolvable for '$name': $($s.command)"
    }

    $cfg.mcpServers[$name] = $s
    Log "MCP[$name] command=$($s.command) args=$([string]::Join(',', $s.args))"
  }

  return $cfg
}

function Write-RunSummary {
  param(
    [string]$Status,
    [string]$Message
  )

  $content = @"
# Local AI Run Summary

- Timestamp: $(Get-Date -Format o)
- Status: $Status
- Message: $Message

## Paths
- Diag Log: $DiagLog
- WebUI Log: $WebUILog
- MCP Config: $McpOutPath
- Data Dir: $DataDir

## Endpoints
- Open WebUI: http://localhost:8080
- Ollama: http://localhost:11434
"@

  Write-Utf8NoBom -path $RunSummary -content $content
  Write-Utf8NoBom -path $LatestRunSummary -content $content
}

try {
  Log "ExecutionDir=$ExecutionDir"
  Log "ConfigDir=$ConfigDir"
  Log "DataDir=$DataDir"

  $workspaceRoot = Get-WorkspaceRoot
  Log "workspaceRoot=$workspaceRoot"

  $cfg  = Build-McpConfig -workspaceRoot $workspaceRoot
  $json = $cfg | ConvertTo-Json -Depth 30
  Write-Utf8NoBom -path $McpOutPath -content $json
  Log "Wrote MCP config: $McpOutPath"

  # Runtime environment
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

  Log "ENV DATA_DIR=$env:DATA_DIR"
  Log "ENV MCP_CONFIG_PATH=$env:MCP_CONFIG_PATH"
  Log "ENV ENABLE_MCP=$env:ENABLE_MCP"

  Stop-StaleWebUIProcesses -PythonPath $PythonExe

  # Ensure target ports are free before launch
  Assert-PortFree -Port 8080 -Name "Open WebUI"
  # port 11434 may already be in use by valid ollama service

  # Ensure Ollama
  if (-not (Get-Process "ollama" -ErrorAction SilentlyContinue)) {
    Log "Starting ollama serve..."
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
  }

  if (-not (Wait-Url "http://localhost:11434/api/tags" 25)) {
    throw "Ollama not reachable at http://localhost:11434/api/tags"
  }
  Log "Ollama reachable."

  if (-not (Test-Path $PythonExe)) {
    throw "python.exe not found in env: $PythonExe"
  }

  if ($DebugForeground) {
    Write-Host "[DEBUG] Launching foreground: python -m open_webui serve" -ForegroundColor Yellow
    & $PythonExe -m open_webui serve
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0) {
      Write-RunSummary -Status "SUCCESS" -Message "Foreground run exited cleanly."
    } else {
      Write-RunSummary -Status "FAIL" -Message "Foreground run exited with code $exitCode."
    }
    exit $exitCode
  }

  # Prefer python module launch
  Log "Launching Open WebUI via python -m open_webui serve"
  $p = Start-Process -FilePath $PythonExe -ArgumentList "-m open_webui serve" `
    -RedirectStandardOutput $WebUILog `
    -RedirectStandardError $WebUILog `
    -WindowStyle Hidden `
    -PassThru

  Start-Sleep -Seconds 3
  if ($p.HasExited) {
    Log "python module launch exited quickly. Trying open-webui.exe fallback."
    if (-not (Test-Path $WebUIExe)) {
      $tail = (Get-Content -Path $WebUILog -Tail 120 -ErrorAction SilentlyContinue) -join "`n"
      throw "python launch exited immediately and open-webui.exe not found at: $WebUIExe`nLog tail:`n$tail"
    }

    $p = Start-Process -FilePath $WebUIExe -ArgumentList "serve" `
      -RedirectStandardOutput $WebUILog `
      -RedirectStandardError $WebUILog `
      -WindowStyle Hidden `
      -PassThru

    Start-Sleep -Seconds 2
    if ($p.HasExited) {
      $tail = (Get-Content -Path $WebUILog -Tail 120 -ErrorAction SilentlyContinue) -join "`n"
      throw "Both launch methods exited immediately. Log tail:`n$tail"
    }
  }

  if (-not (Wait-Url "http://localhost:8080" 45)) {
    $tail = (Get-Content -Path $WebUILog -Tail 150 -ErrorAction SilentlyContinue) -join "`n"
    throw "Open WebUI not reachable on :8080. Log tail:`n$tail"
  }

  $portPid = Get-TcpListenerPid -Port 8080
  if ($null -eq $portPid) {
    throw "Open WebUI responded but no listener PID found on port 8080."
  }
  Log "Port 8080 listener PID=$portPid; launched PID=$($p.Id)"

  Log "Open WebUI reachable on :8080"
  Write-RunSummary -Status "SUCCESS" -Message "Open WebUI reachable and launch checks passed."

  Write-Host "[SUCCESS] Local workstation launched and healthy." -ForegroundColor Green
  Write-Host "Open WebUI: http://localhost:8080" -ForegroundColor Yellow
  Write-Host "Diag log: $DiagLog" -ForegroundColor Yellow
  Write-Host "WebUI log: $WebUILog" -ForegroundColor Yellow
  Write-Host "Run summary: $RunSummary" -ForegroundColor Yellow
  Start-Process "http://localhost:8080"
}
catch {
  $err = $_.Exception.Message
  Log "FAIL: $err"
  Write-RunSummary -Status "FAIL" -Message $err

  Write-Host "[FAIL] launch.ps1: $err" -ForegroundColor Red
  Write-Host "Diag log: $DiagLog" -ForegroundColor Red
  Write-Host "Run summary: $RunSummary" -ForegroundColor Red
  throw
}