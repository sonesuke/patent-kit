# Evaluating - Detailed Instructions

## Template Adherence

- **Requirement**: Strict adherence to the output template is required.
- **Template**: Located in `assets/` directory.
  - `evaluation-template.md` - Use for `3-investigations/<patent-id>/evaluation.md`

## Overview

Generate a detailed evaluation report for a screened patent. This phase analyzes claim elements, legal status, and creates investigation specifications for prior art search.

## Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next uninvestigated relevant patent will be automatically selected from the database.
- **Specification**: `0-specifications/specification.md` (generated in Phase 0).
- **Skills**: `constitution-reminding`, `legal-checking`, `google-patent-cli` (patent-fetch) from marketplace.

## Process

### User Interview for Product Understanding

For accurate claim analysis, understanding the target product is crucial.

- **Rule**: Ensure `0-specifications/specification.md` exists and contains complete product information.
- **Check**: If specification is incomplete or missing, notify the user before proceeding.
- **Information Needed**: Clear definition of the "Target Product" to compare against claim elements.

### Step 0: Determine Patent ID

If no patent ID is provided, query the database for the next patent:

- Use the `investigating-database` skill
- Request: "Get the next patent ID for evaluation"
- The skill will find the first patent marked as `relevant` that doesn't yet have an evaluation report.

**If a Patent ID IS provided**:

- Check if `3-investigations/<patent-id>/evaluation.md` already exists.
- **If it exists**: **ASK the User for confirmation**
  - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with re-evaluating?"
- **If it does NOT exist**: Proceed with the standard process.

### Step 1: Patent Analysis

1. **Load Required Skills**:
   - Load `constitution-reminding` skill to understand core principles
   - Load `legal-checking` skill to understand legal compliance guidelines

2. **Retrieve Data**:
   - Use the `google-patent-cli:patent-fetch` skill with the patent ID
   - The skill handles data retrieval and provides access to patent details
   - Refer to the patent-fetch skill documentation for data access methods

3. **Analyze**: Identify Constituent Elements.
   - **Independent Claim**: Decompose Claim 1 into elements (A, B, C...).
   - **Dependent Claims**: Identify key dependent claims that meaningfully narrow the scope or add critical features.
   - **Divisional Check**: Verify if this is a divisional application. If yes, use the parent application's filing date (or priority date) as the effective reference date for prior art.
   - **Status Verification**:
     - **3-Year Rule**: In Japan, examination must be requested within 3 years of filing.
     - **Zombie Pending**: If Filing Date is > 3 years ago AND Status is "Pending" (and not Granted), it is likely "Deemed Withdrawn".
     - **Action**: In such cases, mark the Status as `Pending (Likely Withdrawn - Examination Deadline Exceeded)` in the report.

4. **Draft**: Fill `[evaluation-template.md](assets/evaluation-template.md)`.

5. **Save**: `3-investigations/<patent-id>/evaluation.md`.

## Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

## Quality Gates

- [ ] **Specification Check**: Does `0-specifications/specification.md` exist with complete product information?
- [ ] **Skills Loaded**: `constitution-reminding` and `legal-checking` skills loaded successfully.
- [ ] **Patent Data Retrieved**: `google-patent-cli:patent-fetch` skill used to fetch patent details.
- [ ] **Claim Analysis**: Constituent elements are clearly identified.
- [ ] **Dependent Claims**: Notable dependent claims are summarized.
- [ ] **Divisional Check**: Divisional application check completed (if applicable).
- [ ] **Status Verification**: Legal status and 3-year rule check completed.
- [ ] **Template Adherence**: Evaluation report follows the template format.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology".
  - [ ] Avoid citing specific court case examples.
- [ ] **Output File**: `3-investigations/<patent-id>/evaluation.md` created.

## Deliverables

1. `3-investigations/<patent-id>/evaluation.md`
