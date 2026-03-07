# Investigating Database - Troubleshooting

For detailed SQL queries and operation details, see the `instructions/` directory:

- [Initialize Database](./instructions/initialize-database.md)
- [Import CSV](./instructions/import-csv.md)
- [Get Patent ID](./instructions/get-patent-id.md)
- [Record Screening](./instructions/record-screening.md)
- [Get Statistics](./instructions/get-statistics.md)

## Common Issues and Solutions

### Issue: "sqlite3: command not found"

**Symptoms**:

- Scripts fail with error: "sqlite3: command not found"
- Exit code 1

**Cause**:
SQLite3 command-line tool is not installed or not in PATH.

**Solutions**:

**Linux (Debian/Ubuntu)**:

```bash
sudo apt-get update
sudo apt-get install sqlite3
```

**Linux (RHEL/CentOS)**:

```bash
sudo yum install sqlite
```

**macOS**:

```bash
brew install sqlite3
```

**Windows**:

1. Download SQLite from https://www.sqlite.org/download.html
2. Add sqlite3.exe to PATH or place in System32

**Verification**:

```bash
sqlite3 --version
```

### Issue: "Database not found" (Exit Code 2)

**Symptoms**:

- Scripts fail with error: "Database not found at patents.db"
- Exit code 2

**Cause**:
The database file doesn't exist or hasn't been initialized.

**Solutions**:

**Check if database exists**:

```bash
ls -la patents.db
```

**Initialize database**:

```bash
sqlite3 patents.db < plugin/skills/investigating-database/references/sql/initialize-database.sql
```

**Recreate database (WARNING: Deletes all data)**:

```bash
rm -f patents.db patents.db-wal patents.db-shm
sqlite3 patents.db < plugin/skills/investigating-database/references/sql/initialize-database.sql
```

### Issue: CSV Import Fails

**Symptoms**:

- "No CSV files found in directory"
- "Failed to import <filename>"
- Exit code 1

**Causes**:

1. No CSV files in specified directory
2. CSV files have incorrect format
3. Missing required columns

**Solutions**:

**Check CSV files exist**:

```bash
ls -la 1-targeting/csv/*.csv
```

**Verify CSV format**:

```bash
head -n 1 1-targeting/csv/patents.csv
```

Expected columns (at minimum):

```
patent_id,title
```

**Check CSV encoding**:

```bash
file 1-targeting/csv/patents.csv
```

Should be `UTF-8 Unicode text` or `ASCII text`.

**Validate CSV structure**:

```bash
# Check for required 'patent_id' column
head -n 1 1-targeting/csv/patents.csv | grep -q "patent_id" && echo "OK" || echo "Missing patent_id column"
```

**Import specific CSV file manually**:

```bash
sqlite3 patents.db <<EOF
.mode csv
.import 1-targeting/csv/patents.csv target_patents
EOF
```

### Issue: "Row number out of range" (Exit Code 3)

**Symptoms**:

- get-patent-id.sh fails with "Row number X is out of range"
- Exit code 3

**Cause**:
Requested row number exceeds the total number of patents in database.

**Solutions**:

**Check total patent count**:

```bash
sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;"
```

**Get last valid row number**:

```bash
COUNT=$(sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;")
echo "Last valid row: $COUNT"
```

**Handle out of range in script**:

```bash
ROW_NUMBER=100
TOTAL=$(sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;")
if [ $ROW_NUMBER -gt $TOTAL ]; then
    echo "Row $ROW_NUMBER exceeds total patents ($TOTAL)"
    exit 1
fi
OFFSET=$((ROW_NUMBER - 1))
PATENT_ID=$(sqlite3 patents.db "SELECT patent_id FROM target_patents ORDER BY patent_id LIMIT 1 OFFSET $OFFSET;")
```

### Issue: "Invalid judgment" When Recording Screening

**Symptoms**:

- "Error: Invalid judgment 'xyz'"
- Exit code 1

**Cause**:
Judgment value is not one of the allowed values: `relevant`, `irrelevant`, `expired`.

**Solutions**:

**Use correct judgment values**:

```bash
# Valid
sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at) VALUES ('US1234567A', 'relevant', 'Core tech', datetime('now'));"

# Invalid (will fail CHECK constraint)
sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at) VALUES ('US1234567A', 'valid', 'Core tech', datetime('now'));"
```

**Check existing judgments**:

```bash
sqlite3 patents.db "SELECT DISTINCT judgment FROM screened_patents;"
```

### Issue: "Patent ID not found in target_patents"

**Symptoms**:

- "Error: Patent ID 'US1234567A' not found in target_patents table"
- Exit code 1 when calling record-screening.sh

**Cause**:
Trying to record screening for a patent that doesn't exist in the database.

**Solutions**:

**Check if patent exists**:

```bash
sqlite3 patents.db "SELECT patent_id, title FROM target_patents WHERE patent_id = 'US1234567A';"
```

**Search for similar patent IDs**:

```bash
sqlite3 patents.db "SELECT patent_id FROM target_patents WHERE patent_id LIKE '%1234567%';"
```

**Import missing patents from CSV**:

```bash
sqlite3 patents.db <<EOF
.mode csv
.import 1-targeting/csv/patents.csv target_patents
EOF
```

### Issue: Large WAL Files

**Symptoms**:

- `patents.db-wal` grows very large
- Disk space concerns

**Cause**:
SQLite WAL (Write-Ahead Logging) file grows with transactions but isn't checkpointed.

**Solutions**:

**Check WAL file size**:

```bash
ls -lh patents.db patents.db-wal patents.db-shm
```

**Run checkpoint**:

```bash
sqlite3 patents.db "PRAGMA wal_checkpoint(TRUNCATE);"
```

**Schedule regular checkpoints** (in long-running scripts):

```bash
# Every 100 operations
sqlite3 patents.db "PRAGMA wal_checkpoint(TRUNCATE);"
```

**Disable WAL mode** (not recommended for concurrent access):

```bash
sqlite3 patents.db "PRAGMA journal_mode=DELETE;"
```

### Issue: Database Locked

**Symptoms**:

- "database is locked"
- Multiple processes trying to access database simultaneously

**Cause**:
SQLite allows multiple readers but only one writer at a time.

**Solutions**:

**Check for locks**:

```bash
lsof patents.db
```

**Wait and retry** (in scripts):

```bash
MAX_RETRIES=5
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, reason, updated_at) VALUES ('US123', 'relevant', 'Test', datetime('now'));" && break
    RETRY_COUNT=$((RETRY_COUNT + 1))
    sleep 1
done
```

**Use WAL mode** (enabled by default):

```bash
sqlite3 patents.db "PRAGMA journal_mode=WAL;"
```

### Issue: Slow Query Performance

**Symptoms**:

- Queries take too long on large datasets
- Statistics retrieval is slow

**Cause**:
Missing indexes or unoptimized queries.

**Solutions**:

**Check if indexes exist**:

```bash
sqlite3 patents.db ".indexes"
```

**Create missing indexes**:

```bash
sqlite3 patents.db "CREATE INDEX IF NOT EXISTS idx_target_patents_assignee ON target_patents(assignee);"
```

**Analyze query plan**:

```bash
sqlite3 patents.db "EXPLAIN QUERY PLAN SELECT * FROM target_patents WHERE assignee LIKE '%TechCorp%';"
```

**Run ANALYZE**:

```bash
sqlite3 patents.db "ANALYZE;"
```

**Use exact match instead of LIKE**:

```sql
-- Slow
SELECT * FROM target_patents WHERE assignee LIKE '%TechCorp%';

-- Fast (if exact match)
SELECT * FROM target_patents WHERE assignee = 'TechCorp Inc.';
```

### Issue: Inconsistent Statistics

**Symptoms**:

- Statistics view returns incorrect counts
- total_screened doesn't match sum of relevant/irrelevant/expired

**Cause**:
View definition is corrupted or out of date.

**Solutions**:

**Recreate view**:

```bash
sqlite3 patents.db "DROP VIEW IF EXISTS v_screening_progress;"
```

Then re-run schema initialization.

**Check individual counts**:

```bash
echo "Total screened: $(sqlite3 patents.db 'SELECT COUNT(*) FROM screened_patents;')"
echo "Relevant: $(sqlite3 patents.db 'SELECT COUNT(*) FROM screened_patents WHERE judgment = \"relevant\";')"
echo "Irrelevant: $(sqlite3 patents.db 'SELECT COUNT(*) FROM screened_patents WHERE judgment = \"irrelevant\";')"
echo "Expired: $(sqlite3 patents.db 'SELECT COUNT(*) FROM screened_patents WHERE judgment = \"expired\";')"
```

### Issue: Permission Denied

**Symptoms**:

- "Permission denied" when creating or accessing database
- Exit code 1

**Cause**:
Insufficient permissions on database file or directory.

**Solutions**:

**Check permissions**:

```bash
ls -la patents.db
```

**Fix permissions**:

```bash
chmod 644 patents.db
chmod 755 .  # Current directory
```

**Change ownership** (if needed):

```bash
sudo chown $USER:$USER patents.db
```

**Check disk space**:

```bash
df -h .
```

### Issue: Character Encoding Problems

**Symptoms**:

- Garbled text in patent titles or abstracts
- Question marks or special characters displayed incorrectly

**Cause**:
CSV files not in UTF-8 encoding.

**Solutions**:

**Check file encoding**:

```bash
file 1-targeting/csv/patents.csv
```

**Convert to UTF-8**:

```bash
iconv -f ISO-8859-1 -t UTF-8 1-targeting/csv/patents.csv > patents_utf8.csv
```

**Import with explicit encoding**:

```bash
# Set locale to UTF-8
export LANG=en_US.UTF-8
bash plugin/skills/investigating-database/scripts/shell/import-csv.sh
```

### Issue: Memory Issues with Large Datasets

**Symptoms**:

- Scripts hang or crash with large datasets (>10,000 patents)
- System becomes unresponsive

**Cause**:
Loading entire dataset into memory at once.

**Solutions**:

**Import in batches**:

```bash
# Split CSV into smaller files
split -l 1000 patents.csv patents_batch_

# Import each batch
for file in patents_batch_*; do
    sqlite3 patents.db <<EOF
.mode csv
.import "$file" target_patents
EOF
done
```

**Use batch inserts**:

```sql
BEGIN;
INSERT INTO screened_patents (id, title, judgment) VALUES ('US1', 'Test', 'relevant');
INSERT INTO screened_patents (id, title, judgment) VALUES ('US2', 'Test', 'relevant');
-- ... more inserts ...
COMMIT;
```

## Getting Help

If you encounter issues not covered here:

1. **Check SQLite version**:

   ```bash
   sqlite3 --version
   ```

   Minimum version: 3.35.0 (for WAL mode and UPSERT support)

2. **Enable SQLite logging**:

   ```bash
   sqlite3 patents.db "PRAGMA verbose;"
   ```

3. **Check database integrity**:

   ```bash
   sqlite3 patents.db "PRAGMA integrity_check;"
   ```

4. **Export schema for review**:

   ```bash
   sqlite3 patents.db ".schema"
   ```

5. **Review query output**:
   ```bash
   sqlite3 patents.db "SELECT * FROM v_screening_progress;" 2>&1 | tee debug.log
   ```
