# Find next patent for claim analysis
# Returns the first patent ID in 3-investigations that doesn't have claim-analysis.md yet
# Usage: .\next-claim-analysis-patent.ps1

# Check if 3-investigations exists
if (-not (Test-Path "3-investigations")) {
    Write-Error "3-investigations folder not found"
    exit 1
}

# Find first patent folder without claim-analysis.md
$patentDirs = Get-ChildItem -Path "3-investigations" -Directory
foreach ($dir in $patentDirs) {
    $patentId = $dir.Name
    $evaluationPath = Join-Path $dir.FullName "evaluation.md"
    $claimPath = Join-Path $dir.FullName "claim-analysis.md"
    
    if ((Test-Path $evaluationPath) -and (-not (Test-Path $claimPath))) {
        Write-Output $patentId
        exit 0
    }
}

Write-Error "No patents pending claim analysis"
exit 1
