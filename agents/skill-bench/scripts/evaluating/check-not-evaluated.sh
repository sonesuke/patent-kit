#!/bin/bash
# Check if the patent was NOT already evaluated (should select next unevaluated one)

PATENT_ID="$1"

if [ -z "$PATENT_ID" ]; then
    echo "FAIL: Patent ID not provided"
    exit 1
fi

# Check if evaluation directory does NOT exist for this patent
if [ ! -d "3-investigations/$PATENT_ID" ]; then
    echo "PASS: Patent $PATENT_ID is not yet evaluated (correctly selected as next to evaluate)"
    exit 0
else
    echo "FAIL: Patent $PATENT_ID appears to already have an evaluation directory"
    exit 1
fi
