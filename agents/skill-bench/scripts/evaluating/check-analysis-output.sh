#!/bin/bash
# Check if analysis output contains expected keywords

if [ ! -f logs/evaluating/functional-analyze-patents.log ]; then
    echo "FAIL: Log file not found"
    exit 1
fi

LOG_FILE="logs/evaluating/functional-analyze-patents.log"

# Check for keywords indicating analysis was performed
KEYWORDS=("claim" "element" "constituent" "decompose" "analyze")

for keyword in "${KEYWORDS[@]}"; do
    if grep -qi "$keyword" "$LOG_FILE"; then
        echo "PASS: Found analysis keyword '$keyword' in output"
        exit 0
    fi
done

echo "FAIL: No analysis keywords found in output"
exit 1
