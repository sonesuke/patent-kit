#!/usr/bin/env bash
# Check database query result
# Usage: check-db-query.sh <log_file> <work_dir> <expected_result> <query>
# Note: query comes last to avoid issues with special characters

LOG_FILE="$1"
WORK_DIR="$2"
EXPECTED="$3"
QUERY="$4"

cd "$WORK_DIR" || exit 1

if [ -f "patents.db" ]; then
    RESULT=$(sqlite3 patents.db "$QUERY" 2>/dev/null | tr -d '\n')
    # Handle numeric comparisons like '>0', '<5', '=10'
    if [[ "$EXPECTED" =~ ^([<>]=?|=)([0-9]+)$ ]]; then
        OP="${BASH_REMATCH[1]}"
        NUM="${BASH_REMATCH[2]}"
        if [ "$OP" = ">" ] && [ "$RESULT" -gt "$NUM" ]; then
            exit 0
        elif [ "$OP" = ">=" ] && [ "$RESULT" -ge "$NUM" ]; then
            exit 0
        elif [ "$OP" = "<" ] && [ "$RESULT" -lt "$NUM" ]; then
            exit 0
        elif [ "$OP" = "<=" ] && [ "$RESULT" -le "$NUM" ]; then
            exit 0
        elif [ "$OP" = "=" ] && [ "$RESULT" -eq "$NUM" ]; then
            exit 0
        fi
    elif [ "$RESULT" = "$EXPECTED" ]; then
        exit 0
    fi
fi
exit 1
