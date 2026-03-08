#!/bin/bash
# check-file-not-contains.sh - Check if a workspace file does NOT contain specific content
# Usage: check-file-not-contains.sh <log_file> <work_dir> <filename> <search_string>

LOG_FILE="${1:-}"
WORK_DIR="${2:-}"
FILENAME="${3:-}"
SEARCH_STRING="${4:-}"

if [ -z "$LOG_FILE" ] || [ -z "$WORK_DIR" ] || [ -z "$FILENAME" ] || [ -z "$SEARCH_STRING" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <filename> <search_string>" >&2
    exit 1
fi

# Check if the file exists in the workspace
FILE_PATH="$WORK_DIR/$FILENAME"

if [ ! -f "$FILE_PATH" ]; then
    # File doesn't exist - treat as not containing (success for this check)
    exit 0
fi

# Check if the file does NOT contain the search string
if grep -q "$SEARCH_STRING" "$FILE_PATH"; then
    # File contains the string - failure (we expect it NOT to)
    exit 1
else
    # File doesn't contain the string - success
    exit 0
fi
