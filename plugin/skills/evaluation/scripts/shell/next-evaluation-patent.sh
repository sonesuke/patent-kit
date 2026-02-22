#!/bin/bash
# Find next patent to evaluate
# Returns the first relevant patent ID that hasn't been investigated yet
# Usage: ./next-patent.sh

# Check if screened.jsonl exists
if [ ! -f "2-screening/screened.jsonl" ]; then
    echo "Error: 2-screening/screened.jsonl not found" >&2
    exit 1
fi

# Get all relevant patent IDs
relevant_ids=$(jq -r 'select(.judgment == "relevant") | .id' 2-screening/screened.jsonl)

# Find first one without investigation folder
for id in $relevant_ids; do
    if [ ! -d "3-investigations/$id" ]; then
        echo "$id"
        exit 0
    fi
done

echo "No uninvestigated patents found" >&2
exit 1
