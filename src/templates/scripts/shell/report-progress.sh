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
        
        # Infringement risks
        inf_risk="None"
        if [ -f "$dir/infringement.md" ]; then
            has_inf="true"
            if grep -E -i -q "Overall Risk:.*High" "$dir/infringement.md"; then
                inf_risk="High"
            elif grep -E -i -q "Overall Risk:.*Medium" "$dir/infringement.md"; then
                inf_risk="Medium"
            elif grep -E -i -q "Overall Risk:.*Low" "$dir/infringement.md"; then
                inf_risk="Low"
            # Fallback
            elif grep -i -q "High Risk" "$dir/infringement.md"; then
                inf_risk="High"
            elif grep -i -q "Medium Risk" "$dir/infringement.md"; then
                inf_risk="Medium"
            elif grep -i -q "Low Risk" "$dir/infringement.md"; then
                inf_risk="Low"
            fi
        fi

        # Prior Art risks
        prior_risk="None"
        # Prior Art risks
        prior_risk="None"
        if [ -f "$dir/prior.md" ]; then
            has_prior="true"
            if grep -E -i -q "Overall Risk:.*High" "$dir/prior.md"; then
                prior_risk="High"
            elif grep -E -i -q "Overall Risk:.*Medium" "$dir/prior.md"; then
                prior_risk="Medium"
            elif grep -E -i -q "Overall Risk:.*Low" "$dir/prior.md"; then
                prior_risk="Low"
            # Fallback
            elif grep -i -q "High Risk" "$dir/prior.md"; then
                prior_risk="High"
            elif grep -i -q "Medium Risk" "$dir/prior.md"; then
                prior_risk="Medium"
            elif grep -i -q "Low Risk" "$dir/prior.md"; then
                prior_risk="Low"
            fi
        fi
        
        if [ "$first" = true ]; then
            first=false
        else
            investigations="$investigations,"
        fi
        
        investigations="$investigations {\"id\":\"$id\", \"evaluation\":$has_eval, \"infringement\":$has_inf, \"inf_risk\":\"$inf_risk\", \"prior\":$has_prior, \"prior_risk\":\"$prior_risk\"}"
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
