# Get Patents Without Similarities

Retrieves list of patents that have elements but no similarities recorded yet.

## Variations

### List Patents Without Similarities

```bash
sqlite3 -json patents.db "
SELECT DISTINCT e.patent_id
FROM elements e
LEFT JOIN similarities s ON e.patent_id = s.patent_id
  AND e.claim_number = s.claim_number
  AND e.element_label = s.element_label
WHERE s.patent_id IS NULL;
"
```

### Count Patents Without Similarities

```bash
sqlite3 -json patents.db "
SELECT COUNT(DISTINCT e.patent_id) AS count
FROM elements e
LEFT JOIN similarities s ON e.patent_id = s.patent_id
  AND e.claim_number = s.claim_number
  AND e.element_label = s.element_label
WHERE s.patent_id IS NULL;
"
```

## Output Format

JSON array of patent_ids (for list queries):

```json
[{ "patent_id": "US20240292070A1" }, { "patent_id": "US20240346271A1" }]
```

JSON array with count (for count queries):

```json
[{ "count": 3 }]
```

Empty array if no patents pending:

```json
[]
```
