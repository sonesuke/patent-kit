# Get Evaluation Progress

Retrieves evaluation progress statistics.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant') as total_relevant,
  (SELECT COUNT(DISTINCT patent_id) FROM claims) as evaluated,
  (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant')
    - (SELECT COUNT(DISTINCT patent_id) FROM claims) as pending;
"
```

## Output Format

```json
[{"total_relevant": 10, "evaluated": 5, "pending": 5}]
```
