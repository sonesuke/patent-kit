#!/bin/bash
# Check if text content contains specific patterns
# Usage: check-text-contains.sh <log_file> <work_dir> <pattern1> [pattern2] ...
#   log_file: Path to the log file
#   work_dir: Path to the workspace directory
#   pattern: Text pattern to search for (can specify multiple)

LOG_FILE="$1"
WORK_DIR="$2"
shift 2
PATTERNS=("$@")

if [ -z "$LOG_FILE" ] || [ ${#PATTERNS[@]} -eq 0 ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <pattern1> [pattern2] ..." >&2
    exit 1
fi

# Build jq expression to check if any pattern is found
JQ_EXPR="[.[] | select(.type == \"assistant\" or .type == \"result\")] | any(.message.content[]?; select(type == \"text\" and ("

FIRST=true
for PATTERN in "${PATTERNS[@]}"; do
    if [ "$FIRST" = true ]; then
        JQ_EXPR="$JQ_EXPR (.text | test(\"$PATTERN\"; \"i\"))"
        FIRST=false
    else
        JQ_EXPR="$JQ_EXPR or (.text | test(\"$PATTERN\"; \"i\"))"
    fi
done

JQ_EXPR="$JQ_EXPR)))]"

jq -s "$JQ_EXPR" "$LOG_FILE"
