# Record Features

Record product/target features to the database.

## SQL Command

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO features (feature_name, description, category, presence, created_at, updated_at)
VALUES
  ('<feature_name>', '<description>', '<category>', '<presence>', datetime('now'), datetime('now'))
;
"
```

For batch insert:

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO features (feature_name, description, category, presence, created_at, updated_at)
VALUES
  ('<feature_name_1>', '<description_1>', '<category_1>', '<presence_1>', datetime('now'), datetime('now')),
  ('<feature_name_2>', '<description_2>', '<category_2>', '<presence_2>', datetime('now'), datetime('now'))
;
"
```

## Parameters

| Parameter    | Type | Description                             |
| ------------ | ---- | --------------------------------------- |
| feature_name | TEXT | Feature name/label (must be unique)     |
| description  | TEXT | Detailed feature description            |
| category     | TEXT | Feature category (optional)             |
| presence     | TEXT | Feature presence: 'present' or 'absent' |

## Output Format

Returns count of inserted features:

```
{"rows_affected": 2}
```

## Use Cases

- **Feature Registration**: Record product features for claim analysis comparison
- **Batch Registration**: Register multiple features at once
- **Feature Update**: Update existing feature using INSERT OR REPLACE

## Verification Query

Check inserted features:

```sql
SELECT
  feature_id,
  feature_name,
  description,
  category,
  created_at
FROM features
ORDER BY feature_id;
```

## Error Handling

- **Error**: Failed to insert features (check feature_name is unique)
- **Error**: feature_name or description is NULL
