# Get Screening Statistics

## Purpose

Retrieve aggregate screening progress counts from the database.

## Request Pattern

"Count screening progress"

## SQL Query

```bash
sqlite3 -json patents.db "SELECT * FROM v_screening_progress"
```

## Expected Output

JSON array with one row:

- `total_targets`: Total patents in targeting
- `total_screened`: Total patents screened
- `relevant`: Relevant patent count
- `irrelevant`: Irrelevant patent count
- `expired`: Expired patent count
