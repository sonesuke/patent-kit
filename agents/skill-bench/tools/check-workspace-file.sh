#!/bin/bash
# Check if a file exists in the workspace
# Usage: check-workspace-file.sh <log_file> <work_dir> <file_path>
#   log_file: Path to the log file
#   work_dir: Path to the workspace directory
#   file_path: Relative path to the file to check

LOG_FILE="$1"
WORK_DIR="$2"
FILE_PATH="$3"

if [ -z "$WORK_DIR" ] || [ -z "$FILE_PATH" ]; then
    echo "[Error] Usage: $0 <log_file> <work_dir> <file_path>" >&2
    exit 1
fi

[ -f "$WORK_DIR/$FILE_PATH" ]
