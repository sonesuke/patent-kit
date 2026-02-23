#!/bin/bash
# agents/test-runner/runner.sh (Host side)
# Parallel Claude CLI test runner.
# Orchestrates test execution: manages processes, collects results, generates reports.
# All display/output is delegated to test-setup.sh and test-check.sh.

set -e
set -o pipefail

# --- Pre-flight Checks ---
check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[Error] Required command '$1' not found. Please install it." >&2
        return 1
    fi
}

check_command "devcontainer" || exit 1
check_command "jq" || exit 1
check_command "yq" || exit 1

if ! docker info >/dev/null 2>&1; then
    echo "[Error] Docker is not running or accessible. Please start Docker Desktop." >&2
    exit 1
fi

WORKSPACE_FOLDER="${WORKSPACE_FOLDER:-$(pwd)}"
N_TRIALS="${1:-1}"
TARGET_SKILL="${2:-}"  # Optional: specify skill folder (e.g., "targeting")

echo "[Host] Ensuring dev container is up for $WORKSPACE_FOLDER..."
devcontainer up --workspace-folder "$WORKSPACE_FOLDER"

# --- Prepare report directory ---
mkdir -p "$WORKSPACE_FOLDER/out"
REPORT_ID=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$WORKSPACE_FOLDER/out/$REPORT_ID"
mkdir -p "$REPORT_DIR"

echo "=================================================="
echo "[Host] Starting Parallel Claude CLI Test-Runner"
echo "[Host] Trials per test case: $N_TRIALS"
echo "=================================================="

TOTAL_CASES=0
TOTAL_PASS=0
TOTAL_FAIL=0

# --- Process each skill directory ---
for SKILL_DIR in "$WORKSPACE_FOLDER"/cases/*/; do
    # Remove trailing slash from SKILL_DIR
    SKILL_DIR="${SKILL_DIR%/}"
    SKILL_NAME=$(basename "$SKILL_DIR")

    # Skip if TARGET_SKILL is specified and doesn't match
    if [ -n "$TARGET_SKILL" ] && [ "$SKILL_NAME" != "$TARGET_SKILL" ]; then
        continue
    fi

    # Process each test file (*.toml) in the skill directory
    for TEST_FILE in "$SKILL_DIR"/*.toml; do
        # Skip if no .toml files exist
        [ -f "$TEST_FILE" ] || continue

        TEST_NAME=$(basename "$TEST_FILE" .toml)
        TEST_CASE_NAME="${SKILL_NAME}/${TEST_NAME}"
        TOTAL_CASES=$((TOTAL_CASES + 1))

        # Read test configuration
        TEST_PROMPT=$(yq eval '.test_prompt' "$TEST_FILE")

        echo ""
        echo "──────────────────────────────────────────────────"
        echo "[Host] Test Case: $TEST_CASE_NAME"
        echo "──────────────────────────────────────────────────"

        # --- Phase 1: Execute N trials in parallel ---
        PIDS=()
        TRIAL_DIRS=()
        TRIAL_START_TIMES=()
        CASE_REPORT_DIR="$REPORT_DIR/$TEST_CASE_NAME"
        mkdir -p "$CASE_REPORT_DIR"

        for TRIAL in $(seq 1 "$N_TRIALS"); do
            LABEL="${TEST_CASE_NAME}_trial-${TRIAL}"
            LOG_FILE="$CASE_REPORT_DIR/trial-${TRIAL}.log"
            WORK_DIR="/tmp/e2e-${LABEL}"
            TRIAL_DIRS+=("$WORK_DIR")
            TRIAL_START_TIMES+=($(date +%s))

            # Setup workspace (delegated to test-setup.sh)
            "$(dirname "$0")/tools/test-setup.sh" "$WORKSPACE_FOLDER" "$WORK_DIR" "$TEST_FILE"

            # Launch trial in background
            echo "[Host]   Launching trial $TRIAL → $LOG_FILE"
            devcontainer exec \
                --workspace-folder "$WORKSPACE_FOLDER" \
                bash -c 'cd "$1" && claude -p \
                    --dangerously-skip-permissions \
                    --verbose \
                    --output-format stream-json \
                    --plugin-dir ./plugin \
                    -- "$2" < /dev/null' -- "${WORK_DIR}" "$TEST_PROMPT" \
                >"$LOG_FILE" 2>&1 &

            PIDS+=($!)
        done

        # Wait for all trials to complete
        echo "[Host]   Waiting for ${#PIDS[@]} trial(s) to complete..."
        TRIAL_DURATIONS=()
        for i in "${!PIDS[@]}"; do
            if wait "${PIDS[$i]}"; then
                echo "[Host]   ✅ Trial $((i + 1)) finished"
            else
                echo "[Host]   ⚠️  Trial $((i + 1)) exited with non-zero (may still be valid)"
            fi
            END_TIME=$(date +%s)
            DURATION=$(( END_TIME - TRIAL_START_TIMES[i] ))
            TRIAL_DURATIONS+=("$DURATION")
            echo "[Host]   ⏱️  Trial $((i + 1)) took ${DURATION}s"
        done

        # --- Phase 2: Evaluate trials (delegated to test-check.sh) ---
        echo "[Host]   Running evaluation..."

        CASE_PASS=true

        for TRIAL_IDX in $(seq 0 $((N_TRIALS - 1))); do
            TRIAL_NUM=$((TRIAL_IDX + 1))
            WORK_DIR="${TRIAL_DIRS[$TRIAL_IDX]}"
            LOG_FILE="$CASE_REPORT_DIR/trial-${TRIAL_NUM}.log"

            # Run checks using test-check.sh (handles all display)
            if ! "$(dirname "$0")/tools/test-check.sh" "$WORKSPACE_FOLDER" "$TEST_FILE" "$LOG_FILE" "$WORK_DIR" "$TRIAL_NUM"; then
                CASE_PASS=false
            fi

            # Display duration (this is runner-level timing info)
            echo "[Host]   ⏱️  Trial $TRIAL_NUM took ${TRIAL_DURATIONS[$TRIAL_IDX]}s"
        done

        # Display case result
        if [ "$CASE_PASS" = true ]; then
            echo "[Host]   ✅ $TEST_CASE_NAME: PASS"
            TOTAL_PASS=$((TOTAL_PASS + 1))
        else
            echo "[Host]   ❌ $TEST_CASE_NAME: FAIL"
            TOTAL_FAIL=$((TOTAL_FAIL + 1))
        fi
    done  # End of TEST_FILE loop
done  # End of SKILL_DIR loop

# --- Generate summary report ---
REPORT_FILE="$REPORT_DIR/summary.md"
{
    echo "# E2E Test Report: $REPORT_ID"
    echo ""
    echo "| Metric | Value |"
    echo "|--------|-------|"
    echo "| Total Test Cases | $TOTAL_CASES |"
    echo "| Passed | $TOTAL_PASS |"
    echo "| Failed | $TOTAL_FAIL |"
    echo "| Trials per Case | $N_TRIALS |"
} > "$REPORT_FILE"

echo ""
echo "=================================================="
echo "[Host] Test-Runner finished."
echo "[Host] Summary: $TOTAL_PASS/$TOTAL_CASES test cases passed."
echo "[Host] Report : $REPORT_FILE"
echo "=================================================="

exit "$TOTAL_FAIL"
