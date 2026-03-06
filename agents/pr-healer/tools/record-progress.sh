#!/usr/bin/env bash
set -euo pipefail

# Get main worktree path (works from any worktree)
GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
MAIN_WORKTREE=$(dirname "$GIT_COMMON_DIR")
PROGRESS_FILE="$MAIN_WORKTREE/agents/pr-healer/progress.jsonl"

# Ensure directory exists
mkdir -p "$(dirname "$PROGRESS_FILE")"

TASK="${1:-No task specified}"
FILES="${2:-}"
DECISIONS="${3:-}"
BLOCKERS="${4:-}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Use jq to safely create JSON
ENTRY=$(jq -n -c \
  --arg ts "$TIMESTAMP" \
  --arg task "$TASK" \
  --arg files "$FILES" \
  --arg decisions "$DECISIONS" \
  --arg blockers "$BLOCKERS" \
  '{timestamp: $ts, task: $task, files: $files, decisions: $decisions, blockers: $blockers}')

echo "$ENTRY" >> "$PROGRESS_FILE"
echo "✅ Progress logged: $TASK"

# Show recent count
RECENT=$(wc -l < "$PROGRESS_FILE" 2>/dev/null || echo "0")
echo "   Total records: $RECENT"
