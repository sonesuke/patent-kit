# Scene: Initialize Database

## Scenario

Create a new patent investigation database with the proper schema if it doesn't exist.

## SQL File

See [`../sql/initialize-database.sql`](../sql/initialize-database.sql) for the complete SQL script.

## Schema

For detailed table definitions, columns, and constraints, see [`../schema.md`](../schema.md).

## Usage

```bash
sqlite3 patents.db < ../sql/initialize-database.sql
```

## Parameters

None

## Output

- Creates `patents.db` file
- Creates `patents.db-wal` and `patents.db-shm` (WAL mode files)

## Recreate Database (WARNING: Deletes All Data)

```bash
rm -f patents.db patents.db-wal patents.db-shm
sqlite3 patents.db < ../sql/initialize-database.sql
```
