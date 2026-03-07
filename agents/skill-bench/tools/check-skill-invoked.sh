#!/bin/bash
# check-skill-invoked.sh - Check if a specific skill was invoked
# Usage: check-skill-invoked.sh <log_file> <work_dir> <skill_name> [--not]
#   --not: Invert the check (verify skill was NOT invoked)

LOG_FILE="${1:-}"
WORK_DIR="${2:-}"
SKILL_NAME="${3:-}"
INVERT="${4:-}"

if [ -z "$LOG_FILE" ] || [ -z "$SKILL_NAME" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <skill_name> [--not]" >&2
    exit 1
fi

# Check if the skill was invoked in the log
# Note: Log is JSONL format with "name":"Skill" and "skill":"patent-kit:<skill-name>"
if grep -q '"Skill"' "$LOG_FILE" && grep -q '"skill":".*'"$SKILL_NAME" "$LOG_FILE"; then
    # Skill was invoked
    if [ "$INVERT" = "--not" ]; then
        # We expected it NOT to be invoked, but it was - failure
        exit 1
    else
        # We expected it to be invoked, and it was - success
        exit 0
    fi
else
    # Skill was not invoked
    if [ "$INVERT" = "--not" ]; then
        # We expected it NOT to be invoked, and it wasn't - success
        exit 0
    else
        # We expected it to be invoked, but it wasn't - failure
        exit 1
    fi
fi
