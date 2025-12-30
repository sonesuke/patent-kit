# Fetch patent data using google-patent-cli
# Usage: .\fetch-patent.ps1 <PATENT_ID>

param([string]$PatentId)
if (-not (Test-Path "2-screening\json")) {
    New-Item -ItemType Directory -Force -Path "2-screening\json" | Out-Null
}
.\.patent-kit\bin\google-patent-cli.exe fetch $PatentId > "2-screening\json\$PatentId.json" 2>&1
