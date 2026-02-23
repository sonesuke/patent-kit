# Find next patent to evaluate
# Returns the first relevant patent ID that hasn't been investigated yet
# Usage: .\next-patent.ps1

# Check if screened.jsonl exists
if (-not (Test-Path "2-screening\screened.jsonl")) {
    Write-Error "2-screening\screened.jsonl not found"
    exit 1
}

# Get all relevant patent IDs
$relevantPatents = Get-Content "2-screening\screened.jsonl" | ForEach-Object {
    $record = $_ | ConvertFrom-Json
    if ($record.judgment -eq "relevant") {
        $record.id
    }
}

# Find first one without investigation folder
foreach ($id in $relevantPatents) {
    if (-not (Test-Path "3-investigations\$id")) {
        Write-Output $id
        exit 0
    }
}

Write-Error "No uninvestigated patents found"
exit 1
