# Get Screening Statistics

Retrieves screening progress statistics.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  judgment,
  COUNT(*) as count
FROM screened_patents
GROUP BY judgment;
"
```

## Output Format

```json
[{"judgment": "relevant", "count": 5}, {"judgment": "not_relevant", "count": 10}]
```
