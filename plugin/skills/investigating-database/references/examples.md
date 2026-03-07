# Investigating Database - Usage Examples

For detailed SQL queries and operations, see the `instructions/` directory:

- [Initialize Database](./instructions/initialize-database.md)
- [Import CSV](./instructions/import-csv.md)
- [Get Patent ID](./instructions/get-patent-id.md)
- [Record Screening](./instructions/record-screening.md)
- [Get Statistics](./instructions/get-statistics.md)

## Example 1: Initialize and Import Data

**Scenario**: Starting a new patent investigation with downloaded CSV files.

**Steps**:

```bash
# 1. Initialize the database (see instructions/initialize-database.md)
sqlite3 patents.db <<EOF
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
CREATE TABLE IF NOT EXISTS target_patents (...);
CREATE TABLE IF NOT EXISTS screened_patents (...);
CREATE VIEW IF NOT EXISTS v_screening_progress AS ...;
EOF

# 2. Import CSV files from targeting phase
sqlite3 patents.db <<EOF
.mode csv
.import 1-targeting/csv/patents.csv target_patents
EOF

# Verify import
sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;"
```

## Example 2: Screen Patents Sequentially

**Scenario**: Screening patents from row 1 to row 10.

**Steps**:

```bash
# Loop through rows 1-10
for ROW in {1..10}; do
    # Get patent ID (convert to 0-based offset)
    OFFSET=$((ROW - 1))
    PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")

    # Fetch patent details (using MCP tool)
    fetch-patent "$PATENT_ID"

    # Read and analyze patent
    # ... manual analysis ...

    # Record screening result
    sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at)
    VALUES ('$PATENT_ID', 'relevant', 'Core technology for LLM-based systems', datetime('now'));"
done

# Check progress
sqlite3 -json patents.db "SELECT * FROM v_screening_progress;"
```

**Output**:

```json
{
  "total_targets": 150,
  "total_screened": 10,
  "relevant": 7,
  "irrelevant": 2,
  "expired": 1
}
```

## Example 3: Generate Progress Report

**Scenario**: Creating a progress report for stakeholders.

**Steps**:

```bash
# Get statistics as JSON
sqlite3 -json patents.db "SELECT * FROM v_screening_progress;"
```

**Output**:

```
Screening Progress Statistics
============================
Total Targets:    150
Total Screened:   75

Breakdown:
  Relevant:       25
  Irrelevant:     40
  Expired:        10

Progress:         75/150 (50%)
```

## Example 4: Query Specific Patents

**Scenario**: Finding all patents from a specific assignee.

**Steps**:

```bash
# Direct SQL query
sqlite3 patents.db \
    "SELECT patent_id, title, publication_date FROM target_patents WHERE assignee LIKE '%TechCorp%' ORDER BY publication_date DESC;"
```

**Output**:

```
US9999999A|Advanced AI Systems|2023-10-15
US1234567A|Machine Learning Platform|2023-06-20
US7654321A|Neural Network Method|2022-12-01
```

## Example 5: Resume Screening After Interruption

**Scenario**: Screening was interrupted at row 50. Resume from row 51.

**Steps**:

```bash
# Get current screening count
SCREENED=$(sqlite3 patents.db "SELECT COUNT(*) FROM screened_patents;")
NEXT_ROW=$((SCREENED + 1))
OFFSET=$((NEXT_ROW - 1))

echo "Resuming from row $NEXT_ROW"

# Get next patent ID
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
echo "Next patent: $PATENT_ID"

# Continue screening...
```

## Example 6: Export Screened Patents

**Scenario**: Exporting all relevant patents for further analysis.

**Steps**:

```bash
# Export relevant patents to CSV
sqlite3 patents.db \
    -header -csv \
    "SELECT t.patent_id, t.title, s.reason, s.screened_at FROM screened_patents s JOIN target_patents t ON s.patent_id = t.patent_id WHERE s.judgment = 'relevant' ORDER BY s.screened_at DESC;" \
    > relevant_patents.csv

# Count exported
wc -l relevant_patents.csv
```

## Example 7: Bulk Screening with Predefined Judgments

**Scenario**: Importing screening results from an external source.

**Steps**:

```bash
# Assume results.csv has columns: patent_id,judgment,reason
while IFS=',' read -r PATENT_ID JUDGMENT REASON; do
    sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at)
    VALUES ('$PATENT_ID', '$JUDGMENT', '$REASON', datetime('now'));"
done < results.csv
```

## Example 8: Get Top Relevant Patents

**Scenario**: Identifying the most important relevant patents.

**Steps**:

```bash
# Query top 10 relevant patents by screening date
sqlite3 patents.db \
    -column \
    "SELECT t.patent_id, t.title, s.reason FROM screened_patents s JOIN target_patents t ON s.patent_id = t.patent_id WHERE s.judgment = 'relevant' ORDER BY s.screened_at DESC LIMIT 10;"
```

**Output**:

```
US9999999A  | Advanced AI Systems        | Core technology for LLM platforms
US1234567A  | Machine Learning Platform   | Critical for data processing
US7654321A  | Neural Network Method      | Essential for model training
...
```

## Example 9: Check for Expired Patents

**Scenario**: Quickly identifying expired patents during screening.

**Steps**:

```bash
# Get all patents with expired status
sqlite3 patents.db \
    -json \
    "SELECT patent_id, title, grant_date FROM target_patents WHERE grant_date < date('now', '-20 years');"
```

## Example 10: Database Maintenance

**Scenario**: Performing routine database maintenance.

**Steps**:

```bash
# Check database size
ls -lh patents.db

# Check WAL file size
ls -lh patents.db-wal

# Run checkpoint to reduce WAL size
sqlite3 patents.db "PRAGMA wal_checkpoint(TRUNCATE);"

# Analyze database for optimization
sqlite3 patents.db "ANALYZE;"

# Rebuild database for optimization
sqlite3 patents.db "VACUUM;"
```

## Example 11: Validation and Verification

**Scenario**: Verifying data integrity after import.

**Steps**:

```bash
# Check total count
echo "Total patents: $(sqlite3 patents.db 'SELECT COUNT(*) FROM target_patents;')"

# Check for duplicate patent_ids (should be 0 due to PRIMARY KEY)
echo "Duplicate patent_ids: $(sqlite3 patents.db 'SELECT patent_id, COUNT(*) FROM target_patents GROUP BY patent_id HAVING COUNT(*) > 1;')"

# Check for NULL required fields
echo "Missing titles: $(sqlite3 patents.db 'SELECT COUNT(*) FROM target_patents WHERE title IS NULL;')"

# Check data consistency
echo "Patents without assignee: $(sqlite3 patents.db 'SELECT COUNT(*) FROM target_patents WHERE assignee IS NULL OR assignee = "";')"
```

## Example 12: Integration with Other Skills

**Scenario**: Using investigating-database from within the screening skill.

**Flow**:

```
1. User: "Screen the patents"
2. Screening skill loads investigating-database skill
3. Request: "Get patent ID at row 5"
4. Investigating-database returns: "US1234567A"
5. Screening skill fetches patent and analyzes
6. Screening skill requests: "Record screening result for US1234567A: judgment=relevant, reason='Core technology'"
7. Investigating-database saves result
8. Screening skill requests: "Get statistics"
9. Investigating-database returns progress JSON
```
