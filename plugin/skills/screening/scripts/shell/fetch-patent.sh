#!/bin/bash
# Fetch patent data using MCP tool
# Usage: ./fetch-patent.sh <PATENT_ID>

PATENT_ID=$1
mkdir -p "2-screening/json"
./.patent-kit/bin/fetch_patent "$PATENT_ID" > "2-screening/json/${PATENT_ID}.json" 2>&1
