---
name: investigating-database
description: |
  Manages patent investigation database using SQLite.

  Triggered when:
  - The user asks to:
    * "initialize the database"
    * "import CSV files"
    * "get patent ID"
    * "record screening result"
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

## Skill Orchestration

### 1. Determine Operation

Based on the user request, select the appropriate database operation:

| Operation        | Trigger                                  | SQL Location                    |
| ---------------- | ---------------------------------------- | ------------------------------- |
| Initialize       | "initialize database", "create database" | `instructions/initialize-database.md` |
| Import CSV       | "import CSV", "load data"                | `instructions/import-csv.md`          |
| Get Patent ID    | "get patent ID", "fetch patent by row"   | `instructions/get-patent-id.md`       |
| Record Screening | "record screening", "save result"        | `instructions/record-screening.md`    |
| Get Statistics   | "get statistics", "show progress"        | `instructions/get-statistics.md`      |

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

1. Execute SQL from `instructions/initialize-database.md`
2. Import CSV: `sqlite3 patents.db ".import 1-targeting/csv/patents.csv target_patents"`

### Workflow 2: Screen Patents

1. Get patent ID: `sqlite3 patents.db "SELECT id FROM target_patents ORDER BY id LIMIT 1 OFFSET 0;"`
2. Fetch patent details using `fetch-patent` MCP tool
3. Record result: Use SQL from `instructions/record-screening.md`

### Workflow 3: Report Progress

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
  - `initialize-database.md`: Database schema creation
  - `import-csv.md`: CSV file import
  - `get-patent-id.md`: Patent ID retrieval by row number
  - `record-screening.md`: Screening result recording
  - `get-statistics.md`: Progress statistics retrieval
- **examples.md**: Usage examples and workflows
- **troubleshooting.md**: Common issues and solutions
