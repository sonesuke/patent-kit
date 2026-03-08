# Step 1: Patent Analysis

Analyze the patent to extract key information for evaluation.

## 0. Load Required Skills

Use the Skill tool to load the following skills BEFORE starting analysis:

1. **Constitution**: `constitution-reminding`
   - Purpose: Understand core principles for patent evaluation
   - Provides guidelines on legal compliance and analysis

## 1. Retrieve Patent Data

Use the `google-patent-cli:patent-fetch` skill with the patent ID:

- The skill handles data retrieval and provides access to patent details
- Refer to patent-fetch skill documentation for data access methods

## 2. Analyze Claims

### Independent Claim Analysis

- Decompose Claim 1 into constituent elements (A, B, C...)
- Identify each element's technical scope
- Document relationships between elements

### Dependent Claims Analysis

- Identify key dependent claims that meaningfully narrow the scope
- Note dependent claims that add critical features
- Summarize how dependent claims modify the independent claim

### Divisional Application Check

- Verify if this is a divisional application
- **If yes**: Use the parent application's filing date (or priority date) as the effective reference date for prior art
- Document divisional relationship in the report

### Legal Status Verification

**3-Year Rule** (Japan):

- Examination must be requested within 3 years of filing
- Check if filing date exceeds 3 years from current date

**Zombie Pending**:

- If Filing Date is > 3 years ago AND Status is "Pending" (and not Granted), it is likely "Deemed Withdrawn"
- **Action**: Mark the Status as `Pending (Likely Withdrawn - Examination Deadline Exceeded)` in the report

## 3. Store Analysis in Database

Use the `investigating-database` skill to record claims and elements in the database:

### Record Claims

- Request: "Record claims for patent <patent-id>"
- Extract claim data from the fetched patent (claim_number, claim_type, claim_text)
- Store all claims (independent and dependent) in the database

### Record Elements

- Request: "Record elements for claim <claim_number>"
- For each analyzed claim, record its constituent elements
- Use claim_number (1, 2, 3...)
- Store element_label (A, B, C...) and element_description

This enables:

- Future querying and comparison of claims and elements
- Progress tracking across multiple evaluation sessions
- Data-driven analysis and reporting

## Quality Gates

- [ ] **Constitution Loaded**: `constitution-reminding` skill loaded successfully
- [ ] **Patent Data Retrieved**: `google-patent-cli:patent-fetch` skill used to fetch patent details
- [ ] **Independent Claim Analyzed**: Claim 1 decomposed into elements (A, B, C...)
- [ ] **Dependent Claims Identified**: Key dependent claims summarized
- [ ] **Divisional Check Completed**: Divisional application status verified (if applicable)
- [ ] **Status Verification Completed**: Legal status and 3-year rule checked
- [ ] **Claims Recorded**: Claims stored in database using `investigating-database` skill
- [ ] **Elements Recorded**: Constituent elements stored in database using `investigating-database` skill

## Next Step

Proceed to Step 2: `generate-report.md` for report generation.
