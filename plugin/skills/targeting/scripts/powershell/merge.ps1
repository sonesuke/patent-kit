param(
    [string]$InputDir = "1-targeting\csv",
    [string]$OutputFile = "1-targeting\target.jsonl"
)

if (-not (Test-Path $InputDir)) {
    Write-Host "Directory not found: $InputDir. Please create it and place CSV files there."
    exit
}

$UniquePatents = @{}
$FileCount = 0

Get-ChildItem -Path $InputDir -Filter "*.csv" | ForEach-Object {
    $FilePath = $_.FullName
    Write-Host "Processing $($_.Name)"
    $FileCount++

    $Lines = Get-Content -Path $FilePath -Encoding UTF8
    
    $CsvStartIndex = 0
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $Line = $Lines[$i].Trim()
        if ($Line -ne "" -and -not $Line.StartsWith("search URL:")) {
            $CsvStartIndex = $i
            break
        }
    }

    if ($CsvStartIndex -lt $Lines.Count) {
        $CsvData = $Lines[$CsvStartIndex..($Lines.Count - 1)] | ConvertFrom-Csv
        
        foreach ($Row in $CsvData) {
            if (-not [string]::IsNullOrWhiteSpace($Row.id)) {
                $UniquePatents[$Row.id] = $Row
            }
        }
    }
}

if ($FileCount -eq 0) {
    Write-Host "No CSV files found in $InputDir"
    exit
}

$OutputDir = Split-Path $OutputFile -Parent
if ($OutputDir -and -not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
}

$OutFileStream = [System.IO.StreamWriter]::new((Resolve-Path -Path ".").ProviderPath + "\" + $OutputFile, $false, [System.Text.Encoding]::UTF8)

foreach ($Record in $UniquePatents.Values) {
    $FilteredRecord = [ordered]@{}
    foreach ($Prop in $Record.PSObject.Properties) {
        $K = $Prop.Name
        $V = $Prop.Value
        if (-not [string]::IsNullOrEmpty($K) -and $K -notmatch 'link' -and $K -ne 'inventor/author') {
            $FilteredRecord[$K] = $V
        }
    }

    if ($FilteredRecord.Contains('id')) {
        $FilteredRecord['id'] = $FilteredRecord['id'] -replace '-', ''
    }

    $Json = $FilteredRecord | ConvertTo-Json -Depth 5 -Compress
    $OutFileStream.WriteLine($Json)
}

$OutFileStream.Close()

$PatentCount = $UniquePatents.Count
Write-Host "Merged $PatentCount unique patents from $FileCount files into $OutputFile"
