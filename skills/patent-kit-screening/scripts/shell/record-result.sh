#!/bin/bash
# Record screening result to screened.jsonl
# Usage: ./record-result.sh <ID> <TITLE> <LEGAL_STATUS> <JUDGMENT> <REASON> <ABSTRACT>

ID=$1
TITLE=$2
LEGAL_STATUS=$3
JUDGMENT=$4
REASON=$5
ABSTRACT=$6

# Escape double quotes in strings
escape_json() {
    echo "$1" | sed 's/"/\\"/g' | tr -d '\n'
}

ESCAPED_TITLE=$(escape_json "$TITLE")
ESCAPED_REASON=$(escape_json "$REASON")
ESCAPED_ABSTRACT=$(escape_json "$ABSTRACT")

echo "{\"id\":\"$ID\",\"title\":\"$ESCAPED_TITLE\",\"legal_status\":\"$LEGAL_STATUS\",\"judgment\":\"$JUDGMENT\",\"reason\":\"$ESCAPED_REASON\",\"abstract_text\":\"$ESCAPED_ABSTRACT\"}" >> 2-screening/screened.jsonl
