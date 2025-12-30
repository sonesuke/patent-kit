# Record screening result to screened.jsonl
# Usage: .\record-result.ps1 <ID> <TITLE> <LEGAL_STATUS> <JUDGMENT> <REASON> <ABSTRACT>

param(
    [Parameter(Position=0)][string]$Id,
    [Parameter(Position=1)][string]$Title,
    [Parameter(Position=2)][string]$LegalStatus,
    [Parameter(Position=3)][string]$Judgment,
    [Parameter(Position=4)][string]$Reason,
    [Parameter(Position=5)][string]$Abstract
)

# Escape double quotes in strings
function Escape-Json([string]$text) {
    return $text -replace '"', '\"'
}

$escapedTitle = Escape-Json $Title
$escapedReason = Escape-Json $Reason
$escapedAbstract = Escape-Json $Abstract

$json = "{`"id`":`"$Id`",`"title`":`"$escapedTitle`",`"legal_status`":`"$LegalStatus`",`"judgment`":`"$Judgment`",`"reason`":`"$escapedReason`",`"abstract_text`":`"$escapedAbstract`"}"
Add-Content -Path "2-screening\screened.jsonl" -Value $json -Encoding UTF8
