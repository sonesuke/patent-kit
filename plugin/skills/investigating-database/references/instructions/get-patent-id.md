# Scene: Get Patent ID by Row Number

## Scenario

Retrieve a patent ID using 1-based row number for pagination.

## Key Components

### Main Query (OFFSET-based)

Converts 1-based row number to 0-based offset:

```sql
SELECT patent_id
FROM target_patents
ORDER BY patent_id
LIMIT 1 OFFSET <offset>;
```

**Offset Calculation**:

- Row 1 → OFFSET 0
- Row 2 → OFFSET 1
- Row N → OFFSET (N-1)

### Alternative: ROWID (Faster)

```sql
SELECT patent_id FROM target_patents WHERE ROWID = <row_number>;
```

**Warning**: `ROWID` may not be sequential after deletions.

## Usage

### Get Patent ID at Specific Row

```bash
# Row 1 (first patent)
sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET 0;"

# Row 5
sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET 4;"

# Row 10
sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET 9;"
```

### Using Variables

```bash
ROW_NUMBER=5
OFFSET=$((ROW_NUMBER - 1))
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
echo "Patent ID at row $ROW_NUMBER: $PATENT_ID"
```

### Using ROWID

```bash
sqlite3 patents.db "SELECT patent_id FROM target_patents WHERE ROWID = 5;"
```

## Parameters

| Parameter  | Type    | Description                     |
| ---------- | ------- | ------------------------------- |
| row_number | integer | 1-based row number (1, 2, ...)  |
| offset     | integer | 0-based offset (row_number - 1) |

## Output

Patent ID as plain text:

```
US1234567A
```

## Verification

```sql
-- Check total count (max valid row number)
SELECT COUNT(*) FROM target_patents;

-- Verify ordering
SELECT ROWID, patent_id FROM target_patents ORDER BY patent_id LIMIT 5;

-- Get specific row
SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET 9;
```

## Error Handling

### Row Number Out of Range

```bash
# Check if row number exceeds total
TOTAL=$(sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;")
ROW_NUMBER=100

if [ $ROW_NUMBER -gt $TOTAL ]; then
    echo "Row $ROW_NUMBER exceeds total patents ($TOTAL)"
    exit 1
fi

OFFSET=$((ROW_NUMBER - 1))
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
```

### Invalid Row Number

```bash
# Validate input is a positive integer
ROW_NUMBER="abc"

if ! [[ "$ROW_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "Error: Row number must be a positive integer"
    exit 1
fi
```

## Performance Notes

- **ORDER BY patent_id** ensures consistent ordering: O(N log N)
- For large datasets (>10,000 patents):
  - Add surrogate key with auto-increment
  - Use cached row numbers
  - Implement cursor-based pagination

## Example Workflows

### Sequential Screening

```bash
TOTAL=$(sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;")

for ROW in $(seq 1 $TOTAL); do
    OFFSET=$((ROW - 1))
    PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
    echo "Processing row $ROW: $PATENT_ID"
    # ... screening logic ...
done
```

### Resume from Interrupted Screening

```bash
# Get last screened row
SCREENED_COUNT=$(sqlite3 patents.db "SELECT COUNT(*) FROM screened_patents;")
NEXT_ROW=$((SCREENED_COUNT + 1))
OFFSET=$((NEXT_ROW - 1))

# Get next patent ID
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
echo "Resuming from row $NEXT_ROW: $PATENT_ID"
```
