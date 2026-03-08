# Record Similarities

Record claim analysis similarity results to the database.

## Purpose

Store similarity analysis results comparing product features against patent elements for each analyzed patent.

## SQL Command

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO similarities (patent_id, claim_number, element_label, similarity_level, analysis_notes, overall_similarity, analyzed_at, updated_at)
VALUES
  ('<patent_id>', <claim_number>, '<element_label>', '<similarity_level>', '<analysis_notes>', '<overall_similarity>', datetime('now'), datetime('now'))
;
"
```

For batch insert:

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO similarities (patent_id, claim_number, element_label, similarity_level, analysis_notes, overall_similarity, analyzed_at, updated_at)
VALUES
  ('<patent_id>', <claim_number_1>, '<element_label_1>', '<similarity_level_1>', '<analysis_notes_1>', '<overall_similarity>', datetime('now'), datetime('now')),
  ('<patent_id>', <claim_number_2>, '<element_label_2>', '<similarity_level_2>', '<analysis_notes_2>', '<overall_similarity>', datetime('now'), datetime('now'))
;
"
```

## Parameters

| Parameter          | Type    | Description                                                    |
| ------------------ | ------- | -------------------------------------------------------------- |
| patent_id          | TEXT    | Patent number (must exist in screened_patents)                 |
| claim_number       | INTEGER | Claim number (must exist in claims)                            |
| element_label      | TEXT    | Element label (must exist in elements, e.g., 'A', 'B', 'C')    |
| similarity_level   | TEXT    | Similarity level: 'Significant', 'Moderate', or 'Limited'      |
| analysis_notes     | TEXT    | Detailed analysis notes explaining the similarity assessment   |
| overall_similarity | TEXT    | Overall similarity level for the patent (same values as above) |

## Output Format

Returns count of inserted similarities:

```
{"rows_affected": 2}
```

## Use Cases

- **Claim Analysis Phase**: Record similarity analysis after comparing product features against patent elements
- **Element Comparison**: Track similarity levels for each constituent element
- **Overall Assessment**: Store overall similarity judgment for the patent

## Verification Query

Check inserted similarities:

```sql
SELECT
  patent_id,
  claim_number,
  element_label,
  similarity_level,
  analysis_notes,
  overall_similarity,
  analyzed_at
FROM similarities
WHERE patent_id = '<patent_id>'
ORDER BY claim_number, element_label;
```

## Error Handling

- **Error**: Failed to insert similarities (check patent_id, claim_number, and element_label exist in their respective tables)
- **Error**: Invalid similarity_level (must be 'Significant', 'Moderate', or 'Limited')
