# Scene: Get Screening Statistics

## Scenario

Retrieve screening progress statistics from the database.

## Key Components

### Main Query (Using View)

```sql
SELECT * FROM v_screening_progress;
```

**Output Format** (JSON):

```json
{
  "total_targets": 150,
  "total_screened": 45,
  "relevant": 12,
  "irrelevant": 28,
  "expired": 5
}
```

### Additional Queries

#### Judgment Breakdown with Percentages

```sql
SELECT
    judgment,
    COUNT(*) as count,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM screened_patents) AS INTEGER) as percentage
FROM screened_patents
GROUP BY judgment
ORDER BY count DESC;
```

#### Top 10 Relevant Patents

```sql
SELECT
    t.patent_id,
    t.title,
    s.reason,
    s.screened_at
FROM screened_patents s
JOIN target_patents t ON s.patent_id = t.patent_id
WHERE s.judgment = 'relevant'
ORDER BY s.screened_at DESC
LIMIT 10;
```

#### Unscreened Patents

```sql
SELECT
    t.patent_id,
    t.title
FROM target_patents t
LEFT JOIN screened_patents s ON t.patent_id = s.patent_id
WHERE s.patent_id IS NULL
ORDER BY t.patent_id;
```

## Usage

### JSON Output (Default)

```bash
# Get statistics as JSON
sqlite3 -json patents.db "SELECT * FROM v_screening_progress;"

# Output:
# {"total_targets":150,"total_screened":45,"relevant":12,"irrelevant":28,"expired":5}
```

### Text Output (Human-Readable)

```bash
# Get statistics with formatted output
sqlite3 -column patents.db "SELECT * FROM v_screening_progress;"
```

### Custom Format with jq

```bash
sqlite3 -json patents.db "SELECT * FROM v_screening_progress;" | jq -r '
  "Screening Progress\n" +
  "  Total:   \(.total_targets)\n" +
  "  Screened: \(.total_screened)\n" +
  "  Relevant: \(.relevant)\n" +
  "  Irrelevant: \(.irrelevant)\n" +
  "  Expired:  \(.expired)\n" +
  "  Progress: \(.total_screened)/\(.total_targets) (\(.total_screened * 100 / .total_targets)%)"
'
```

## Data Source

The statistics are computed from the `v_screening_progress` view, which aggregates:

- **total_targets**: Count of all patents in `target_patents` table
- **total_screened**: Count of all patents in `screened_patents` table
- **relevant**: Count of patents with `judgment = 'relevant'`
- **irrelevant**: Count of patents with `judgment = 'irrelevant'`
- **expired**: Count of patents with `judgment = 'expired'`

## Verification

```sql
-- Verify view exists
SELECT name FROM sqlite_master WHERE type='view' AND name='v_screening_progress';

-- Check view definition
SELECT sql FROM sqlite_master WHERE type='view' AND name='v_screening_progress';

-- Verify counts match
SELECT 'target_patents' as table_name, COUNT(*) as count FROM target_patents
UNION ALL
SELECT 'screened_patents', COUNT(*) FROM screened_patents;
```

## Error Handling

### View Not Found

```bash
# Solution: Re-create view
sqlite3 patents.db <<EOF
CREATE VIEW IF NOT EXISTS v_screening_progress AS
SELECT
    (SELECT COUNT(*) FROM target_patents) as total_targets,
    (SELECT COUNT(*) FROM screened_patents) as total_screened,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant') as relevant,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'irrelevant') as irrelevant,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'expired') as expired;
EOF
```

### Inconsistent Counts

```bash
# Check for NULL judgment values
sqlite3 patents.db "SELECT COUNT(*) FROM screened_patents WHERE judgment IS NULL;"

# Fix NULL judgments
sqlite3 patents.db "UPDATE screened_patents SET judgment = 'irrelevant' WHERE judgment IS NULL;"
```

## Example Workflows

### Generate Progress Report

```bash
# Get statistics and parse
STATS=$(sqlite3 -json patents.db "SELECT * FROM v_screening_progress;")

# Extract values using jq
TOTAL_TARGETS=$(echo "$STATS" | jq -r '.total_targets')
TOTAL_SCREENED=$(echo "$STATS" | jq -r '.total_screened')
RELEVANT=$(echo "$STATS" | jq -r '.relevant')

# Calculate percentage
PERCENT=$((TOTAL_SCREENED * 100 / TOTAL_TARGETS))

echo "Progress: $TOTAL_SCREENED/$TOTAL_TARGETS ($PERCENT%)"
echo "Relevant patents found: $RELEVANT"
```

### Automated Progress Check

```bash
# Get statistics and check if screening is complete
STATS=$(sqlite3 -json patents.db "SELECT * FROM v_screening_progress;")
TOTAL_TARGETS=$(echo "$STATS" | jq -r '.total_targets')
TOTAL_SCREENED=$(echo "$STATS" | jq -r '.total_screened')

if [ "$TOTAL_SCREENED" -eq "$TOTAL_TARGETS" ]; then
    echo "All patents screened!"
else
    REMAINING=$((TOTAL_TARGETS - TOTAL_SCREENED))
    echo "Remaining: $REMAINING patents"
fi
```

### Export Statistics

```bash
# Get statistics as JSON
sqlite3 -json patents.db "SELECT * FROM v_screening_progress;" > stats.json

# Generate CSV report
sqlite3 -header -csv patents.db \
    "SELECT judgment, COUNT(*) as count,
     CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM screened_patents) AS INTEGER) as percentage
     FROM screened_patents GROUP BY judgment;" \
    > judgment_breakdown.csv
```

### Real-Time Monitoring

```bash
# Watch statistics change every 5 seconds
watch -n 5 'sqlite3 -column patents.db "SELECT * FROM v_screening_progress;"'
```
