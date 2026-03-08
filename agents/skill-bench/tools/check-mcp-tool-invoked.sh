#!/bin/bash
# check-mcp-tool-invoked.sh - Check if a specific MCP tool was invoked
# Usage: check-mcp-tool-invoked.sh <log_file> <work_dir> <mcp_tool_name>
#   mcp_tool_name: e.g., "search_patents", "fetch_patent", etc.

LOG_FILE="${1:-}"
WORK_DIR="${2:-}"
TOOL_NAME="${3:-}"

if [ -z "$LOG_FILE" ] || [ -z "$TOOL_NAME" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <mcp_tool_name>" >&2
    exit 1
fi

# Check if the MCP tool was invoked in the log
# MCP tools appear as: "name":"mcp__plugin_xxx__tool_name"
if grep -q '"name":"mcp__'" "$LOG_FILE" && grep -q '"name":"mcp__.*__'"$TOOL_NAME"'"' "$LOG_FILE"; then
    # Tool was invoked - success
    exit 0
else
    # Tool was not invoked - failure
    exit 1
fi
