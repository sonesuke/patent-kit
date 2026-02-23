#!/bin/bash
# agents/test-runner/runner.sh (Host side)
# Parallel Claude CLI test runner.
# Orchestrates test execution: manages processes, collects results, generates reports.
# All display/output is delegated to test-setup.sh and test-check.sh.
#
# Usage: runner.sh <n_trials> [pattern]
#   n_trials: Number of trials per test case (default: 1)
#   pattern:  Glob pattern to match test files (default: "cases/*/*.toml")
#             Examples:
#               "cases/*/*.toml"                    - all tests
#               "cases/c*/*.toml"                   - skills starting with 'c'
#               "cases/concept-interview/*.toml"    - all concept-interview tests
#               "cases/concept-interview/func*.toml" - tests starting with 'func'
#               "cases/concept-interview/functional-with-spec.toml" - specific test

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
TARGET_PATTERN="${2:-cases/*/*.toml}"

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
echo "[Host] Pattern: $TARGET_PATTERN"
echo "=================================================="

TOTAL_CASES=0
TOTAL_PASS=0
TOTAL_FAIL=0

# Track all log files for summary
declare -a ALL_LOG_FILES=()

# --- Collect test files matching pattern ---
TEST_FILES=()
for TEST_FILE in $TARGET_PATTERN; do
    # Skip if no matches
    [ -f "$TEST_FILE" ] || continue

    # Extract skill and test names from path
    # Expected format: cases/<skill>/<test>.toml
    TEST_FILE_REL="${TEST_FILE#$WORKSPACE_FOLDER/}"
    SKILL_NAME=$(basename "$(dirname "$TEST_FILE_REL")")
    TEST_NAME=$(basename "$TEST_FILE" .toml)

    TEST_FILES+=("$TEST_FILE")
    TEST_SKILLS+=("$SKILL_NAME")
    TEST_NAMES+=("$TEST_NAME")
done

# --- Process each test file ---
for IDX in "${!TEST_FILES[@]}"; do
    TEST_FILE="${TEST_FILES[$IDX]}"
    SKILL_NAME="${TEST_SKILLS[$IDX]}"
    TEST_NAME="${TEST_NAMES[$IDX]}"
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
    TRIAL_LOG_FILES=()

    # Create skill-specific log directory
    LOG_DIR="$REPORT_DIR/${SKILL_NAME}"
    mkdir -p "$LOG_DIR"

    for TRIAL in $(seq 1 "$N_TRIALS"); do
        LABEL="${TEST_CASE_NAME}_trial-${TRIAL}"
        LOG_FILE="$LOG_DIR/${TEST_NAME}-${TRIAL}.log"
        WORK_DIR="/tmp/e2e-${LABEL}"
        TRIAL_LOG_FILES+=("$LOG_FILE")
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
    RESULT_FILE="$LOG_DIR/${TEST_NAME}.results"
    > "$RESULT_FILE"  # Create/clear result file

    for TRIAL_IDX in $(seq 0 $((N_TRIALS - 1))); do
        TRIAL_NUM=$((TRIAL_IDX + 1))
        WORK_DIR="${TRIAL_DIRS[$TRIAL_IDX]}"
        LOG_FILE="${TRIAL_LOG_FILES[$TRIAL_IDX]}"

        # Run checks using test-check.sh and capture output
        CHECK_OUTPUT=$("$(dirname "$0")/tools/test-check.sh" "$WORKSPACE_FOLDER" "$TEST_FILE" "$LOG_FILE" "$WORK_DIR" "$TRIAL_NUM" 2>&1)
        CHECK_EXIT_CODE=$?

        # Display output
        echo "$CHECK_OUTPUT"

        # Extract token usage from output
        TRIAL_INPUT=$(echo "$CHECK_OUTPUT" | grep "📊 Tokens:" | sed -E 's/.*in=([0-9]+).*/\1/' || echo "0")
        TRIAL_OUTPUT=$(echo "$CHECK_OUTPUT" | grep "📊 Tokens:" | sed -E 's/.*out=([0-9]+).*/\1/' || echo "0")

        # Store trial result for summary
        TRIAL_STATUS="true"
        if [ $CHECK_EXIT_CODE -ne 0 ]; then
            CASE_PASS=false
            TRIAL_STATUS="false"
        fi
        echo "${TRIAL_STATUS}|${TRIAL_DURATIONS[$TRIAL_IDX]}|${TRIAL_INPUT}|${TRIAL_OUTPUT}" >> "$RESULT_FILE"

        # Display duration
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
done

# --- Generate and display summary (delegated to test-summary.sh) ---
"$(dirname "$0")/tools/test-summary.sh" "$REPORT_DIR" "$TOTAL_CASES" "$TOTAL_PASS" "$TOTAL_FAIL" "$N_TRIALS"

exit "$TOTAL_FAIL"
