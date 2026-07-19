# ==============================================================================
# write-summary.ps1 - Hardened run summary writer
# ==============================================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$RunSummary,
    [Parameter(Mandatory=$true)][string]$ResolvedMcp,
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$LaunchMode,
    [Parameter(Mandatory=$true)][string]$FinalStatus,
    [Parameter(Mandatory=$true)][string]$DiagLog,
    [Parameter(Mandatory=$true)][string]$WebUiOutLog,
    [Parameter(Mandatory=$true)][string]$WebUiErrLog,
    [Parameter(Mandatory=$true)][int]$UnresolvedCount,
    [Parameter(Mandatory=$true)][object[]]$McpValidation,
    [Parameter(Mandatory=$true)][object]$OllamaCheck,
    [Parameter(Mandatory=$true)][object]$WebUiCheck
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# Local AI Launch Run Summary")
$lines.Add("")
$lines.Add("- Timestamp: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
$lines.Add("- Repo root: " + $RepoRoot)
$lines.Add("- Launch mode: " + $LaunchMode)
$lines.Add("- POC status: " + $FinalStatus)
$lines.Add("")
$lines.Add("## Health checks")
$lines.Add("- Ollama: ok=" + $OllamaCheck.ok + ", status=" + $OllamaCheck.status + ", msg=" + $OllamaCheck.message)
$lines.Add("- Open WebUI: ok=" + $WebUiCheck.ok + ", status=" + $WebUiCheck.status + ", msg=" + $WebUiCheck.message)
$lines.Add("")
$lines.Add("## MCP validation")
$lines.Add("- Unresolved MCP commands: " + $UnresolvedCount)

foreach ($row in $McpValidation) {
    $lines.Add("- " + $row.server + ": ok=" + $row.ok + ", check=" + $row.check + ", command=" + $row.command)
}

$lines.Add("")
$lines.Add("## Active files")
$lines.Add("- Diagnostic log: " + $DiagLog)
$lines.Add("- Open WebUI stdout log: " + $WebUiOutLog)
$lines.Add("- Open WebUI stderr log: " + $WebUiErrLog)
$lines.Add("- Run summary: " + $RunSummary)
$lines.Add("- Resolved MCP config: " + $ResolvedMcp)
$lines.Add("")
$lines.Add("## MCP JSON preview")
$lines.Add("```json")

if (Test-Path $ResolvedMcp) {
    $lines.Add((Get-Content -Raw -Path $ResolvedMcp))
} else {
    $lines.Add("{ }")
}

$lines.Add("```")

$lines | Out-File -FilePath $RunSummary -Encoding utf8 -Force