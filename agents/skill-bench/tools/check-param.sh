#!/bin/bash
# Check if parameter was used in tool call
# Usage: check-param.sh <log_file> <work_dir> <tool_name> <param_name> <expected_value>

LOG_FILE="$1"
WORK_DIR="$2"
TOOL_NAME="$3"
PARAM_NAME="$4"
EXPECTED_VALUE="$5"

if [ -z "$LOG_FILE" ] || [ -z "$TOOL_NAME" ] || [ -z "$PARAM_NAME" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <tool_name> <param_name> [expected_value]" >&2
    exit 1
fi

if [ -n "$EXPECTED_VALUE" ]; then
    # Check if parameter equals expected value (handle both string and array)
    jq -s "[.[] | select(.type == \"assistant\") | .message.content[]? | select(type == \"object\" and .type == \"tool_use\") | select(.name | test(\"$TOOL_NAME\"; \"i\")) | .input.$PARAM_NAME | (if type == \"array\" then .[] == \"$EXPECTED_VALUE\" else . == \"$EXPECTED_VALUE\" end)] | any" "$LOG_FILE"
else
    # Check if parameter exists
    jq -s "[.[] | select(.type == \"assistant\") | .message.content[]? | select(type == \"object\" and .type == \"tool_use\") | select(.name | test(\"$TOOL_NAME\"; \"i\")) | .input.$PARAM_NAME] | length > 0" "$LOG_FILE"
fi
