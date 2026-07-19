# ==============================================================================
# deploy.ps1 - Hardened local workstation dependency/bootstrap script
# ==============================================================================
[CmdletBinding()]
param(
    [switch]$SkipNodeChecks,
    [switch]$SkipPythonChecks,
    [switch]$SkipOllamaChecks
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$LocalAiDir = Join-Path $RepoRoot "dev\sessions\local-ai"

if (-not (Test-Path $LocalAiDir)) {
    New-Item -ItemType Directory -Path $LocalAiDir -Force | Out-Null
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

Write-DeployLog "Starting hardened deploy preflight checks."
Write-DeployLog ("RepoRoot: " + $RepoRoot)
Write-DeployLog ("LocalAiDir: " + $LocalAiDir)

# ------------------------------------------------------------------------------
# Core command checks
# ------------------------------------------------------------------------------
if (-not $SkipPythonChecks.IsPresent) {
    Assert-CommandAvailable -Name "python" -InstallHint "Install Python 3.10+ and ensure python.exe is on PATH."
    try {
        $pyVersion = & python --version 2>&1
        Write-DeployLog ("python --version => " + $pyVersion)
    }
    catch {
        throw ("Python is present but failed to execute: " + $_.Exception.Message)
    }
}
else {
    Write-DeployLog "Skipping Python checks by request."
}

if (-not $SkipNodeChecks.IsPresent) {
    Assert-CommandAvailable -Name "node" -InstallHint "Install Node.js LTS and ensure node.exe is on PATH."
    Assert-CommandAvailable -Name "npm" -InstallHint "Install npm with Node.js and ensure npm.cmd is on PATH."
    try {
        $nodeVersion = & node --version 2>&1
        $npmVersion = & npm --version 2>&1
        Write-DeployLog ("node --version => " + $nodeVersion)
        Write-DeployLog ("npm --version => " + $npmVersion)
    }
    catch {
        throw ("Node/npm failed version checks: " + $_.Exception.Message)
    }
}
else {
    Write-DeployLog "Skipping Node/npm checks by request."
}

# ------------------------------------------------------------------------------
# MCP command wrappers (expected for launch defaults)
# ------------------------------------------------------------------------------
$appDataNpm = Join-Path $env:APPDATA "npm"
$filesystemMcp = Join-Path $appDataNpm "mcp-server-filesystem.cmd"
$gitMcp = Join-Path $appDataNpm "mcp-server-git.cmd"

if (-not $SkipNodeChecks.IsPresent) {
    if (Test-Path $filesystemMcp) {
        Write-DeployLog ("Verified MCP wrapper: " + $filesystemMcp)
    }
    else {
        Write-DeployLog ("WARNING: Missing MCP wrapper: " + $filesystemMcp)
        Write-DeployLog "Install suggestion: npm i -g @modelcontextprotocol/server-filesystem"
    }

    if (Test-Path $gitMcp) {
        Write-DeployLog ("Verified MCP wrapper: " + $gitMcp)
    }
    else {
        Write-DeployLog ("WARNING: Missing MCP wrapper: " + $gitMcp)
        Write-DeployLog "Install suggestion: npm i -g @modelcontextprotocol/server-git"
    }
}

# ------------------------------------------------------------------------------
# Open WebUI module availability check
# ------------------------------------------------------------------------------
if (-not $SkipPythonChecks.IsPresent) {
    try {
        & python -c "import open_webui; print('open_webui import OK')" 2>&1 | ForEach-Object { Write-DeployLog $_ }
    }
    catch {
        Write-DeployLog "WARNING: open_webui import failed in current python environment."
        Write-DeployLog "Install suggestion: pip install open-webui"
    }
}

# ------------------------------------------------------------------------------
# Ollama checks (runtime + endpoint)
# ------------------------------------------------------------------------------
if (-not $SkipOllamaChecks.IsPresent) {
    if (Test-CommandAvailable -Name "ollama") {
        Write-DeployLog "Verified command: ollama"
    }
    else {
        Write-DeployLog "WARNING: ollama command not found on PATH."
        Write-DeployLog "Install suggestion: install Ollama and ensure ollama.exe is on PATH."
    }

    $ollamaHealth = Test-HttpEndpoint -Url "http://localhost:11434/api/tags" -TimeoutSec 4
    if ($ollamaHealth.ok) {
        Write-DeployLog ("Ollama endpoint reachable: status=" + $ollamaHealth.status)
    }
    else {
        Write-DeployLog ("WARNING: Ollama endpoint not reachable: " + $ollamaHealth.message)
        Write-DeployLog "If expected, start Ollama service before launch."
    }
}
else {
    Write-DeployLog "Skipping Ollama checks by request."
}

# ------------------------------------------------------------------------------
# Optional repo config checks
# ------------------------------------------------------------------------------
$routingPath = Join-Path $RepoRoot "dev\config\open-webui-mcp-routing.json"
if (Test-Path $routingPath) {
    try {
        $raw = Get-Content -Raw -Path $routingPath
        if ([string]::IsNullOrWhiteSpace($raw)) {
            Write-DeployLog ("WARNING: MCP routing file exists but is empty: " + $routingPath)
        }
        else {
            $null = $raw | ConvertFrom-Json
            Write-DeployLog ("Verified MCP routing JSON parse: " + $routingPath)
        }
    }
    catch {
        Write-DeployLog ("WARNING: MCP routing JSON parse failed: " + $_.Exception.Message)
    }
}
else {
    Write-DeployLog ("MCP routing file not found (optional): " + $routingPath)
}

Write-DeployLog "Deploy preflight checks complete."
Write-Host ("[DEPLOY] Completed. Log: " + $DeployLog) -ForegroundColor Green