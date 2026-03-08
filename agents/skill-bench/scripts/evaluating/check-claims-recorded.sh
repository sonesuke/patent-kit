#!/bin/bash
# Check if claims were recorded in database

EXPECTED_COUNT=${1:-1}

if [ ! -f patents.db ]; then
    echo "FAIL: patents.db not found"
    exit 1
fi

# Count claims in database
ACTUAL_COUNT=$(sqlite3 patents.db "SELECT COUNT(*) FROM claims;" 2>/dev/null)

if [ -z "$ACTUAL_COUNT" ]; then
    echo "FAIL: Could not query claims table"
    exit 1
fi

if [ "$ACTUAL_COUNT" -ge "$EXPECTED_COUNT" ]; then
    echo "PASS: Found $ACTUAL_COUNT claims (expected at least $EXPECTED_COUNT)"
    exit 0
else
    echo "FAIL: Found $ACTUAL_COUNT claims (expected at least $EXPECTED_COUNT)"
    exit 1
fi
