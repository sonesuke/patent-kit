#!/bin/bash
# check-skill-not-invoked.sh - Check if a specific skill was NOT invoked
# Usage: check-skill-not-invoked.sh <log_file> <work_dir> <skill_name>

LOG_FILE="${1:-}"
WORK_DIR="${2:-}"
SKILL_NAME="${3:-}"

if [ -z "$LOG_FILE" ] || [ -z "$SKILL_NAME" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <skill_name>" >&2
    exit 1
fi

# Check if the skill was NOT invoked in the log
# Note: Log is JSONL format with "name":"Skill" and "skill":"patent-kit:<skill-name>"
if grep -q '"Skill"' "$LOG_FILE" && grep -q '"skill":".*'"$SKILL_NAME" "$LOG_FILE"; then
    # Skill was invoked - we expected it NOT to be - failure
    exit 1
else
    # Skill was not invoked - success
    exit 0
fi
