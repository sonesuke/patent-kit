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
    if [ "$RESULT" = "$EXPECTED" ]; then
        exit 0
    fi
fi
exit 1
