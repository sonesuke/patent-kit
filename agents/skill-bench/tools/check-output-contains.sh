#!/bin/bash
# check-output-contains.sh - Check if the agent output contains a specific string
# Usage: check-output-contains.sh <log_file> <work_dir> <search_string>

LOG_FILE="${1:-}"
WORK_DIR="${2:-}"
SEARCH_STRING="${3:-}"

if [ -z "$LOG_FILE" ] || [ -z "$SEARCH_STRING" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <search_string>" >&2
    exit 1
fi

# Check if the output contains the search string
# We look for assistant messages in the log
if grep -q '"type":"assistant"' "$LOG_FILE" && grep -q "content" "$LOG_FILE" && grep -qi "$SEARCH_STRING" "$LOG_FILE"; then
    exit 0
else
    exit 1
fi
