#!/bin/bash
# extract-toml-test-prompt.sh - Extract test_prompt from TOML file
# Usage: extract-toml-test-prompt.sh <toml_file>

TOML_FILE="${1:-}"

if [ -z "$TOML_FILE" ]; then
    echo "[Error] Usage: $0 <toml_file>" >&2
    exit 1
fi

# Use Python to parse TOML and extract test_prompt
python3 <<PYTHON
import sys
import re

try:
    with open('$TOML_FILE', 'r') as f:
        content = f.read()

    # Find test_prompt value (handles both ''' and """ delimiters)
    match = re.search(r"test_prompt\s*=\s*['\"]{3}(.+?)['\"]{3}", content, re.DOTALL)
    if match:
        print(match.group(1), end='')
    else:
        sys.exit(1)
except Exception as e:
    sys.exit(1)
PYTHON
