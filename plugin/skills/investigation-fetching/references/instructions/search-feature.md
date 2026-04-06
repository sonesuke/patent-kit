# Search Feature

Searches for a matching feature by keyword against both feature name and description.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  feature_name,
  description,
  category,
  presence
FROM features
WHERE feature_name LIKE '%<search_term>%' OR description LIKE '%<search_term>%';
"
```

## Parameters

| Parameter   | Type | Description                                          |
| ----------- | ---- | ---------------------------------------------------- |
| search_term | TEXT | Keyword to match against feature_name or description |

## Output Format

Matching feature records:

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
