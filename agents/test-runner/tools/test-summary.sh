#!/bin/bash
# test-summary.sh - Generate and display test summary report
# Usage: test-summary.sh <report_dir> <total_cases> <total_pass> <total_fail> <n_trials>

set -e
set -o pipefail

REPORT_DIR="${1:?}"
TOTAL_CASES="${2:?}"
TOTAL_PASS="${3:?}"
TOTAL_FAIL="${4:?}"
N_TRIALS="${5:?}"

# --- Generate summary report ---
REPORT_FILE="$REPORT_DIR/summary.md"
{
    echo "# E2E Test Report"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Total Test Cases | $TOTAL_CASES |"
    echo "| Passed | $TOTAL_PASS |"
    echo "| Failed | $TOTAL_FAIL |"
    echo "| Trials per Case | $N_TRIALS |"
} > "$REPORT_FILE"

# --- Display summary ---
echo ""
echo "=================================================="
echo "[Host] Test-Runner finished."
echo "[Host] Summary: $TOTAL_PASS/$TOTAL_CASES test cases passed."
echo "[Host] Report : $REPORT_FILE"
echo "=================================================="
