# Get Relevant Patents

Retrieves list of relevant patents from the database.

## Variations

### All Relevant Patents

```bash
sqlite3 -json patents.db "
SELECT patent_id FROM screened_patents
WHERE judgment = 'relevant';
"
```

### Relevant Patents Without Evaluation

```bash
sqlite3 -json patents.db "
SELECT patent_id FROM screened_patents
WHERE judgment = 'relevant'
  AND patent_id NOT IN (SELECT patent_id FROM claims);
"
```

## Output Format

JSON array of patent_ids:

```json
[{ "patent_id": "US20240292070A1" }, { "patent_id": "US20240346271A1" }]
```
