# Scene: Record Screening Result

## Scenario

Save or update a screening judgment in the `screened_patents` table.

## Key Components

### Main Query (UPSERT)

```sql
INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, abstract_text, updated_at)
VALUES (
    '<patent_id>',
    '<judgment>',
    '<reason>',
    '<abstract_text>',
    datetime('now')
);
```

**Features**:

- `INSERT OR REPLACE` provides UPSERT semantics
- `patent_id` is a FOREIGN KEY referencing `target_patents(patent_id)`
- `reason` and `abstract_text` are required (NOT NULL)
- `updated_at` automatically set to current timestamp

## Usage

### Direct SQL Execution

```bash
# Record screening result
sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, abstract_text, updated_at)
VALUES ('US1234567A', 'relevant', 'Core technology for LLM systems', 'Abstract content fetched during screening', datetime('now'));"
```

### Using Variables

```bash
PATENT_ID="US1234567A"
JUDGMENT="relevant"
REASON="Core technology for LLM systems"
ABSTRACT_TEXT="Abstract content here"

sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, abstract_text, updated_at)
VALUES ('$PATENT_ID', '$JUDGMENT', '$REASON', '$ABSTRACT_TEXT', datetime('now'));"
```

### Multi-Line SQL

```bash
sqlite3 patents.db <<EOF
INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, abstract_text, updated_at)
VALUES (
    'US1234567A',
    'relevant',
    'Core technology for LLM systems',
    'Abstract content here',
    datetime('now')
);
EOF
```

## Parameters

| Parameter     | Type   | Required | Default | Description                                                   |
| ------------- | ------ | -------- | ------- | ------------------------------------------------------------- |
| patent_id     | string | Yes      | -       | Patent ID (must exist in target_patents)                      |
| judgment      | string | Yes      | -       | One of: `relevant`, `irrelevant`, `expired`                   |
| reason        | string | Yes      | -       | Screening rationale (must NOT be NULL)                        |
| abstract_text | string | Yes      | -       | Abstract content (must NOT be NULL, fetched during screening) |

## Output

No output on success. To verify:

```sql
-- Check screening result
SELECT * FROM screened_patents WHERE patent_id = 'US1234567A';

-- Get full details with title (JOIN)
SELECT
    t.patent_id,
    t.title,
    s.judgment,
    s.reason,
    s.abstract_text
FROM screened_patents s
JOIN target_patents t ON s.patent_id = t.patent_id
WHERE s.patent_id = 'US1234567A';
```

## Validation

```sql
-- Check if patent exists before recording
SELECT COUNT(*) FROM target_patents WHERE patent_id = 'US1234567A';

-- Validate judgment value
SELECT DISTINCT judgment FROM screened_patents;

-- Verify record was saved
SELECT patent_id, judgment, reason, updated_at FROM screened_patents WHERE patent_id = 'US1234567A';
```

## Error Handling

### Patent Not Found (Foreign Key Constraint)

```bash
# Error: "FOREIGN KEY constraint failed"
# Solution: Import patent from CSV first (see import-csv.md)
EXISTS=$(sqlite3 patents.db "SELECT COUNT(*) FROM target_patents WHERE patent_id = 'US1234567A';")
if [ "$EXISTS" -eq 0 ]; then
    echo "Error: Patent US1234567A not found in target_patents"
    exit 1
fi
```

### Invalid Judgment

```bash
# Solution: Use only: relevant, irrelevant, expired
JUDGMENT="relevant"  # Valid
```

### Special Characters in Reason

```bash
# Escape single quotes by doubling
REASON="It''s a core technology"

sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at)
VALUES ('US1234567A', 'relevant', 'It''s a core technology', datetime('now'));"
```

## Data Integrity

### Foreign Key Constraint

```sql
FOREIGN KEY (patent_id) REFERENCES target_patents(patent_id) ON DELETE CASCADE
```

- `screened_patents.patent_id` references `target_patents.patent_id`
- `ON DELETE CASCADE`: Automatically deletes screening records when patent is deleted
- Ensures data integrity

### UPSERT Semantics

`INSERT OR REPLACE` guarantees:

- Unique entry (PRIMARY KEY constraint)
- Automatic update of existing records
- Only latest screening result is kept

## Query Examples with JOIN

### Get Screened Patents with Titles

```sql
SELECT
    t.patent_id,
    t.title,
    s.judgment,
    s.reason,
    s.abstract_text,
    s.screened_at
FROM screened_patents s
JOIN target_patents t ON s.patent_id = t.patent_id
ORDER BY s.screened_at DESC;
```

### Get Relevant Patents

```sql
SELECT
    t.patent_id,
    t.title,
    s.reason
FROM screened_patents s
JOIN target_patents t ON s.patent_id = t.patent_id
WHERE s.judgment = 'relevant'
ORDER BY s.screened_at DESC;
```

## Example Workflows

### Single Patent Screening

```bash
# Get patent ID
OFFSET=0
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")

# Fetch and analyze (using MCP tool)
# fetch-patent "$PATENT_ID"

# Record result
sqlite3 patents.db <<EOF
INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, abstract_text, updated_at)
VALUES (
    '$PATENT_ID',
    'relevant',
    'Core technology for multi-turn LLM systems',
    'Abstract content fetched during screening',
    datetime('now')
);
EOF
```

### Bulk Screening from File

```bash
# Assume results.csv has: patent_id,judgment,reason
while IFS=',' read -r PATENT_ID JUDGMENT REASON; do
    sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at)
    VALUES ('$PATENT_ID', '$JUDGMENT', '$REASON', datetime('now'));"
done < results.csv
```

### Update Existing Screening

```bash
# Change judgment from irrelevant to relevant
sqlite3 patents.db <<EOF
INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at)
VALUES (
    'US1234567A',
    'relevant',
    'Re-evaluated: Actually core technology after review',
    datetime('now')
);
EOF
```
