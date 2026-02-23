#!/bin/bash
# test-setup.sh - Setup test workspace in dev container
# Usage: test-setup.sh <workspace_folder> <work_dir> <test_toml_file>

set -e
set -o pipefail

WORKSPACE_FOLDER="${1:?}"
WORK_DIR="${2:?}"
TEST_TOML_FILE="${3:?}"

echo "[Host]   📦 Setting up workspace: $WORK_DIR"

# --- Remove existing workspace and create new one ---
devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
    bash -c "rm -rf ${WORK_DIR} && mkdir -p ${WORK_DIR} && cp -r plugin e2e agents .claude-plugin ./.claude.json CLAUDE.md ${WORK_DIR}/ 2>/dev/null || true"

# --- Read setup files from test.toml [[setup]] array ---
NUM_SETUP=$(yq eval '.setup | length // 0' "$TEST_TOML_FILE")

if [ "$NUM_SETUP" -gt 0 ]; then
    for SETUP_IDX in $(seq 0 $((NUM_SETUP - 1))); do
        SETUP_PATH=$(yq eval ".setup[$SETUP_IDX].path" "$TEST_TOML_FILE")

        # Create parent directory in container
        SETUP_DIR=$(dirname "$WORK_DIR/$SETUP_PATH")
        devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
            bash -c "mkdir -p ${SETUP_DIR}"

        # Extract content and create file in container
        yq eval ".setup[$SETUP_IDX].content" "$TEST_TOML_FILE" | \
            devcontainer exec --workspace-folder "$WORKSPACE_FOLDER" \
            bash -c "cat > ${WORK_DIR}/${SETUP_PATH}"

        echo "[Host]      - Created ${SETUP_PATH}"
    done
    echo "[Host]   ✅ Setup complete ($NUM_SETUP file(s))"
else
    echo "[Host]   ✅ Setup complete"
fi
