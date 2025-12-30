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
        
        $inf_path = Join-Path $d.FullName "infringement.md"
        $has_inf = Test-Path $inf_path
        $inf_risk = "None"
        
        if ($has_inf) {
           $inf_content = Get-Content $inf_path -Raw
           if ($inf_content -match "Overall Risk:.*High") { $inf_risk = "High" }
           elseif ($inf_content -match "Overall Risk:.*Medium") { $inf_risk = "Medium" }
           elseif ($inf_content -match "Overall Risk:.*Low") { $inf_risk = "Low" }
           # Fallback
           elseif ($inf_content -match "High Risk") { $inf_risk = "High" }
           elseif ($inf_content -match "Medium Risk") { $inf_risk = "Medium" }
           elseif ($inf_content -match "Low Risk") { $inf_risk = "Low" }
        }

        $prior_path = Join-Path $d.FullName "prior.md"
        $has_prior = Test-Path $prior_path
        $prior_risk = "None"

        if ($has_prior) {
           $prior_content = Get-Content $prior_path -Raw
           if ($prior_content -match "Overall Risk:.*High") { $prior_risk = "High" }
           elseif ($prior_content -match "Overall Risk:.*Medium") { $prior_risk = "Medium" }
           elseif ($prior_content -match "Overall Risk:.*Low") { $prior_risk = "Low" }
           # Fallback
           elseif ($prior_content -match "High Risk") { $prior_risk = "High" }
           elseif ($prior_content -match "Medium Risk") { $prior_risk = "Medium" }
           elseif ($prior_content -match "Low Risk") { $prior_risk = "Low" }
        }
        
        $investigations += @{
            id = $id
            evaluation = $has_eval
            infringement = $has_inf
            inf_risk = $inf_risk
            prior = $has_prior
            prior_risk = $prior_risk
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
