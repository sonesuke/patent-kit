#!/bin/bash
# test-summary.sh - Generate and display test summary report from result files
# Usage: test-summary.sh <report_dir> <total_cases> <total_pass> <total_fail> <n_trials>

set -e
set -o pipefail

REPORT_DIR="${1:?}"
TOTAL_CASES="${2:?}"
TOTAL_PASS="${3:?}"
TOTAL_FAIL="${4:?}"
N_TRIALS="${5:?}"

# --- Parse result files and collect statistics ---
RESULT_FILES=()
for f in "$REPORT_DIR"/*.results; do
    [ -f "$f" ] || continue
    RESULT_FILES+=("$f")
done

# Get unique test names
TEST_NAMES=()
declare -a TEST_STATS  # Format: "test_name|total_duration|total_input|total_output|count|all_pass"

for RESULT_FILE in "${RESULT_FILES[@]}"; do
    # Extract test name from file name
    FILE_BASENAME=$(basename "$RESULT_FILE" .results)
    TEST_NAMES+=("$FILE_BASENAME")
done

# Calculate statistics for each test
for TEST_NAME in "${TEST_NAMES[@]}"; do
    RESULT_FILE="$REPORT_DIR/${TEST_NAME}.results"

    DURATION_SUM=0
    INPUT_SUM=0
    OUTPUT_SUM=0
    COUNT=0
    ALL_PASS=true

    while IFS='|' read -r R_PASSED R_DURATION R_INPUT R_OUTPUT; do
        DURATION_SUM=$((DURATION_SUM + R_DURATION))
        INPUT_SUM=$((INPUT_SUM + R_INPUT))
        OUTPUT_SUM=$((OUTPUT_SUM + R_OUTPUT))
        COUNT=$((COUNT + 1))

        if [ "$R_PASSED" != "true" ]; then
            ALL_PASS=false
        fi
    done < "$RESULT_FILE"

    TEST_STATS+=("${TEST_NAME}|${DURATION_SUM}|${INPUT_SUM}|${OUTPUT_SUM}|${COUNT}|${ALL_PASS}")
done

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
    echo ""

    if [ ${#TEST_NAMES[@]} -gt 0 ]; then
        echo "## Test Results"
        echo ""
        echo "| Test | Status | Avg Duration | Avg Input Tokens | Avg Output Tokens |"
        echo "|------|--------|--------------|-------------------|--------------------|"

        for STAT in "${TEST_STATS[@]}"; do
            IFS='|' read -r TEST_NAME DURATION_SUM INPUT_SUM OUTPUT_SUM COUNT ALL_PASS <<< "$STAT"
            AVG_DURATION=$((DURATION_SUM / COUNT))
            AVG_INPUT=$((INPUT_SUM / COUNT))
            AVG_OUTPUT=$((OUTPUT_SUM / COUNT))

            STATUS="✅ PASS"
            if [ "$ALL_PASS" != "true" ]; then
                STATUS="❌ FAIL"
            fi
            echo "| $TEST_NAME | $STATUS | ${AVG_DURATION}s | $AVG_INPUT | $AVG_OUTPUT |"
        done
    fi
} > "$REPORT_FILE"

# --- Display summary ---
echo ""
echo "=================================================="
echo "[Host] Test-Runner finished."
echo "[Host] Summary: $TOTAL_PASS/$TOTAL_CASES test cases passed."

if [ ${#TEST_NAMES[@]} -gt 0 ]; then
    echo ""
    echo "[Host] Test Results:"
    for STAT in "${TEST_STATS[@]}"; do
        IFS='|' read -r TEST_NAME DURATION_SUM INPUT_SUM OUTPUT_SUM COUNT ALL_PASS <<< "$STAT"
        AVG_DURATION=$((DURATION_SUM / COUNT))
        AVG_INPUT=$((INPUT_SUM / COUNT))
        AVG_OUTPUT=$((OUTPUT_SUM / COUNT))

        STATUS="✅"
        if [ "$ALL_PASS" != "true" ]; then
            STATUS="❌"
        fi
        echo "[Host]   $STATUS $TEST_NAME - ${AVG_DURATION}s (in: $AVG_INPUT, out: $AVG_OUTPUT tokens)"
    done
fi

echo ""
echo "[Host] Report : $REPORT_FILE"
echo "=================================================="
