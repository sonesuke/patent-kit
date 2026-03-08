# Report detailed progress of the project in JSON format
# Usage: .\report-progress.ps1

# Concept Interviewing
$concept_spec = Test-Path "specification.md"

# Targeting
$targeting = Test-Path "targeting.md"
$keywords = Test-Path "keywords.md"

# Screening (use database statistics)
# The screening progress is tracked in patents.db

# Evaluations & Investigations
$investigations = @()
if (Test-Path "investigations") {
    $dirs = Get-ChildItem -Path "investigations" -Directory
    foreach ($d in $dirs) {
        $id = $d.Name
        $has_eval = Test-Path (Join-Path $d.FullName "evaluation.md")
        
        $claim_path = Join-Path $d.FullName "claim-analysis.md"
        $has_claim = Test-Path $claim_path
        $claim_sim = "None"
        
        if ($has_claim) {
           $claim_content = Get-Content $claim_path -Raw
           if ($claim_content -match "^### Overall Similarity:.*Significant") { $claim_sim = "Significant" }
           elseif ($claim_content -match "^### Overall Similarity:.*Moderate") { $claim_sim = "Moderate" }
           elseif ($claim_content -match "^### Overall Similarity:.*Limited") { $claim_sim = "Limited" }
        }

        $prior_path = Join-Path $d.FullName "prior-art.md"
        $has_prior = Test-Path $prior_path
        $prior_verdict = "None"

        if ($has_prior) {
           $prior_content = Get-Content $prior_path -Raw
           if ($prior_content -match "^- \*\*Verdict\*\*:.*Relevant prior art identified") { $prior_verdict = "Relevant" }
           elseif ($prior_content -match "^- \*\*Verdict\*\*:.*Alternative implementation selected") { $prior_verdict = "Alternative" }
           elseif ($prior_content -match "^- \*\*Verdict\*\*:.*Aligned with existing techniques") { $prior_verdict = "Aligned" }
           elseif ($prior_content -match "^- \*\*Verdict\*\*:.*Escalated for legal review") { $prior_verdict = "Escalated" }
        }
        
        $investigations += @{
            id = $id
            evaluation = $has_eval
            claim_analysis = $has_claim
            claim_analysis_sim = $claim_sim
            prior = $has_prior
            prior_verdict = $prior_verdict
        }
    }
}

$output = @{
    concept_interviewing = @{
        specification_md = $concept_spec
    }
    targeting = @{
        targeting_md = $targeting
        keywords_md = $keywords
    }
    screening = @{
        tracked_in_database = $true
    }
    investigations = $investigations
}

$output | ConvertTo-Json -Depth 4
