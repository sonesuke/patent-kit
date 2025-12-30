# Report detailed progress of the project in JSON format
# Usage: .\report-progress.ps1

# Phase 0
$p0_spec = Test-Path "0-specifications\specification.md"

# Phase 1
$p1_targeting = Test-Path "1-targeting\targeting.md"
$p1_keywords = Test-Path "1-targeting\keywords.md"
$p1_target_jsonl = Test-Path "1-targeting\target.jsonl"
$p1_total_count = 0
if ($p1_target_jsonl) {
    $measures = Get-Content "1-targeting\target.jsonl" -ErrorAction SilentlyContinue | Measure-Object
    $p1_total_count = $measures.Count
}

# Phase 2
$p2_screened_jsonl = Test-Path "2-screening\screened.jsonl"
$p2_screened_count = 0
$p2_relevant = 0
$p2_irrelevant = 0
$p2_expired = 0
$top_10 = @()

if ($p2_screened_jsonl) {
    $content = Get-Content "2-screening\screened.jsonl" -ErrorAction SilentlyContinue
    if ($content) {
        $p2_screened_count = ($content | Measure-Object).Count
        $p2_relevant = ($content | Select-String '"judgment":"relevant"').Count
        $p2_irrelevant = ($content | Select-String '"judgment":"irrelevant"').Count
        $p2_expired = ($content | Select-String '"judgment":"expired"').Count
        
        # Extract Top 10 Relevant
        $relevantRecords = $content | ForEach-Object { $_ | ConvertFrom-Json } | Where-Object { $_.judgment -eq "relevant" }
        $top_10 = $relevantRecords | Select-Object -First 10
    }
}

# Phase 3-5
$investigations = @()
if (Test-Path "3-investigations") {
    $dirs = Get-ChildItem -Path "3-investigations" -Directory
    foreach ($d in $dirs) {
        $id = $d.Name
        $has_eval = Test-Path (Join-Path $d.FullName "evaluation.md")
        
        $claim_path = Join-Path $d.FullName "claim-analysis.md"
        $has_claim = Test-Path $claim_path
        $claim_sim = "None"
        
        if ($has_claim) {
           $claim_content = Get-Content $claim_path -Raw
           if ($claim_content -match "Overall Similarity:.*Significant") { $claim_sim = "Significant" }
           elseif ($claim_content -match "Overall Similarity:.*Moderate") { $claim_sim = "Moderate" }
           elseif ($claim_content -match "Overall Similarity:.*Limited") { $claim_sim = "Limited" }
        }

        $prior_path = Join-Path $d.FullName "prior-art.md"
        $has_prior = Test-Path $prior_path
        $prior_verdict = "None"

        if ($has_prior) {
           $prior_content = Get-Content $prior_path -Raw
           if ($prior_content -match "Verdict:.*Relevant prior art identified") { $prior_verdict = "Relevant" }
           elseif ($prior_content -match "Verdict:.*Alternative implementation selected") { $prior_verdict = "Alternative" }
           elseif ($prior_content -match "Verdict:.*Aligned with existing techniques") { $prior_verdict = "Aligned" }
           elseif ($prior_content -match "Verdict:.*Escalated for legal review") { $prior_verdict = "Escalated" }
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
    phase0 = @{
        specification_md = $p0_spec
    }
    phase1 = @{
        targeting_md = $p1_targeting
        keywords_md = $p1_keywords
        target_jsonl = $p1_target_jsonl
        total_targets = $p1_total_count
    }
    phase2 = @{
        screened_jsonl = $p2_screened_jsonl
        total_screened = $p2_screened_count
        relevant = $p2_relevant
        irrelevant = $p2_irrelevant
        expired = $p2_expired
        top_10_relevant = $top_10
    }
    investigations = $investigations
}

$output | ConvertTo-Json -Depth 4
