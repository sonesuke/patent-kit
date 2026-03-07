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

# Check if any pattern is found in assistant text content
FOUND=false
for PATTERN in "${PATTERNS[@]}"; do
    if grep -q "\"text\":\"[^\"]*$PATTERN[^\"]*\"" "$LOG_FILE" 2>/dev/null; then
        FOUND=true
        break
    fi
done

if [ "$FOUND" = "true" ]; then
    exit 0
else
    exit 1
fi
