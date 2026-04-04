# Get Claim Analysis Statistics

## Purpose

Retrieve aggregate claim analysis progress counts.

## Request Pattern

"Count claim analysis progress"

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  COUNT(DISTINCT patent_id) AS all_count,
  SUM(CASE WHEN max_sim = 1 THEN 1 ELSE 0 END) AS limited_count,
  SUM(CASE WHEN max_sim > 1 THEN 1 ELSE 0 END) AS not_limited_count
FROM (
  SELECT
    patent_id,
    MAX(CASE similarity_level
      WHEN 'Significant' THEN 3
      WHEN 'Moderate' THEN 2
      WHEN 'Limited' THEN 1
    END) AS max_sim
  FROM similarities
  GROUP BY patent_id
);
"
```

## Expected Output

JSON array with one row:

- `all_count`: Total patents with similarity results
- `limited_count`: Patents where all similarities are Limited
- `not_limited_count`: Patents with at least one Significant or Moderate similarity
