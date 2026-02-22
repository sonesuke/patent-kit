# Extract patent ID from target.jsonl
# Usage: .\extract-id.ps1 <LINE_NUM>

param([int]$LineNum)
Get-Content 1-targeting\target.jsonl | Select-Object -Index ($LineNum - 1) | jq -r '.id'
