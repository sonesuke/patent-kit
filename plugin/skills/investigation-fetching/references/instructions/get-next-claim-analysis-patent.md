# Get Next Patent for Claim Analysis

Retrieves the next patent that has evaluation.md but no claim-analysis.md yet.

## Command

```bash
find 3-investigations -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  patent_id=$(basename "$dir")
  if [ -f "$dir/evaluation.md" ] && [ ! -f "$dir/claim-analysis.md" ]; then
    echo "$patent_id"
    exit 0
  fi
done
```

## Output Format

Single patent_id or empty if no patents pending.

Example output:

```
US20240292070A1
```

No output if no patents pending.
