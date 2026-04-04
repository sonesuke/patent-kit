# Get Prior Art Statistics

## Purpose

Retrieve aggregate prior art research progress counts, scoped to Not Limited
patents (Significant/Moderate similarity only).

## Request Pattern

"Count prior art progress"

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  not_limited.all_count,
  COALESCE(resolved.resolved_count, 0) AS resolved_count,
  COALESCE(open_pat.open_count, 0) AS open_count,
  not_limited.all_count - COALESCE(resolved.resolved_count, 0) - COALESCE(open_pat.open_count, 0) AS pending_count
FROM (
  SELECT COUNT(*) AS all_count
  FROM (
    SELECT patent_id
    FROM similarities
    GROUP BY patent_id
    HAVING MAX(CASE similarity_level
      WHEN 'Significant' THEN 3
      WHEN 'Moderate' THEN 2
      WHEN 'Limited' THEN 1
    END) > 1
  )
) AS not_limited
LEFT JOIN (
  SELECT COUNT(DISTINCT patent_id) AS resolved_count
  FROM prior_art_elements
  WHERE relevance_level = 'Significant'
    AND patent_id IN (
      SELECT patent_id
      FROM similarities
      GROUP BY patent_id
      HAVING MAX(CASE similarity_level
        WHEN 'Significant' THEN 3
        WHEN 'Moderate' THEN 2
        WHEN 'Limited' THEN 1
      END) > 1
    )
) AS resolved ON 1 = 1
LEFT JOIN (
  SELECT COUNT(DISTINCT patent_id) AS open_count
  FROM prior_art_elements
  WHERE patent_id IN (
      SELECT patent_id
      FROM similarities
      GROUP BY patent_id
      HAVING MAX(CASE similarity_level
        WHEN 'Significant' THEN 3
        WHEN 'Moderate' THEN 2
        WHEN 'Limited' THEN 1
      END) > 1
    )
    AND patent_id NOT IN (
      SELECT DISTINCT patent_id
      FROM prior_art_elements
      WHERE relevance_level = 'Significant'
    )
) AS open_pat ON 1 = 1;
"
```

## Expected Output

JSON array with one row:

- `all_count`: Total Not Limited patents (Significant/Moderate similarity)
- `resolved_count`: Patents with prior art elements having Significant relevance
- `open_count`: Patents with prior art elements but none with Significant relevance
- `pending_count`: Not Limited patents with no prior art elements at all

## Verification

`all_count` = `resolved_count` + `open_count` + `pending_count`
