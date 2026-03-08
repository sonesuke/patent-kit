#!/bin/bash
# Report detailed progress of the project in JSON format
# Usage: ./report-progress.sh

# Concept Interviewing
concept_spec="false"
[ -f "specification.md" ] && concept_spec="true"

# Targeting
targeting="false"
keywords="false"

[ -f "targeting.md" ] && targeting="true"
[ -f "keywords.md" ] && keywords="true"

# Screening (use database statistics)
# The screening progress is tracked in patents.db

# Evaluations & Investigations
investigations="[]"
if [ -d "investigations" ]; then
    # Start JSON array
    investigations="["
    first=true
    for dir in investigations/*/; do
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
  "concept_interviewing": {
    "specification_md": $concept_spec
  },
  "targeting": {
    "targeting_md": $targeting,
    "keywords_md": $keywords
  },
  "screening": {
    "tracked_in_database": true
  },
  "investigations": $investigations
}
EOF
