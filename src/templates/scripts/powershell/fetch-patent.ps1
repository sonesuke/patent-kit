# Fetch patent data using google-patent-cli
# Usage: .\fetch-patent.ps1 <PATENT_ID>

param([string]$PatentId)
$ScreeningFile = "2-screening\json\$PatentId.json"

if (Test-Path $ScreeningFile) {
    Write-Host "Reusing existing data for $PatentId"
    exit 0
}

if (-not (Test-Path "2-screening\json")) {
    New-Item -ItemType Directory -Force -Path "2-screening\json" | Out-Null
}
.\.patent-kit\bin\google-patent-cli.exe fetch $PatentId > $ScreeningFile 2>&1
