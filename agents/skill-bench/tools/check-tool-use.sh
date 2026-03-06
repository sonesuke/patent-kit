#!/bin/bash
# Check if a specific tool was called with specific parameters
# Usage: check-tool-use.sh <log_file> <work_dir> <tool_name> <param_name> <param_pattern>
#   log_file: Path to the log file
#   work_dir: Path to the workspace directory
#   tool_name: Name of the tool to check (e.g., "Read", "Write")
#   param_name: Name of the parameter to check (e.g., "file_path")
#   param_pattern: Pattern to match in the parameter value (regex)

LOG_FILE="$1"
WORK_DIR="$2"
TOOL_NAME="$3"
PARAM_NAME="${4:-}"
PARAM_PATTERN="${5:-}"

if [ -z "$LOG_FILE" ] || [ -z "$TOOL_NAME" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <tool_name> [param_name] [param_pattern]" >&2
    exit 1
fi

if [ -n "$PARAM_NAME" ] && [ -n "$PARAM_PATTERN" ]; then
    # Check if tool was called with specific parameter matching pattern
    jq -s "[.[] | select(.type == \"assistant\") | .message.content[]? | select(type == \"object\" and .type == \"tool_use\" and .name == \"$TOOL_NAME\") | select(.input.$PARAM_NAME | test(\"$PARAM_PATTERN\"))] | length > 0" "$LOG_FILE"
elif [ -n "$PARAM_NAME" ]; then
    # Check if tool was called with specific parameter (any value)
    jq -s "[.[] | select(.type == \"assistant\") | .message.content[]? | select(type == \"object\" and .type == \"tool_use\" and .name == \"$TOOL_NAME\") | .input.$PARAM_NAME] | length > 0" "$LOG_FILE"
else
    # Check if tool was called (any parameters)
    jq -s "[.[] | select(.type == \"assistant\") | .message.content[]? | select(type == \"object\" and .type == \"tool_use\" and .name == \"$TOOL_NAME\")] | length > 0" "$LOG_FILE"
fi
