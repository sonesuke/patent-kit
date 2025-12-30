#!/bin/bash
# Find next patent for infringement analysis
# Returns the first patent ID in 3-investigations that doesn't have infringement.md yet
# Usage: ./next-infringement-patent.sh

# Check if 3-investigations exists
if [ ! -d "3-investigations" ]; then
    echo "Error: 3-investigations folder not found" >&2
    exit 1
fi

# Find first patent folder without infringement.md
for dir in 3-investigations/*/; do
    patent_id=$(basename "$dir")
    if [ -f "$dir/evaluation.md" ] && [ ! -f "$dir/infringement.md" ]; then
        echo "$patent_id"
        exit 0
    fi
done

echo "No patents pending infringement analysis" >&2
exit 1
