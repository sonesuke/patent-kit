#!/usr/bin/env bash
set -euo pipefail

# Get main worktree path (works from any worktree)
GIT_COMMON_DIR=$(git rev-parse --git-common-dir)
MAIN_WORKTREE=$(dirname "$GIT_COMMON_DIR")
PROGRESS_FILE="$MAIN_WORKTREE/agents/pr-healer/progress.jsonl"

if [[ ! -f "$PROGRESS_FILE" ]]; then
    echo "📋 No progress file found - this is a fresh start"
    exit 0
fi

LINES=$(wc -l < "$PROGRESS_FILE" | tr -d ' ')

if [[ "$LINES" -eq 0 ]]; then
    echo "📋 Progress file is empty - this is a fresh start"
    exit 0
fi

echo "📋 Progress History (showing last 5 entries of $LINES total):"
echo "================================"

tail -n 5 "$PROGRESS_FILE" | while IFS= read -r line; do
    echo "$line" | jq -r '"\(.timestamp): \(.task)\n  Files: \(.files)\n  Decisions: \(.decisions)\n  Blockers: \(.blockers)"'
    echo ""
done

echo ""
echo "Use this information to:"
echo "  - Skip tasks that have already been processed successfully"
echo "  - Retry tasks that failed previously"
echo "  - Avoid repeating the same fixes"
