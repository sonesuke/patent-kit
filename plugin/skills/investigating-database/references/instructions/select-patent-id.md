# Select Patent ID for Evaluation

Select the next patent ID for evaluation from the database.

## Purpose

Retrieve a patent ID that meets the following criteria:

- Marked as `relevant` in `screened_patents` table
- Does NOT have an evaluation report yet (no folder in `3-investigations/`)

## SQL Query

```bash
sqlite3 patents.db "
SELECT sp.patent_id
FROM screened_patents sp
LEFT JOIN (
    SELECT DISTINCT patent_id
    FROM (
        SELECT '3-investigations/' || SUBSTR(patent_id, 1, INSTR(patent_id, '-') - 1) || SUBSTR(patent_id, INSTR(patent_id, '-') + 1, INSTR(patent_id, '-', INSTR(patent_id, '-') + 1) - INSTR(patent_id, '-') - 1) || '-' || SUBSTR(patent_id, INSTR(patent_id, '-', INSTR(patent_id, '-') + 1) + 1) as patent_id
        FROM target_patents
        WHERE patent_id IN (
            SELECT SUBSTR(path, LENGTH('3-investigations/') + 1, INSTR(SUBSTR(path, LENGTH('3-investigations/') + 1), '/') - 1)
            FROM (
                SELECT path FROM fsdir WHERE path LIKE '3-investigations/%'
            )
        )
    )
) eval ON sp.patent_id = eval.patent_id
WHERE sp.judgment = 'relevant'
  AND eval.patent_id IS NULL
ORDER BY sp.screened_at ASC
LIMIT 1;
"
```

## Alternative: Check File System

For simpler implementation, check for existing evaluation directories:

```bash
# Get first relevant patent
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM screened_patents WHERE judgment = 'relevant' ORDER BY screened_at ASC LIMIT 1;")

# Check if evaluation already exists
if [ -d "3-investigations/${PATENT_ID}" ]; then
  # Try next patent
  PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM screened_patents WHERE judgment = 'relevant' AND patent_id > '${PATENT_ID}' ORDER BY screened_at ASC LIMIT 1;")
fi

echo "$PATENT_ID"
```

## Output

- **patent_id**: The patent ID to evaluate (or empty if no relevant patents without evaluation)

## Use Cases

- **Evaluation Phase**: Get the next patent to evaluate
- **Progress Tracking**: Find relevant patents that haven't been evaluated yet
