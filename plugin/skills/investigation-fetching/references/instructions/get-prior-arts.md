# Get Prior Arts

Retrieves prior art master data for a specific patent.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  pa.reference_id,
  pa.reference_type,
  pa.title,
  pa.publication_date
FROM prior_arts pa
JOIN prior_art_elements pae ON pa.reference_id = pae.reference_id
WHERE pae.patent_id = '<patent_id>'
ORDER BY pa.reference_type, pa.reference_id;
"
```

## Parameters

| Parameter | Type | Description            |
| --------- | ---- | ---------------------- |
| patent_id | TEXT | Patent number to query |

## Output Format

JSON array of prior arts:

```json
[
  {
    "reference_id": "US1234567B2",
    "reference_type": "patent",
    "title": "Similar technology patent",
    "publication_date": "2018-05-15"
  },
  {
    "reference_id": "arXiv:2305.13657",
    "reference_type": "npl",
    "title": "Academic paper on related technology",
    "publication_date": "2023-05-23"
  }
]
```

Empty array if no prior arts found:

```json
[]
```
