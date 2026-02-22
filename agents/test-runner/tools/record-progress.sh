#!/bin/bash
# agents/test-runner/tools/record-progress.sh
# Appends a structured JSONL entry to progress.jsonl for test isolation tracking

PROGRESS_FILE="agents/test-runner/progress.jsonl"

TEST_CASE="${1:-No test case specified}"
STATUS="${2:-UNKNOWN}"
DETAILS="${3:-}"
ERRORS="${4:-}"
INPUT_TOKENS="${5:-0}"
OUTPUT_TOKENS="${6:-0}"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Use jq to safely create JSON
ENTRY=$(jq -n -c \
  --arg ts "$TIMESTAMP" \
  --arg tc "$TEST_CASE" \
  --arg status "$STATUS" \
  --arg details "$DETAILS" \
  --arg errors "$ERRORS" \
  --arg in_tok "$INPUT_TOKENS" \
  --arg out_tok "$OUTPUT_TOKENS" \
  '{timestamp: $ts, test_case: $tc, status: $status, details: $details, errors: $errors, input_tokens: $in_tok, output_tokens: $out_tok}')

echo "$ENTRY" >> "$PROGRESS_FILE"
echo "[record-progress] Logged Test Case: $TEST_CASE ($STATUS) [In: $INPUT_TOKENS | Out: $OUTPUT_TOKENS]"
