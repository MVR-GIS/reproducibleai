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

$summaryLines = @()
$summaryLines += "# Local AI Launch Run Summary"
$summaryLines += ""
$summaryLines += ("- Timestamp: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
$summaryLines += ("- Repo root: " + $RepoRoot)
$summaryLines += ("- Launch mode: " + $LaunchMode)
$summaryLines += ("- POC status: " + $FinalStatus)
$summaryLines += ""
$summaryLines += "## Health checks"
$summaryLines += ("- Ollama: ok=" + $OllamaCheck.ok + ", status=" + $OllamaCheck.status + ", msg=" + $OllamaCheck.message)
$summaryLines += ("- Open WebUI: ok=" + $WebUiCheck.ok + ", status=" + $WebUiCheck.status + ", msg=" + $WebUiCheck.message)
$summaryLines += ""
$summaryLines += "## MCP validation"
$summaryLines += ("- Unresolved MCP commands: " + $UnresolvedCount)

foreach ($row in $McpValidation) {
    $summaryLines += ("- " + $row.server + ": ok=" + $row.ok + ", check=" + $row.check + ", command=" + $row.command)
}

$summaryLines += ""
$summaryLines += "## Active files"
$summaryLines += ("- Diagnostic log: " + $DiagLog)
$summaryLines += ("- Open WebUI stdout log: " + $WebUiOutLog)
$summaryLines += ("- Open WebUI stderr log: " + $WebUiErrLog)
$summaryLines += ("- Run summary: " + $RunSummary)
$summaryLines += ("- Resolved MCP config: " + $ResolvedMcp)
$summaryLines += ""
$summaryLines += "## MCP JSON preview"
$summaryLines += "```json"

if (Test-Path $ResolvedMcp) {
    $summaryLines += (Get-Content -Raw -Path $ResolvedMcp)
} else {
    $summaryLines += "{ }"
}

$summaryLines += "```"

$summaryLines | Out-File -FilePath $RunSummary -Encoding utf8 -Force