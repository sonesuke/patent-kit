# Record Claims

Record patent claims to the database during evaluation.

## Purpose

Store analyzed patent claims for future reference and analysis.

## SQL Insert

**Recommended**: Use timeout for concurrent access

```bash
sqlite3 patents.db -cmd ".timeout 30000" <<EOF
INSERT INTO claims (patent_id, claim_number, claim_type, claim_text) VALUES
  ('${PATENT_ID}', 1, 'independent', '${CLAIM_1_TEXT}'),
  ('${PATENT_ID}', 2, 'dependent', '${CLAIM_2_TEXT}'),
  ('${PATENT_ID}', 3, 'dependent', '${CLAIM_3_TEXT}');
EOF
```

**For large batches** (10+ claims):

```bash
sqlite3 patents.db -cmd ".timeout 30000" <<EOF
INSERT INTO claims (patent_id, claim_number, claim_type, claim_text) VALUES
  ('${PATENT_ID}', 1, 'independent', '${CLAIM_1_TEXT}'),
  ('${PATENT_ID}', 2, 'dependent', '${CLAIM_2_TEXT}'),
  ('${PATENT_ID}', 3, 'dependent', '${CLAIM_3_TEXT}'),
  ('${PATENT_ID}', 4, 'dependent', '${CLAIM_4_TEXT}'),
  ('${PATENT_ID}', 5, 'dependent', '${CLAIM_5_TEXT}');
EOF
```

## Parameters

- **PATENT_ID**: Patent identifier (e.g., "US20240292070A1")
- **CLAIM_NUMBER**: Claim number (1 for independent, 2+ for dependent)
- **CLAIM_TYPE**: Either "independent" or "dependent"
- **CLAIM_TEXT**: Full text of the claim

## Use Cases

- **Evaluation Phase**: Record claims after analysis
- **Claim Analysis**: Query specific claims for comparison
- **Prior Art Search**: Find similar claims across patents

## Verify Insert

```bash
sqlite3 patents.db "SELECT * FROM claims WHERE patent_id = '${PATENT_ID}';"
```

## Output

- **Success**: Claims recorded in database
- **Error**: Failed to insert claims (check patent_id exists in screened_patents)
