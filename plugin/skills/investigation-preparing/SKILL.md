---
name: investigation-preparing
description: |
  Manages patent investigation database preparation operations using SQLite.

  IMPORTANT: This skill should be invoked via the Skill tool for database operations.
  DO NOT read internal instruction files (references/instructions/*.md) directly.

  Supported operations:
  - "Initialize the database"
  - "Import CSV files from <directory>"
  - "Get patent ID at row <number>"
  - "Select next patent for evaluation"
  - "Get statistics"

  This skill handles all database preparation operations. Just provide the request
  and let the skill manage the database.
user_invocable: false
metadata:
  author: sonesuke
  version: 1.0.0
context: fork
---

# Patent Investigation Database - Preparing Operations

## For External Skills and Agents

**WARNING**: DO NOT read files from `references/instructions/` directory. Those are
internal reference files for this skill's internal use only.

**To use this skill**:

1. Invoke via Skill tool: `Skill: investigation-preparing`
2. Provide your request with data
3. The skill will handle all SQL operations automatically

**Example requests**:

- "Initialize the database"
- "Import CSV files from 1-targeting/csv/ directory"
- "Get patent ID at row 5"
- "Select next patent for evaluation"
- "Get statistics on screening progress"
- "Execute SQL query: SELECT COUNT(\*) FROM screened_patents"

## Purpose

Manages database preparation operations for the SQLite database (`patents.db`)
in the working directory, including initialization, data import, and data retrieval.

## Internal Reference (For This Skill Only)

The following sections are for the skill's internal operations when processing
requests from external agents.

### Database Prerequisites

- SQLite3 command must be available
- Workspace root must be writable for database creation

### Database Initialization

**IMPORTANT**: Before executing any database operation, verify that `patents.db`
exists and is properly initialized.

#### Check Database Status

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

#### Initialize Database (if needed)

If `patents.db` does not exist or has an invalid schema:

```bash
sqlite3 patents.db < references/sql/initialize-database.sql
```

This command creates all necessary tables (`target_patents`, `screened_patents`,
`claims`, `elements`), views, and triggers.

### Internal Operation Mapping (For This Skill Only)

When processing external requests, map them to internal instruction files:

| External Request               | Internal Reference File                     |
| ------------------------------ | ------------------------------------------- |
| "Initialize database"          | SKILL.md → Database Initialization          |
| "Import CSV files..."          | references/instructions/import-csv.md       |
| "Get patent ID at row..."      | references/instructions/get-patent-id.md    |
| "Select patent for evaluation" | references/instructions/select-patent-id.md |
| "Get statistics"               | references/instructions/get-statistics.md   |

**CRITICAL**: These reference files are for INTERNAL USE ONLY. External agents
should invoke via Skill tool, not read these files.

### SQL Execution (Internal Use Only)

When executing SQL operations based on internal reference files:

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

### Output Formats

- **JSON output**: Use `sqlite3 -json` for programmatic use
- **Text output**: Use `sqlite3 -column` for human-readable format
- **CSV output**: Use `sqlite3 -header -csv` for CSV export

## Internal Workflows (For This Skill Only)

### Workflow 1: Initialize and Import

1. External: "Initialize the database and import CSV files from 1-targeting/csv/"
2. Internal: Check database status → Execute import-csv.md instructions

### Workflow 2: Get Patent ID

1. External: "Get patent ID at row 5"
2. Internal: Execute get-patent-id.md → Return patent ID

### Workflow 3: Select Patent for Evaluation

1. External: "Select next patent for evaluation"
2. Internal: Execute select-patent-id.md → Return patent ID

### Workflow 4: Get Statistics

1. External: "Get statistics on screening progress"
2. Internal: Execute get-statistics.md → Return JSON statistics

## State Management

### Initial State

- No `patents.db` file exists

### Final State

- `patents.db` created with proper schema in working directory
- Data imported from CSV files (if provided)
- Database queries executed successfully

## Internal References (For This Skill Only)

These files are for the skill's internal use when processing requests. External
agents should NOT read these:

- **references/instructions/**: Operation-based documentation (SQL queries and operations)
  - `import-csv.md`: CSV file import with ETL processing
  - `get-patent-id.md`: Patent ID retrieval by row number
  - `select-patent-id.md`: Select next patent for evaluation (relevant, not yet evaluated)
  - `get-statistics.md`: Progress statistics retrieval
  - `execute-sql-with-retry.md`: Generic SQL execution with retry logic
- **references/sql/**: SQL schema and query files
  - `initialize-database.sql`: Database schema definition
- **references/schema.md**: Database schema documentation

**IMPORTANT**: External agents should invoke this skill via the Skill tool, not
access these internal files directly.
