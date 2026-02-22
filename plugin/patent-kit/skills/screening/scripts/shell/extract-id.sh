#!/bin/bash
# Extract patent ID from target.jsonl
# Usage: ./extract-id.sh <LINE_NUM>

LINE_NUM=$1
head -n "$LINE_NUM" 1-targeting/target.jsonl | tail -n 1 | jq -r '.id'
