#!/bin/bash
# test-summary.sh - Generate and display test summary report
# Usage: test-summary.sh <report_dir> <total_cases> <total_pass> <total_fail> <n_trials> [trial_results...]

set -e
set -o pipefail

REPORT_DIR="${1:?}"
TOTAL_CASES="${2:?}"
TOTAL_PASS="${3:?}"
TOTAL_FAIL="${4:?}"
N_TRIALS="${5:?}"
shift 5
TRIAL_RESULTS=("$@")

# --- Calculate averages per test case ---
declare -A TEST_DURATION_SUM
declare -A TEST_INPUT_SUM
declare -A TEST_OUTPUT_SUM
declare -A TEST_PASS_COUNT
declare -A TEST_TOTAL_COUNT
declare -A TEST_ALL_PASS

# Get unique test names
TEST_NAMES=()
for RESULT in "${TRIAL_RESULTS[@]}"; do
    IFS='|' read -r TEST_NAME PASSED DURATION INPUT OUTPUT <<< "$RESULT"
    if [[ ! " ${TEST_NAMES[@]} " =~ " ${TEST_NAME} " ]]; then
        TEST_NAMES+=("$TEST_NAME")
    fi
    TEST_DURATION_SUM[$TEST_NAME]=$((${TEST_DURATION_SUM[$TEST_NAME]:-0} + DURATION))
    TEST_INPUT_SUM[$TEST_NAME]=$((${TEST_INPUT_SUM[$TEST_NAME]:-0} + INPUT))
    TEST_OUTPUT_SUM[$TEST_NAME]=$((${TEST_OUTPUT_SUM[$TEST_NAME]:-0} + OUTPUT))
    TEST_TOTAL_COUNT[$TEST_NAME]=$((${TEST_TOTAL_COUNT[$TEST_NAME]:-0} + 1))

    if [ "$PASSED" = "true" ]; then
        TEST_PASS_COUNT[$TEST_NAME]=$((${TEST_PASS_COUNT[$TEST_NAME]:-0} + 1))
        TEST_ALL_PASS[$TEST_NAME]=${TEST_ALL_PASS[$TEST_NAME]:-true}
    else
        TEST_ALL_PASS[$TEST_NAME]=false
    fi
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
    echo "## Test Results"
    echo ""
    echo "| Test | Status | Avg Duration | Avg Input Tokens | Avg Output Tokens |"
    echo "|------|--------|--------------|-------------------|--------------------|"

    for TEST_NAME in "${TEST_NAMES[@]}"; do
        AVG_DURATION=$((TEST_DURATION_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
        AVG_INPUT=$((TEST_INPUT_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
        AVG_OUTPUT=$((TEST_OUTPUT_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
        STATUS="✅ PASS"
        if [ "${TEST_ALL_PASS[$TEST_NAME]}" != "true" ]; then
            STATUS="❌ FAIL"
        fi
        echo "| $TEST_NAME | $STATUS | ${AVG_DURATION}s | $AVG_INPUT | $AVG_OUTPUT |"
    done
} > "$REPORT_FILE"

# --- Display summary ---
echo ""
echo "=================================================="
echo "[Host] Test-Runner finished."
echo "[Host] Summary: $TOTAL_PASS/$TOTAL_CASES test cases passed."
echo ""
echo "[Host] Test Results:"
for TEST_NAME in "${TEST_NAMES[@]}"; do
    AVG_DURATION=$((TEST_DURATION_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
    AVG_INPUT=$((TEST_INPUT_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
    AVG_OUTPUT=$((TEST_OUTPUT_SUM[$TEST_NAME] / TEST_TOTAL_COUNT[$TEST_NAME]))
    STATUS="✅"
    if [ "${TEST_ALL_PASS[$TEST_NAME]}" != "true" ]; then
        STATUS="❌"
    fi
    echo "[Host]   $STATUS $TEST_NAME - ${AVG_DURATION}s (in: $AVG_INPUT, out: $AVG_OUTPUT tokens)"
done
echo ""
echo "[Host] Report : $REPORT_FILE"
echo "=================================================="
