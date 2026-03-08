# Get Features

Retrieves all product/target features from the database.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  feature_name,
  description,
  category,
  presence
FROM features
ORDER BY feature_id;
"
```

## Output Format

JSON array of features:

```json
[
  {
    "feature_name": "Feature A",
    "description": "...",
    "category": "...",
    "presence": "present"
  },
  {
    "feature_name": "Feature B",
    "description": "...",
    "category": "...",
    "presence": "absent"
  }
]
```

Empty array if no features found:

```json
[]
```
