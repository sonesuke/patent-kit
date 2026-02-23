#!/bin/bash
# Find next patent for claim analysis
# Returns the first patent ID in 3-investigations that doesn't have claim-analysis.md yet
# Usage: ./next-claim-analysis-patent.sh

# Check if 3-investigations exists
if [ ! -d "3-investigations" ]; then
    echo "Error: 3-investigations folder not found" >&2
    exit 1
fi

# Find first patent folder without claim-analysis.md
for dir in 3-investigations/*/; do
    patent_id=$(basename "$dir")
    if [ -f "$dir/evaluation.md" ] && [ ! -f "$dir/claim-analysis.md" ]; then
        echo "$patent_id"
        exit 0
    fi
done

echo "No patents pending claim analysis" >&2
exit 1
