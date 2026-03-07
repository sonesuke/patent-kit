# Scene: Initialize Database

## Scenario

Create a new patent investigation database with the proper schema if it doesn't exist.

## Execution

**IMPORTANT**: Do NOT read the SQL file content. Execute directly:

```bash
sqlite3 patents.db < references/sql/initialize-database.sql
```

This single command creates all necessary tables, views, and triggers.

## Output

- Creates `patents.db` file
- Creates `patents.db-wal` and `patents.db-shm` (WAL mode files)
