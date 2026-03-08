# Record Evaluation Result

Record evaluation completion in the database.

## Purpose

Track which patents have been evaluated to support resume functionality and progress tracking.

## Database Schema

Note: Current schema does not have an `evaluated_patents` table. This operation records completion by checking for the existence of evaluation report files.

## Implementation

### Option 1: File System Check (Current)

Verify evaluation report exists:

```bash
# Check if evaluation directory exists
if [ -d "3-investigations/${PATENT_ID}" ]; then
    echo "Evaluation recorded for ${PATENT_ID}"
else
    echo "Evaluation not found for ${PATENT_ID}"
    exit 1
fi
```

### Option 2: Add evaluated_patents Table (Future)

If needed, add a new table to track evaluations:

```sql
CREATE TABLE IF NOT EXISTS evaluated_patents (
    patent_id TEXT PRIMARY KEY NOT NULL,
    evaluated_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE
);

CREATE TRIGGER update_evaluated_patents_timestamp
AFTER UPDATE ON evaluated_patents
FOR EACH ROW
BEGIN
    UPDATE evaluated_patents SET updated_at = datetime('now') WHERE patent_id = NEW.patent_id;
END;
```

Then record evaluation:

```bash
sqlite3 patents.db "INSERT OR REPLACE INTO evaluated_patents (patent_id) VALUES ('${PATENT_ID}');"
```

## Use Cases

- **Evaluation Phase**: Record completion after evaluation report is created
- **Progress Tracking**: Track which relevant patents have been evaluated
- **Resume Support**: Identify next patent for evaluation (used by select-patent-id.md)

## Output

- **Success**: Evaluation recorded for patent_id
- **Error**: Failed to record evaluation

## Next Steps

After recording evaluation:

- Proceed to next patent evaluation
- Or return to user with completion summary
