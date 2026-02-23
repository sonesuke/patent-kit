#!/bin/bash
# agents/test-runner/runner.sh (Host side)
# Parallel Claude CLI test runner.
# For each test case directory: spawns N trial `claude -p` processes in parallel,
# waits for all trials, then runs a separate `claude -p` evaluator session.

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
mkdir -p "$WORKSPACE_FOLDER/e2e/reports"
REPORT_ID=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$WORKSPACE_FOLDER/e2e/reports/$REPORT_ID"
mkdir -p "$REPORT_DIR"

echo "=================================================="
echo "[Host] Starting Parallel Claude CLI Test-Runner"
echo "[Host] Trials per test case: $N_TRIALS"
echo "=================================================="

TOTAL_CASES=0
TOTAL_PASS=0
TOTAL_FAIL=0

# --- Process each test type (triggering/functional) for each skill ---
for SKILL_DIR in "$WORKSPACE_FOLDER"/e2e/test_cases/*/; do
    # Remove trailing slash from SKILL_DIR
    SKILL_DIR="${SKILL_DIR%/}"
    SKILL_NAME=$(basename "$SKILL_DIR")

    # Skip if TARGET_SKILL is specified and doesn't match
    if [ -n "$TARGET_SKILL" ] && [ "$SKILL_NAME" != "$TARGET_SKILL" ]; then
        continue
    fi

    # Process each test type (triggering, functional, etc.)
    for TEST_TYPE_DIR in "$SKILL_DIR"/*/; do
        # Remove trailing slash from TEST_TYPE_DIR
        TEST_CASE_DIR="${TEST_TYPE_DIR%/}"
        TEST_CASE_NAME="${SKILL_NAME}/$(basename "$TEST_TYPE_DIR")"
        TOTAL_CASES=$((TOTAL_CASES + 1))

    # Read test-prompt.md (used as-is for claude -p)
    TEST_PROMPT_FILE="$TEST_CASE_DIR/test-prompt.md"
    EVAL_TOML_FILE="$TEST_CASE_DIR/evaluation.toml"
    SETUP_DIR="$TEST_CASE_DIR/setup"

    if [ ! -f "$TEST_PROMPT_FILE" ]; then
        echo "[Host] ⚠️  Skipping $TEST_CASE_NAME: no test-prompt.md found"
        continue
    fi



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

        # --- Host-side workspace setup ---
        echo "[Host]   Setting up workspace: $WORK_DIR"
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
            bash -c "rm -rf ${WORK_DIR} && mkdir -p ${WORK_DIR} && cp -r plugin e2e agents .claude-plugin ./.claude.json CLAUDE.md ${WORK_DIR}/ 2>/dev/null || true"

        # Copy setup files into workspace (if setup/ directory exists)
        # Convert host path to container path
        SETUP_REL_PATH="${TEST_CASE_DIR#$WORKSPACE_FOLDER/}"
        SETUP_DIR_CONTAINER="/workspaces/patent-kit/$SETUP_REL_PATH/setup"

        if [ -d "$SETUP_DIR" ]; then
            devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
                bash -c "cp -r ${SETUP_DIR_CONTAINER}/* ${WORK_DIR}/"
        fi

        echo "[Host]   Launching trial $TRIAL → $LOG_FILE"

        devcontainer exec \
            --workspace-folder "$WORKSPACE_FOLDER" \
            bash -c 'cd "$1" && claude -p \
                --dangerously-skip-permissions \
                --verbose \
                --output-format stream-json \
                --plugin-dir ./plugin \
                -- "$2" < /dev/null' -- "${WORK_DIR}" "$(cat "$TEST_PROMPT_FILE")" \
                >"$LOG_FILE" 2>&1 &

        PIDS+=($!)
    done

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

    # --- Phase 2: Deterministic evaluation (bash + jq) ---
    echo "[Host]   Running evaluation..."

    CASE_PASS=true

    for TRIAL_IDX in $(seq 0 $((N_TRIALS - 1))); do
        TRIAL_NUM=$((TRIAL_IDX + 1))
        WORK_DIR="${TRIAL_DIRS[$TRIAL_IDX]}"
        LOG_FILE="$CASE_REPORT_DIR/trial-${TRIAL_NUM}.log"
        TRIAL_PASS=true

        echo "[Host]   --- Trial $TRIAL_NUM ---"

        # Run each check from evaluation.toml
        NUM_CHECKS=$(yq eval '.checks | length' "$EVAL_TOML_FILE")
        for CHECK_IDX in $(seq 0 $((NUM_CHECKS - 1))); do
            CHECK_NAME=$(yq eval ".checks[$CHECK_IDX].name" "$EVAL_TOML_FILE")
            CHECK_TYPE=$(yq eval ".checks[$CHECK_IDX].type" "$EVAL_TOML_FILE")

            if [ "$CHECK_TYPE" = "workspace" ]; then
                CHECK_CMD=$(yq eval ".checks[$CHECK_IDX].command" "$EVAL_TOML_FILE")
                if devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
                    bash -c "cd ${WORK_DIR} && ${CHECK_CMD}" >/dev/null 2>&1; then
                    echo "[Host]     ✅ $CHECK_NAME"
                else
                    echo "[Host]     ❌ $CHECK_NAME"
                    TRIAL_PASS=false
                fi
            elif [ "$CHECK_TYPE" = "log" ]; then
                JQ_FILTER=$(yq eval ".checks[$CHECK_IDX].jq" "$EVAL_TOML_FILE")
                if grep -v '^\s*$' "$LOG_FILE" | jq -s -e "any(.[]; $JQ_FILTER)" >/dev/null 2>&1; then
                    echo "[Host]     ✅ $CHECK_NAME"
                else
                    echo "[Host]     ❌ $CHECK_NAME"
                    TRIAL_PASS=false
                fi
            fi
        done

        # Extract token usage from log (type: result)
        INPUT_TOKENS=$(grep -v '^\s*$' "$LOG_FILE" | jq -s '[.[] | select(.type == "result") | .usage.input_tokens // 0] | add' 2>/dev/null || echo "0")
        OUTPUT_TOKENS=$(grep -v '^\s*$' "$LOG_FILE" | jq -s '[.[] | select(.type == "result") | .usage.output_tokens // 0] | add' 2>/dev/null || echo "0")
        DURATION="${TRIAL_DURATIONS[$TRIAL_IDX]}s"

        echo "[Host]     📊 Tokens: in=$INPUT_TOKENS out=$OUTPUT_TOKENS | Time: $DURATION"

        if [ "$TRIAL_PASS" = false ]; then
            CASE_PASS=false
        fi
    done

        if [ "$CASE_PASS" = true ]; then
            echo "[Host]   ✅ $TEST_CASE_NAME: PASS"
            TOTAL_PASS=$((TOTAL_PASS + 1))
        else
            echo "[Host]   ❌ $TEST_CASE_NAME: FAIL"
            TOTAL_FAIL=$((TOTAL_FAIL + 1))
        fi
    done  # End of TEST_TYPE_DIR loop
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
