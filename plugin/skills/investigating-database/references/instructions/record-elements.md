# Record Elements

Record claim constituent elements to the database during evaluation.

## Purpose

Store analyzed claim elements for future reference and comparison.

## SQL Insert

```bash
sqlite3 patents.db <<EOF
INSERT INTO elements (patent_id, claim_number, element_label, element_description)
VALUES
  ('${PATENT_ID}', ${CLAIM_NUMBER}, '${ELEMENT_LABEL}', '${ELEMENT_DESCRIPTION}');
EOF
```

For multiple elements (recommended):

```bash
sqlite3 patents.db <<EOF
INSERT INTO elements (patent_id, claim_number, element_label, element_description) VALUES
  ('${PATENT_ID}', ${CLAIM_NUMBER}, 'A', 'Element A description'),
  ('${PATENT_ID}', ${CLAIM_NUMBER}, 'B', 'Element B description'),
  ('${PATENT_ID}', ${CLAIM_NUMBER}, 'C', 'Element C description');
EOF
```

## Parameters

- **PATENT_ID**: Patent identifier (e.g., "US20240292070A1")
- **CLAIM_NUMBER**: Claim number (1, 2, 3...)
- **ELEMENT_LABEL**: Element label (A, B, C...)
- **ELEMENT_DESCRIPTION**: Description of the constituent element

## Use Cases

- **Evaluation Phase**: Record constituent elements after claim analysis
- **Claim Comparison**: Compare elements across multiple patents
- **Prior Art Search**: Find patents with similar elements
- **Infringement Analysis**: Analyze overlap between elements

## Verify Insert

```bash
sqlite3 patents.db "
SELECT e.element_label, e.element_description, c.claim_number
FROM elements e
JOIN claims c ON e.claim_number = c.claim_number AND e.patent_id = c.patent_id
WHERE e.patent_id = '${PATENT_ID}'
ORDER BY c.claim_number, e.element_label;
"
```

## Output

- **Success**: Elements recorded in database
- **Error**: Failed to insert elements (check patent_id and claim_number exist)
