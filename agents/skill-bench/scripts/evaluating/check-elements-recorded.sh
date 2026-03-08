#!/bin/bash
# Check if elements were recorded in database

EXPECTED_COUNT=${1:-1}

if [ ! -f patents.db ]; then
    echo "FAIL: patents.db not found"
    exit 1
fi

# Count elements in database
ACTUAL_COUNT=$(sqlite3 patents.db "SELECT COUNT(*) FROM elements;" 2>/dev/null)

if [ -z "$ACTUAL_COUNT" ]; then
    echo "FAIL: Could not query elements table"
    exit 1
fi

if [ "$ACTUAL_COUNT" -ge "$EXPECTED_COUNT" ]; then
    echo "PASS: Found $ACTUAL_COUNT elements (expected at least $EXPECTED_COUNT)"
    exit 0
else
    echo "FAIL: Found $ACTUAL_COUNT elements (expected at least $EXPECTED_COUNT)"
    exit 1
fi
