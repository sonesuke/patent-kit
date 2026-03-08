# Get Unscreened Patents

Retrieves list of patents that have not been screened yet.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT tp.patent_id FROM target_patents tp
LEFT JOIN screened_patents sp ON tp.patent_id = sp.patent_id
WHERE sp.patent_id IS NULL;
"
```

## Output Format

JSON array of patent_ids:

```json
[{"patent_id": "US20240292070A1"}, {"patent_id": "US20240346271A1"}]
```
