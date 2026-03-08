# Record Elements

Record claim constituent elements to the database during evaluation.

## Purpose

Store analyzed claim elements for future reference and comparison.

## SQL Insert

```bash
sqlite3 patents.db <<EOF
INSERT INTO elements (patent_id, claim_id, element_label, element_description)
VALUES
  ('${PATENT_ID}', ${CLAIM_ID}, '${ELEMENT_LABEL}', '${ELEMENT_DESCRIPTION}');
EOF
```

For multiple elements (recommended):

```bash
sqlite3 patents.db <<EOF
INSERT INTO elements (patent_id, claim_id, element_label, element_description) VALUES
  ('${PATENT_ID}', ${CLAIM_ID}, 'A', 'Element A description'),
  ('${PATENT_ID}', ${CLAIM_ID}, 'B', 'Element B description'),
  ('${PATENT_ID}', ${CLAIM_ID}, 'C', 'Element C description');
EOF
```

## Parameters

- **PATENT_ID**: Patent identifier (e.g., "US20240292070A1")
- **CLAIM_ID**: ID of the claim from claims table (use last_insert_rowid())
- **ELEMENT_LABEL**: Element label (A, B, C...)
- **ELEMENT_DESCRIPTION**: Description of the constituent element

## Get Claim ID

When inserting elements, reference the claim by its claim_id (not auto-increment ID):

```bash
# Use the actual claim_id from patent data
CLAIM_ID="clm-1"  # or extracted from patent data
```

The claim_id comes from the patent data's claims array (usually in the `claim_id` or similar field).

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
JOIN claims c ON e.claim_id = c.claim_id AND e.patent_id = c.patent_id
WHERE e.patent_id = '${PATENT_ID}'
ORDER BY c.claim_number, e.element_label;
"
```

## Output

- **Success**: Elements recorded in database
- **Error**: Failed to insert elements (check patent_id and claim_id exist)
