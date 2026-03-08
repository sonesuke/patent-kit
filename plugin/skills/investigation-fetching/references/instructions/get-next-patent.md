# Get Next Patent for Evaluation

Retrieves the next relevant patent that has not been evaluated yet.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT patent_id FROM screened_patents
WHERE judgment = 'relevant'
  AND patent_id NOT IN (SELECT patent_id FROM claims)
LIMIT 1;
"
```

## Output Format

JSON array with single patent_id:

```json
[{"patent_id": "US20240292070A1"}]
```

Empty array if no patents pending:

```json
[]
```
