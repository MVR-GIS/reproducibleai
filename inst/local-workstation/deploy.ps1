# ==============================================================================
# deploy.ps1 - Bare-metal local AI workstation preflight/bootstrap
# Target stack: Positron + Continue + Ollama + MCP server array
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$SkipNodeChecks,
    [switch]$SkipOllamaChecks,
    [switch]$InstallMcpServers,
    [string]$TargetModel = "qwen2.5-coder:32b-instruct",
    [switch]$AutoPullModel
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$LocalAiDir = Join-Path $RepoRoot "dev\sessions\local-ai"
$ConfigDir = Join-Path $RepoRoot "dev\config"

if (-not (Test-Path $LocalAiDir)) {
    New-Item -ItemType Directory -Path $LocalAiDir -Force | Out-Null
}
if (-not (Test-Path $ConfigDir)) {
    New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
}

$DeployLog = Join-Path $LocalAiDir "latest-deploy-diag.log"
if (Test-Path $DeployLog) {
    Remove-Item -Path $DeployLog -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType File -Path $DeployLog -Force | Out-Null

function Write-DeployLog {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -Path $DeployLog -Value $line
    Write-Host $Message
}

function Test-CommandAvailable {
    param([Parameter(Mandatory=$true)][string]$Name)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

function Assert-CommandAvailable {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$InstallHint
    )
    if (-not (Test-CommandAvailable -Name $Name)) {
        throw ("Required command not found: " + $Name + ". " + $InstallHint)
    }
    Write-DeployLog ("Verified command: " + $Name)
}

function Test-HttpEndpoint {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [int]$TimeoutSec = 4
    )
    try {
        $resp = Invoke-WebRequest -Uri $Url -Method GET -UseBasicParsing -TimeoutSec $TimeoutSec
        return [pscustomobject]@{
            ok = $true
            status = $resp.StatusCode
            message = "OK"
        }
    }
    catch {
        return [pscustomobject]@{
            ok = $false
            status = ""
            message = $_.Exception.Message
        }
    }
}

function Test-ModelPresent {
    param([Parameter(Mandatory=$true)][string]$ModelName)
    try {
        $list = & ollama list 2>&1
        $joined = ($list -join "`n")
        return ($joined -match [regex]::Escape($ModelName))
    }
    catch {
        return $false
    }
}

Write-DeployLog "Starting bare-metal deploy preflight checks."
Write-DeployLog ("RepoRoot: " + $RepoRoot)
Write-DeployLog ("LocalAiDir: " + $LocalAiDir)
Write-DeployLog ("TargetModel: " + $TargetModel)

# ------------------------------------------------------------------------------
# Node/npm + MCP wrappers
# ------------------------------------------------------------------------------
if (-not $SkipNodeChecks.IsPresent) {
    Assert-CommandAvailable -Name "node" -InstallHint "Install Node.js LTS and ensure node.exe is on PATH."
    Assert-CommandAvailable -Name "npm" -InstallHint "Install npm with Node.js and ensure npm.cmd is on PATH."

    $nodeVersion = & node --version 2>&1
    $npmVersion = & npm --version 2>&1
    Write-DeployLog ("node --version => " + $nodeVersion)
    Write-DeployLog ("npm --version => " + $npmVersion)

    if ($InstallMcpServers.IsPresent) {
        Write-DeployLog "Installing MCP servers globally via npm..."
        & npm i -g @modelcontextprotocol/server-filesystem @modelcontextprotocol/server-git 2>&1 | ForEach-Object { Write-DeployLog $_ }
    }

    $appDataNpm = Join-Path $env:APPDATA "npm"
    $filesystemMcp = Join-Path $appDataNpm "mcp-server-filesystem.cmd"
    $gitMcp = Join-Path $appDataNpm "mcp-server-git.cmd"

    if (Test-Path $filesystemMcp) {
        Write-DeployLog ("Verified MCP wrapper: " + $filesystemMcp)
    } else {
        Write-DeployLog ("WARNING: Missing MCP wrapper: " + $filesystemMcp)
        Write-DeployLog "Install suggestion: npm i -g @modelcontextprotocol/server-filesystem"
    }

    if (Test-Path $gitMcp) {
        Write-DeployLog ("Verified MCP wrapper: " + $gitMcp)
    } else {
        Write-DeployLog ("WARNING: Missing MCP wrapper: " + $gitMcp)
        Write-DeployLog "Install suggestion: npm i -g @modelcontextprotocol/server-git"
    }
}
else {
    Write-DeployLog "Skipping Node/npm checks by request."
}

# ------------------------------------------------------------------------------
# Ollama runtime + model checks
# ------------------------------------------------------------------------------
if (-not $SkipOllamaChecks.IsPresent) {
    if (Test-CommandAvailable -Name "ollama") {
        Write-DeployLog "Verified command: ollama"
    } else {
        Write-DeployLog "WARNING: ollama command not found on PATH."
        Write-DeployLog "Install suggestion: install Ollama and ensure ollama.exe is on PATH."
    }

    $ollamaHealth = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 4
    if ($ollamaHealth.ok) {
        Write-DeployLog ("Ollama endpoint reachable: status=" + $ollamaHealth.status)
    } else {
        Write-DeployLog ("WARNING: Ollama endpoint not reachable: " + $ollamaHealth.message)
        Write-DeployLog "If expected, start Ollama service before launch."
    }

    $modelPresent = $false
    if (Test-CommandAvailable -Name "ollama") {
        $modelPresent = Test-ModelPresent -ModelName $TargetModel
    }

    if ($modelPresent) {
        Write-DeployLog ("Verified model present: " + $TargetModel)
    } else {
        Write-DeployLog ("WARNING: Model not found locally: " + $TargetModel)
        if ($AutoPullModel.IsPresent -and (Test-CommandAvailable -Name "ollama")) {
            Write-DeployLog ("AutoPullModel enabled. Pulling: " + $TargetModel)
            & ollama pull $TargetModel 2>&1 | ForEach-Object { Write-DeployLog $_ }
        } else {
            Write-DeployLog ("Pull suggestion: ollama pull " + $TargetModel)
        }
    }
}
else {
    Write-DeployLog "Skipping Ollama checks by request."
}

# ------------------------------------------------------------------------------
# Repo config checks (Continue-first, legacy fallback noted)
# ------------------------------------------------------------------------------
$continueRouting = Join-Path $ConfigDir "continue-mcp-routing.json"
$legacyRouting = Join-Path $ConfigDir "open-webui-mcp-routing.json"

if (Test-Path $continueRouting) {
    try {
        $raw = Get-Content -Raw -Path $continueRouting
        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-DeployLog ("WARNING: continue-mcp-routing.json exists but is empty: " + $continueRouting)
        } else {
            $null = $raw | ConvertFrom-Json
            Write-DeployLog ("Verified Continue MCP routing JSON parse: " + $continueRouting)
        }
    } catch {
        Write-DeployLog ("WARNING: Continue MCP routing JSON parse failed: " + $_.Exception.Message)
    }
} else {
    Write-DeployLog ("Continue MCP routing file not found (optional): " + $continueRouting)
}

if (Test-Path $legacyRouting) {
    Write-DeployLog ("Legacy routing file detected (fallback-compatible): " + $legacyRouting)
}

Write-DeployLog "POC readiness summary:"
Write-DeployLog "- Bare-metal runtime target: Positron + Continue + Ollama + MCP"
Write-DeployLog "- Deploy script completed; use launch.ps1 to generate resolved MCP config and runtime validation artifacts."
Write-Host ("[DEPLOY] Completed. Log: " + $DeployLog) -ForegroundColor Green