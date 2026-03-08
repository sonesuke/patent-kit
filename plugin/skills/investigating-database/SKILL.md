---
name: investigating-database
description: |
  Manages patent investigation database using SQLite.

  Triggered when:
  - The user asks to:
    * "initialize the database"
    * "import CSV files"
    * "get patent ID"
    * "select patent ID for evaluation"
    * "record screening result"
    * "record claims"
    * "record elements"
    * "record evaluation result"
    * "get statistics"
  - Other skills need database operations
context: fork
metadata:
  author: sonesuke
  version: 1.0.0
---

# Patent Investigation Database

## Purpose

Manages the SQLite database (`patents.db`) for storing and retrieving patent data throughout the investigation lifecycle.

## Prerequisites

- SQLite3 command must be available
- Workspace root must be writable for database creation

## Database Initialization

**IMPORTANT**: Before executing any database operation, verify that `patents.db` exists and is properly initialized.

### Check Database Status

```bash
# Check if database exists and has the required tables
if [ ! -f patents.db ]; then
    echo "Database not found. Initializing..."
    sqlite3 patents.db < references/sql/initialize-database.sql
else
    # Verify schema
    sqlite3 patents.db ".tables"
fi
```

### Initialize Database (if needed)

If `patents.db` does not exist or has an invalid schema:

```bash
sqlite3 patents.db < references/sql/initialize-database.sql
```

This command creates all necessary tables (`target_patents`, `screened_patents`), views, and triggers.

## Skill Orchestration

### 1. Determine Operation

Based on the user request, select the appropriate database operation:

| Operation              | Trigger                                       | Instruction File Path                          |
| ---------------------- | --------------------------------------------- | ---------------------------------------------- |
| Initialize             | Database not found (auto-check)               | SKILL.md → Database Initialization section     |
| Import CSV             | "import CSV", "load data"                     | `references/instructions/import-csv.md`        |
| Get Patent ID          | "get patent ID", "fetch patent by row"        | `references/instructions/get-patent-id.md`     |
| Select Patent for Eval | "select patent ID", "next patent to evaluate" | `references/instructions/select-patent-id.md`  |
| Record Screening       | "record screening", "save result"             | `references/instructions/record-screening.md`  |
| Record Claims          | "record claims", "save claims"                | `references/instructions/record-claims.md`     |
| Record Elements        | "record elements", "save elements"            | `references/instructions/record-elements.md`   |
| Record Evaluation      | "record evaluation", "save evaluation result" | `references/instructions/record-evaluation.md` |
| Get Statistics         | "get statistics", "show progress"             | `references/instructions/get-statistics.md`    |

**IMPORTANT**: Always use the full path starting with `references/instructions/` to avoid file search delays.

### 2. Execute SQL Query

Use the Bash tool to execute SQLite commands:

```bash
sqlite3 patents.db "<SQL_QUERY>"
```

For multi-line SQL:

```bash
sqlite3 patents.db <<EOF
<SQL_QUERY_1>;
<SQL_QUERY_2>;
...
EOF
```

### 3. Return Results

- **JSON output**: Use `sqlite3 -json` for programmatic use
- **Text output**: Use `sqlite3 -column` for human-readable format
- **CSV output**: Use `sqlite3 -header -csv` for CSV export

## Common Workflows

### Workflow 1: Initialize and Import

1. **Check database status** (SKILL.md → Database Initialization)
2. **Import CSV** (Follow `references/instructions/import-csv.md`)

### Workflow 2: Screen Patents

1. Get patent ID: `sqlite3 patents.db "SELECT id FROM target_patents ORDER BY id LIMIT 1 OFFSET 0;"`
2. Fetch patent details using `fetch-patent` MCP tool
3. Record result: Use SQL from `instructions/record-screening.md`

### Workflow 3: Evaluate Patents

1. Select patent ID: `references/instructions/select-patent-id.md` (find relevant, not yet evaluated)
2. Fetch patent details using `google-patent-cli:patent-fetch` MCP tool
3. Record claims: Use SQL from `instructions/record-claims.md`
4. Record elements: Use SQL from `instructions/record-elements.md`
5. Record evaluation: Use SQL from `instructions/record-evaluation.md`

### Workflow 4: Report Progress

1. Execute SQL from `instructions/get-statistics.md`
2. Parse JSON output for reporting

## State Management

### Initial State

- No `patents.db` file exists

### Final State

- `patents.db` created with proper schema
- Data imported from CSV files (if provided)
- Screening results recorded (if executed)

## References

See `references/` directory for:

- **instructions/**: Operation-based documentation (SQL queries and operations)
  - `import-csv.md`: CSV file import with ETL processing
  - `get-patent-id.md`: Patent ID retrieval by row number
  - `select-patent-id.md`: Select next patent for evaluation (relevant, not yet evaluated)
  - `record-screening.md`: Screening result recording
  - `record-claims.md`: Patent claims recording
  - `record-elements.md`: Constituent elements recording
  - `record-evaluation.md`: Evaluation completion recording
  - `get-statistics.md`: Progress statistics retrieval
- **sql/**: SQL schema and query files
  - `initialize-database.sql`: Database schema definition
- **examples.md**: Usage examples and workflows
- \*\*troubleshooting.md`: Common issues and solutions
