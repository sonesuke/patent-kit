#!/bin/bash
# Report detailed progress of the project in JSON format
# Usage: ./report-progress.sh

# Phase 0
p0_spec="false"
[ -f "0-specifications/specification.md" ] && p0_spec="true"

# Phase 1
p1_targeting="false"
p1_keywords="false"
p1_target_jsonl="false"
p1_total_count=0

[ -f "1-targeting/targeting.md" ] && p1_targeting="true"
[ -f "1-targeting/keywords.md" ] && p1_keywords="true"
if [ -f "1-targeting/target.jsonl" ]; then
    p1_target_jsonl="true"
    p1_total_count=$(wc -l < "1-targeting/target.jsonl" | tr -d ' ')
fi

# Phase 2
p2_screened_jsonl="false"
p2_screened_count=0
p2_relevant=0
p2_irrelevant=0
p2_expired=0
top_10="[]"

if [ -f "2-screening/screened.jsonl" ]; then
    p2_screened_jsonl="true"
    p2_screened_count=$(wc -l < "2-screening/screened.jsonl" | tr -d ' ')
    p2_relevant=$(grep -c '"judgment":"relevant"' "2-screening/screened.jsonl")
    p2_irrelevant=$(grep -c '"judgment":"irrelevant"' "2-screening/screened.jsonl")
    p2_expired=$(grep -c '"judgment":"expired"' "2-screening/screened.jsonl")
    
    # Extract Top 10
    relevant_lines=$(grep '"judgment":"relevant"' "2-screening/screened.jsonl" | head -n 10)
    if [ -n "$relevant_lines" ]; then
        top_10=$(echo "$relevant_lines" | jq -s '.')
    fi
fi

# Phase 3-5
investigations="[]"
if [ -d "3-investigations" ]; then
    # Start JSON array
    investigations="["
    first=true
    for dir in 3-investigations/*/; do
        [ -d "$dir" ] || continue
        id=$(basename "$dir")
        
        has_eval="false"
        has_inf="false"
        has_prior="false"
        
        [ -f "$dir/evaluation.md" ] && has_eval="true"
        
        # Claim Analysis similarity
        claim_analysis_sim="None"
        has_claim_analysis="false"
        if [ -f "$dir/claim-analysis.md" ]; then
            has_claim_analysis="true"
            if grep -E -i -q "^### Overall Similarity:.*Significant" "$dir/claim-analysis.md"; then
                claim_analysis_sim="Significant"
            elif grep -E -i -q "^### Overall Similarity:.*Moderate" "$dir/claim-analysis.md"; then
                claim_analysis_sim="Moderate"
            elif grep -E -i -q "^### Overall Similarity:.*Limited" "$dir/claim-analysis.md"; then
                claim_analysis_sim="Limited"
            fi
        fi

        # Prior Art Verdict
        prior_verdict="None"
        if [ -f "$dir/prior-art.md" ]; then
            has_prior="true"
            if grep -E -i -q "^- \*\*Verdict\*\*:.*Relevant prior art identified" "$dir/prior-art.md"; then
                prior_verdict="Relevant"
            elif grep -E -i -q "^- \*\*Verdict\*\*:.*Alternative implementation selected" "$dir/prior-art.md"; then
                prior_verdict="Alternative"
            elif grep -E -i -q "^- \*\*Verdict\*\*:.*Aligned with existing techniques" "$dir/prior-art.md"; then
                prior_verdict="Aligned"
            elif grep -E -i -q "^- \*\*Verdict\*\*:.*Escalated for legal review" "$dir/prior-art.md"; then
                prior_verdict="Escalated"
            fi
        fi
        
        if [ "$first" = true ]; then
            first=false
        else
            investigations="$investigations,"
        fi
        
        investigations="$investigations {\"id\":\"$id\", \"evaluation\":$has_eval, \"claim_analysis\":$has_claim_analysis, \"claim_analysis_sim\":\"$claim_analysis_sim\", \"prior\":$has_prior, \"prior_verdict\":\"$prior_verdict\"}"
    done
    investigations="$investigations]"
fi

# Construct final JSON
cat <<EOF
{
  "phase0": {
    "specification_md": $p0_spec
  },
  "phase1": {
    "targeting_md": $p1_targeting,
    "keywords_md": $p1_keywords,
    "target_jsonl": $p1_target_jsonl,
    "total_targets": $p1_total_count
  },
  "phase2": {
    "screened_jsonl": $p2_screened_jsonl,
    "total_screened": $p2_screened_count,
    "relevant": $p2_relevant,
    "irrelevant": $p2_irrelevant,
    "expired": $p2_expired,
    "top_10_relevant": $top_10
  },
  "investigations": $investigations
}
EOF
