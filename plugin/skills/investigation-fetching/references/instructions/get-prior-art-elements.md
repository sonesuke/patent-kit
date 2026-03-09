# Get Prior Art Elements

Retrieves element-level prior art mappings for a specific patent.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  pae.patent_id,
  pae.claim_number,
  pae.element_label,
  pae.reference_id,
  pa.reference_type,
  pa.title,
  pa.publication_date,
  pae.relevance_level,
  pae.analysis_notes,
  pae.claim_chart,
  pae.researched_at
FROM prior_art_elements pae
JOIN prior_arts pa ON pae.reference_id = pa.reference_id
WHERE pae.patent_id = '<patent_id>'
ORDER BY pae.claim_number, pae.element_label, pae.reference_id;
"
```

## Parameters

| Parameter | Type | Description             |
| --------- | ---- | ----------------------- |
| patent_id | TEXT | Patent number to query  |

## Output Format

JSON array of prior art elements:

```json
[
  {
    "patent_id": "US20240292070A1",
    "claim_number": 1,
    "element_label": "A",
    "reference_id": "US1234567B2",
    "reference_type": "patent",
    "title": "Similar technology patent",
    "publication_date": "2018-05-15",
    "relevance_level": "Significant",
    "analysis_notes": "Discloses similar feature",
    "claim_chart": "Element A -> Claim 1, col 5, line 10",
    "researched_at": "2024-03-09 12:00:00"
  }
]
```

Empty array if no prior art elements found:

```json
[]
```
