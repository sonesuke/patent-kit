# Record Prior Arts

Record prior art master data to the database.

## Purpose

Store prior art reference data (patent and non-patent literature) before linking to patent elements.

## SQL Command

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO prior_arts (reference_id, reference_type, title, publication_date, created_at, updated_at)
VALUES
  ('<reference_id>', '<reference_type>', '<title>', '<publication_date>', datetime('now'), datetime('now'))
;
"
```

For batch insert:

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO prior_arts (reference_id, reference_type, title, publication_date, created_at, updated_at)
VALUES
  ('<reference_id_1>', '<reference_type_1>', '<title_1>', '<publication_date_1>', datetime('now'), datetime('now')),
  ('<reference_id_2>', '<reference_type_2>', '<title_2>', '<publication_date_2>', datetime('now'), datetime('now'))
;
"
```

## Parameters

| Parameter        | Type | Description                                                 |
| ---------------- | ---- | ----------------------------------------------------------- |
| reference_id     | TEXT | Prior art reference ID (e.g., US1234567A, arXiv:2305.13657) |
| reference_type   | TEXT | Reference type: 'patent' or 'npl'                           |
| title            | TEXT | Title of the prior art reference                            |
| publication_date | TEXT | Publication date (ISO 8601 format: YYYY-MM-DD)              |

## Output Format

Returns count of inserted prior arts:

```
{"rows_affected": 2}
```

## Use Cases

- **Prior Art Search Phase**: Record discovered prior art references
- **Literature Collection**: Store both patent and non-patent literature references
- **Reference Management**: Maintain master list of prior art sources

## Verification Query

Check inserted prior arts:

```sql
SELECT
  reference_id,
  reference_type,
  title,
  publication_date,
  created_at
FROM prior_arts
WHERE reference_id = '<reference_id>';
```

## Error Handling

- **Error**: Failed to insert prior art (check reference_id is unique)
- **Error**: Invalid reference_type (must be 'patent' or 'npl')
- **Error**: Invalid publication_date format (must be YYYY-MM-DD or NULL)
