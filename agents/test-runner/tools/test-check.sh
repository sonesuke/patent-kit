#!/bin/bash
# test-check.sh - Run evaluation checks on test results
# Usage: test-check.sh <workspace_folder> <test_toml_file> <log_file> <work_dir> <trial_num>
# Returns: 0 if all checks pass, 1 otherwise

set -e
set -o pipefail

WORKSPACE_FOLDER="${1:?}"
TEST_TOML_FILE="${2:?}"
LOG_FILE="${3:?}"
WORK_DIR="${4:?}"
TRIAL_NUM="${5:-1}"

TRIAL_PASS=true

# --- Display trial header ---
echo ""
echo "[Host]   --- Trial $TRIAL_NUM ---"

# --- Run each check from test.toml ---
NUM_CHECKS=$(yq eval '.checks | length' "$TEST_TOML_FILE")
for CHECK_IDX in $(seq 0 $((NUM_CHECKS - 1))); do
    CHECK_NAME=$(yq eval ".checks[$CHECK_IDX].name" "$TEST_TOML_FILE")
    CHECK_TYPE=$(yq eval ".checks[$CHECK_IDX].type" "$TEST_TOML_FILE")

    if [ "$CHECK_TYPE" = "workspace" ]; then
        CHECK_CMD=$(yq eval ".checks[$CHECK_IDX].command" "$TEST_TOML_FILE")
        if devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
            bash -c "cd ${WORK_DIR} && ${CHECK_CMD}" >/dev/null 2>&1; then
            echo "[Host]     ✅ $CHECK_NAME"
        else
            echo "[Host]     ❌ $CHECK_NAME"
            TRIAL_PASS=false
        fi
    elif [ "$CHECK_TYPE" = "log" ]; then
        JQ_FILTER=$(yq eval ".checks[$CHECK_IDX].jq" "$TEST_TOML_FILE")
        if grep -v '^\s*$' "$LOG_FILE" | jq -s -e "$JQ_FILTER" >/dev/null 2>&1; then
            echo "[Host]     ✅ $CHECK_NAME"
        else
            echo "[Host]     ❌ $CHECK_NAME"
            TRIAL_PASS=false
        fi
    elif [ "$CHECK_TYPE" = "script" ]; then
        CHECK_CMD=$(yq eval ".checks[$CHECK_IDX].command" "$TEST_TOML_FILE")
        MCP_TOOL=$(yq eval ".checks[$CHECK_IDX].mcp_tool // \"\"" "$TEST_TOML_FILE")
        IF_CALLED=$(yq eval ".checks[$CHECK_IDX].if_called // \"false\"" "$TEST_TOML_FILE")
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        OPTIONAL_FLAG=""
        if [ "$IF_CALLED" = "true" ]; then
            OPTIONAL_FLAG="--optional"
        fi
        # Prepend ./ to command if not already present
        [[ ! "$CHECK_CMD" =~ ^\.\/ ]] && CHECK_CMD="./$CHECK_CMD"
        cd "$SCRIPT_DIR" && if $CHECK_CMD "$LOG_FILE" "$MCP_TOOL" "$OPTIONAL_FLAG" >/dev/null 2>&1; then
            echo "[Host]     ✅ $CHECK_NAME"
        else
            echo "[Host]     ❌ $CHECK_NAME"
            TRIAL_PASS=false
        fi
    fi
done

# --- Extract and display token usage ---
INPUT_TOKENS=$(grep -v '^\s*$' "$LOG_FILE" | jq -s '[.[] | select(.type == "result") | .usage.input_tokens // 0] | add' 2>/dev/null || echo "0")
CACHE_READ_TOKENS=$(grep -v '^\s*$' "$LOG_FILE" | jq -s '[.[] | select(.type == "result") | .usage.cache_read_input_tokens // 0] | add' 2>/dev/null || echo "0")
TOTAL_INPUT_TOKENS=$((INPUT_TOKENS + CACHE_READ_TOKENS))
OUTPUT_TOKENS=$(grep -v '^\s*$' "$LOG_FILE" | jq -s '[.[] | select(.type == "result") | .usage.output_tokens // 0] | add' 2>/dev/null || echo "0")
echo "[Host]     📊 Tokens: in=$INPUT_TOKENS (cache=$CACHE_READ_TOKENS, total=$TOTAL_INPUT_TOKENS) out=$OUTPUT_TOKENS"

# --- Return exit code based on trial pass status ---
if [ "$TRIAL_PASS" = true ]; then
    exit 0
else
    exit 1
fi
