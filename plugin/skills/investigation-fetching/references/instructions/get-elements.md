# Get Elements for Patent

Retrieves all constituent elements for a specific patent from the database.

## SQL Query

```bash
sqlite3 -json patents.db "
SELECT
  claim_number,
  element_label,
  element_description
FROM elements
WHERE patent_id = '<patent_id>'
ORDER BY claim_number, element_label;
"
```

## Output Format

JSON array of elements:

```json
[
  { "claim_number": 1, "element_label": "A", "element_description": "..." },
  { "claim_number": 1, "element_label": "B", "element_description": "..." }
]
```

Empty array if no elements found:

```json
[]
```
