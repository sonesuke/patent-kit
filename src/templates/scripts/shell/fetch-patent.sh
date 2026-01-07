#!/bin/bash
# Fetch patent data using google-patent-cli
# Usage: ./fetch-patent.sh <PATENT_ID>

PATENT_ID=$1
SCREENING_FILE="2-screening/json/${PATENT_ID}.json"

if [ -f "$SCREENING_FILE" ]; then
    echo "Reusing existing data for ${PATENT_ID}"
    exit 0
fi

mkdir -p "2-screening/json"
./.patent-kit/bin/google-patent-cli fetch "$PATENT_ID" > "$SCREENING_FILE" 2>&1
