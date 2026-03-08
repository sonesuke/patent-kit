#!/bin/bash
# check-file-content.sh - Check if a workspace file contains specific content
# Usage: check-file-content.sh <log_file> <work_dir> <filename> <search_string>

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
    # File doesn't exist - failure
    exit 1
fi

# Check if the file contains the search string
if grep -q "$SEARCH_STRING" "$FILE_PATH"; then
    # File contains the string - success
    exit 0
else
    # File doesn't contain the string - failure
    exit 1
fi
