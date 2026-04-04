# Get Patents Without Prior Arts

Retrieves list of patents with Moderate/Significant similarities but no prior art
elements recorded yet.

## Variations

### List Patents Without Prior Arts

```bash
sqlite3 -json patents.db "
SELECT DISTINCT e.patent_id
FROM elements e
WHERE e.patent_id IN (
  SELECT s.patent_id
  FROM similarities s
  GROUP BY s.patent_id
  HAVING SUM(CASE WHEN s.similarity_level = 'Limited' THEN 1 ELSE 0 END) = 0
)
AND e.patent_id NOT IN (
  SELECT patent_id FROM prior_art_elements
);
"
```

### Count Patents Without Prior Arts

```bash
sqlite3 -json patents.db "
SELECT COUNT(DISTINCT e.patent_id) AS count
FROM elements e
WHERE e.patent_id IN (
  SELECT s.patent_id
  FROM similarities s
  GROUP BY s.patent_id
  HAVING SUM(CASE WHEN s.similarity_level = 'Limited' THEN 1 ELSE 0 END) = 0
)
AND e.patent_id NOT IN (
  SELECT patent_id FROM prior_art_elements
);
"
```

## Output Format

JSON array of patent_ids (for list queries):

```json
[{ "patent_id": "US20240292070A1" }, { "patent_id": "US20240346271A1" }]
```

JSON array with count (for count queries):

```json
[{ "count": 2 }]
```

Empty array if no patents pending:

```json
[]
```

## Notes

- Filters for patents where all similarities are Moderate/Significant (no Limited)
- Excludes patents that already have prior art elements recorded
- Returns patents ready for prior art search phase
