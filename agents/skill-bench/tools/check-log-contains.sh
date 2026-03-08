#!/bin/bash
# Check if log file contains a specific pattern
# Usage: check-log-contains.sh <log_file> <pattern>

LOG_FILE="$1"
PATTERN="$2"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found: $LOG_FILE"
    exit 1
fi

if grep -q "$PATTERN" "$LOG_FILE"; then
    exit 0
else
    exit 1
fi
