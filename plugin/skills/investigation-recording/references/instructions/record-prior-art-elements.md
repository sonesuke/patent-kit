# Record Prior Art Elements

Record element-level prior art mappings to the database.

## Purpose

Store mappings between patent elements and prior art references, including relevance assessment and claim charts.

## Prerequisites

- Prior art reference must exist in `prior_arts` table (use `record-prior-arts.md` first)
- Patent element must exist in `elements` table

## SQL Command

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO prior_art_elements (patent_id, claim_number, element_label, reference_id, relevance_level, analysis_notes, claim_chart, researched_at, updated_at)
VALUES
  ('<patent_id>', <claim_number>, '<element_label>', '<reference_id>', '<relevance_level>', '<analysis_notes>', '<claim_chart>', datetime('now'), datetime('now'))
;
"
```

For batch insert:

```bash
sqlite3 patents.db "
INSERT OR REPLACE INTO prior_art_elements (patent_id, claim_number, element_label, reference_id, relevance_level, analysis_notes, claim_chart, researched_at, updated_at)
VALUES
  ('<patent_id>', <claim_number_1>, '<element_label_1>', '<reference_id_1>', '<relevance_level_1>', '<analysis_notes_1>', '<claim_chart_1>', datetime('now'), datetime('now')),
  ('<patent_id>', <claim_number_2>, '<element_label_2>', '<reference_id_2>', '<relevance_level_2>', '<analysis_notes_2>', '<claim_chart_2>', datetime('now'), datetime('now'))
;
"
```

## Parameters

| Parameter       | Type    | Description                                                  |
| --------------- | ------- | ------------------------------------------------------------ |
| patent_id       | TEXT    | Target patent number (must exist in screened_patents)       |
| claim_number    | INTEGER | Claim number (must exist in claims)                          |
| element_label   | TEXT    | Element label (must exist in elements, e.g., 'A', 'B', 'C')  |
| reference_id    | TEXT    | Prior art reference ID (must exist in prior_arts)            |
| relevance_level | TEXT    | Relevance level: 'Significant', 'Moderate', or 'Limited'     |
| analysis_notes  | TEXT    | Detailed analysis notes explaining the relevance assessment   |
| claim_chart     | TEXT    | Claim chart comparing prior art to target patent elements    |

## Output Format

Returns count of inserted prior art elements:

```
{"rows_affected": 2}
```

## Use Cases

- **Prior Art Analysis Phase**: Record element-level prior art mappings
- **Relevance Assessment**: Track relevance levels for each element-prior art pair
- **Claim Chart Creation**: Store detailed claim charts for invalidity analysis

## Verification Query

Check inserted prior art elements:

```sql
SELECT
  pae.patent_id,
  pae.claim_number,
  pae.element_label,
  pae.reference_id,
  pa.reference_type,
  pa.title,
  pae.relevance_level,
  pae.analysis_notes,
  pae.researched_at
FROM prior_art_elements pae
JOIN prior_arts pa ON pae.reference_id = pa.reference_id
WHERE pae.patent_id = '<patent_id>'
ORDER BY pae.claim_number, pae.element_label, pae.reference_id;
```

## Error Handling

- **Error**: Failed to insert prior art element (check patent_id, claim_number, element_label exist in their respective tables)
- **Error**: Failed to insert prior art element (check reference_id exists in prior_arts table)
- **Error**: Invalid relevance_level (must be 'Significant', 'Moderate', or 'Limited')
