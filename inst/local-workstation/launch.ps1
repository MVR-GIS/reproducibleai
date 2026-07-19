# ==============================================================================
# LAUNCH.PS1: Local AI Workspace Orchestrator (POC-fast MCP bring-up)
# ==============================================================================
param(
  [switch]$DebugForeground
)

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------------------------
# Paths (anchored to repo root)
# ------------------------------------------------------------------------------
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
$PythonExe     = Join-Path $CondaEnvRoot "python.exe"
$WebUIExe      = Join-Path $CondaEnvRoot "Scripts\open-webui.exe"

if (-not (Test-Path $LogDir))  { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
if (-not (Test-Path $DataDir)) { New-Item -ItemType Directory -Force -Path $DataDir | Out-Null }

# Latest-only logs
$DiagLog    = Join-Path $LogDir "latest-launch-diag.log"
$WebUILog   = Join-Path $LogDir "latest-open-webui.log"
$RunSummary = Join-Path $LogDir "latest-run-summary.md"

function Reset-File([string]$Path) {
  if (Test-Path $Path) { Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue }
  New-Item -ItemType File -Path $Path -Force | Out-Null
}

Reset-File $DiagLog
Reset-File $WebUILog

function Log([string]$m) {
  Add-Content -Path $DiagLog -Value "$(Get-Date -Format o) | $m" -Encoding utf8
}

function Write-Utf8NoBom([string]$path, [string]$content) {
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $enc)
}

function Resolve-Token([string]$txt, [string]$workspaceRoot) {
  if ([string]::IsNullOrWhiteSpace($txt)) { return $txt }
  $x = $txt.Replace('${APPDATA}', $env:APPDATA)
  $x = $x.Replace('${USERPROFILE}', $env:USERPROFILE)
  $x = $x.Replace('${WORKSPACE_ROOT}', ($workspaceRoot -replace '\\','/'))
  return $x
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

function Get-WorkspaceRoot {
  if (Test-Path $BoundsPath) {
    try {
      $bounds = (Get-Content -Raw -Path $BoundsPath -Encoding UTF8) | ConvertFrom-Json
      Log "Workspace mode=REPO-ISOLATED project_name=$($bounds.project_name)"
      return $ExecutionDir
    } catch {
      throw "workspace-bounds.json invalid JSON: $($_.Exception.Message)"
    }
  }
  $parent = Split-Path -Path $ExecutionDir -Parent
  Log "Workspace mode=MULTI-REPO root=$parent"
  return $parent
}

function Test-CommandResolvable([string]$CommandText) {
  if ([string]::IsNullOrWhiteSpace($CommandText)) { return $false }

  $looksLikePath =
    $CommandText.Contains('\') -or
    $CommandText.Contains('/') -or
    $CommandText.Contains(':') -or
    $CommandText.EndsWith(".cmd") -or
    $CommandText.EndsWith(".exe") -or
    $CommandText.EndsWith(".bat") -or
    $CommandText.EndsWith(".ps1")

  if ($looksLikePath) { return (Test-Path $CommandText) }
  return ($null -ne (Get-Command $CommandText -ErrorAction SilentlyContinue))
}

function Build-McpConfig([string]$workspaceRoot) {
  $servers = @{}

  # Defaults
  $servers["local_filesystem"] = @{
    command = Join-Path $NpmBin "mcp-server-filesystem.cmd"
    args    = @($workspaceRoot -replace '\\','/')
  }
  $servers["local_git"] = @{
    command = Join-Path $NpmBin "mcp-server-git.cmd"
    args    = @()
  }

  # Optional repo overrides (no -AsHashtable)
  if (Test-Path $RepoMcpPath) {
    Log "Applying MCP overrides from $RepoMcpPath"
    $repo = (Get-Content -Raw -Path $RepoMcpPath -Encoding UTF8) | ConvertFrom-Json
    if (-not $repo.mcpServers) {
      throw "Repo MCP config missing top-level 'mcpServers': $RepoMcpPath"
    }

    foreach ($prop in $repo.mcpServers.PSObject.Properties) {
      $servers[$prop.Name] = @{
        command = [string]$prop.Value.command
        args    = @($prop.Value.args)
      }
    }
  } else {
    Log "No repo MCP override file found. Using default MCP servers."
  }

  # Normalize + validate
  foreach ($name in @($servers.Keys)) {
    $s = $servers[$name]
    if ([string]::IsNullOrWhiteSpace($s.command)) {
      throw "MCP server '$name' missing command."
    }

    $s.command = Resolve-Token $s.command $workspaceRoot
    $resolvedArgs = @()
    foreach ($a in @($s.args)) {
      $resolvedArgs += (Resolve-Token ([string]$a) $workspaceRoot)
    }
    $s.args = $resolvedArgs

    if (-not (Test-CommandResolvable $s.command)) {
      throw "MCP command not resolvable for '$name': $($s.command)"
    }

    $servers[$name] = $s
    Log "MCP[$name] command=$($s.command) args=$([string]::Join(',', $s.args))"
  }

  return @{ mcpServers = $servers }
}

function Write-RunSummary([string]$Status, [string]$Message, [string]$McpJsonPreview) {
  $content = @"
# Local AI Run Summary (POC)

- Timestamp: $(Get-Date -Format o)
- Status: $Status
- Message: $Message

## Proof points captured
- MCP config generated at: $McpOutPath
- Launch diag log: $DiagLog
- Open WebUI log: $WebUILog
- Open WebUI URL: http://localhost:8080
- Ollama URL: http://localhost:11434

## MCP JSON preview
```json
$McpJsonPreview