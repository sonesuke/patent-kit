#!/bin/bash
# Check if the correct patent was selected

EXPECTED_PATENT_ID="$1"

if [ -z "$EXPECTED_PATENT_ID" ]; then
    echo "FAIL: Expected patent ID not provided"
    exit 1
fi

if [ ! -f logs/evaluating/functional-select-patent-id.log ]; then
    echo "FAIL: Log file not found"
    exit 1
fi

LOG_FILE="logs/evaluating/functional-select-patent-id.log"

# Check if the expected patent ID is mentioned in the log
if grep -q "$EXPECTED_PATENT_ID" "$LOG_FILE"; then
    echo "PASS: Patent $EXPECTED_PATENT_ID was selected"
    exit 0
else
    echo "FAIL: Patent $EXPECTED_PATENT_ID not found in output"
    echo "Expected to find: $EXPECTED_PATENT_ID"
    exit 1
fi
