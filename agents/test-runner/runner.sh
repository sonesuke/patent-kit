#!/bin/bash
# agents/test-runner/runner.sh (Host side)
# The "Host Loop" daemon script for executing Test-Runner agent.

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

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "[Error] Docker is not running or accessible. Please start Docker Desktop." >&2
    exit 1
fi

WORKSPACE_FOLDER="${WORKSPACE_FOLDER:-$(pwd)}"
N_TRIALS="${1:-1}" # Default to 1 trial if not specified

echo "[Host] Ensuring dev container is up for $WORKSPACE_FOLDER..."
devcontainer up --workspace-folder "$WORKSPACE_FOLDER"

echo "[Host] Ensuring patent-kit plugin is loaded in Claude Code..."
devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" claude plugin add plugin/ || true

# Ensure the e2e reporting directory exists
mkdir -p "$WORKSPACE_FOLDER/e2e/reports"
REPORT_ID=$(date +%Y%m%d_%H%M%S)

echo "=================================================="
echo "[Host] Starting Agentic Test-Runner for $N_TRIALS trials..."

# Loop for N_TRIALS
for ((i=1; i<=N_TRIALS; i++)); do
    echo "=================================================="
    echo "[Host] Trial $i / $N_TRIALS"
    echo "[Host] Triggering Claude inside Dev Container..."

    # Run Claude inside the container. 
    TEMP_ERR=$(mktemp)

    if ! devcontainer exec \
        --workspace-folder "$WORKSPACE_FOLDER" \
        claude -p \
            --dangerously-skip-permissions \
            --verbose \
            --output-format stream-json \
            "$(cat agents/test-runner/prompt.txt) REPORT_ID=$REPORT_ID TRIAL=$i" < /dev/null 2>"$TEMP_ERR" | jq . ; then
        
        EXIT_CODE=$?
        echo "[Host] Error: Claude agent or devcontainer failed on Trial $i with exit code $EXIT_CODE." >&2
        if [ -s "$TEMP_ERR" ]; then
            echo "[Host] Detailed error log:" >&2
            cat "$TEMP_ERR" >&2
        fi
        rm -f "$TEMP_ERR"
        
        echo "[Host] Terminating test run due to error." >&2
        exit $EXIT_CODE
    fi

    rm -f "$TEMP_ERR"
    sleep 2 # Brief pause between trials
done

rm -f "$TEMP_ERR"

echo "[Host] Test-Runner finished. Reports should be available in e2e/reports/."
exit 0
