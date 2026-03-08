# Search Feature

Searches for a specific feature by name in the database.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  feature_name,
  description,
  category,
  presence
FROM features
WHERE feature_name = '<feature_name>';
"
```

## Output Format

Single feature record if found:

```json
[
  {
    "feature_name": "Feature A",
    "description": "...",
    "category": "...",
    "presence": "present"
  }
]
```

Empty array if not found:

```json
[]
```
