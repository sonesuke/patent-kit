#!/bin/bash
# Check if directories exist in the workspace
# Usage: check-workspace-dir.sh <log_file> <work_dir> <dir1> [dir2] ...
#   log_file: Path to the log file
#   work_dir: Path to the workspace directory
#   dir: Directory path to check (can specify multiple, all must exist)

LOG_FILE="$1"
WORK_DIR="$2"
shift 2
DIRS=("$@")

if [ -z "$WORK_DIR" ] || [ ${#DIRS[@]} -eq 0 ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <dir1> [dir2] ..." >&2
    exit 1
fi

# Check if all directories exist
for DIR in "${DIRS[@]}"; do
    if [ ! -d "$WORK_DIR/$DIR" ]; then
        exit 1
    fi
done

exit 0
