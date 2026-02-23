#!/bin/bash
# check-skill-invoked.sh - Check if a specific skill was invoked
# Usage: check-skill-invoked.sh <skill_name> <log_file> [<mcp_tool>] [<optional_flag>]
# Note: Called from test-check.sh as: $CHECK_CMD "$LOG_FILE" "$MCP_TOOL" "$OPTIONAL_FLAG"
# where $CHECK_CMD = "check-skill-invoked.sh constitution-reminding"
# So actual arguments are: $1=skill_name, $2=log_file, $3=mcp_tool, $4=optional_flag

SKILL_NAME="${1:-}"
LOG_FILE="${2:-}"

if [ -z "$LOG_FILE" ] || [ -z "$SKILL_NAME" ]; then
    echo "[Error] Usage: $0 <skill_name> <log_file>" >&2
    exit 1
fi

# Check if the skill was invoked in the log
# Note: Log is JSONL format with "name":"Skill" and "skill":"patent-kit:<skill-name>"
grep -q '"Skill"' "$LOG_FILE" && grep -q '"skill":".*'"$SKILL_NAME" "$LOG_FILE"
