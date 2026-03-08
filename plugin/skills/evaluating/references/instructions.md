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

## Process

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

### Step 1: Load Required Skills

Use the Skill tool to load skills BEFORE starting any work:

1. **Constitution**: `constitution-reminding` - Understand core principles
2. **Legal Checker**: `legal-checking` - Legal compliance guidelines

### Step 2: Patent Analysis

1. **Retrieve Data**:
   - Use the `google-patent-cli:patent-fetch` skill with the patent ID
   - The skill handles data retrieval and provides access to patent details

2. **Analyze Claims**:
   - **Independent Claim**: Decompose Claim 1 into elements (A, B, C...)
   - **Dependent Claims**: Identify key dependent claims that meaningfully narrow the scope or add critical features
   - **Divisional Check**: Verify if this is a divisional application
     - If yes, use the parent application's filing date (or priority date) as the effective reference date for prior art
   - **Status Verification**:
     - **3-Year Rule**: In Japan, examination must be requested within 3 years of filing
     - **Zombie Pending**: If Filing Date is > 3 years ago AND Status is "Pending" (and not Granted), it is likely "Deemed Withdrawn"
     - **Action**: In such cases, mark the Status as `Pending (Likely Withdrawn - Examination Deadline Exceeded)` in the report

### Step 3: Report Generation

1. **Draft Report**: Fill in the evaluation template
   - Use `assets/evaluation-template.md` as the template
   - Include all claim analysis results
   - Add legal status and divisional application notes (if applicable)

2. **Save Report**: Create the evaluation report file
   - Path: `3-investigations/<patent-id>/evaluation.md`
   - Ensure the report follows the template format

## Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

## Quality Gates

### Step 1: Load Required Skills

- [ ] **Constitution Loaded**: `constitution-reminding` skill loaded successfully
- [ ] **Legal Checker Loaded**: `legal-checking` skill loaded successfully

### Step 2: Patent Analysis

- [ ] **Patent Data Retrieved**: `google-patent-cli:patent-fetch` skill used to fetch patent details
- [ ] **Independent Claim Analyzed**: Claim 1 decomposed into elements (A, B, C...)
- [ ] **Dependent Claims Identified**: Key dependent claims summarized
- [ ] **Divisional Check Completed**: Divisional application status verified (if applicable)
- [ ] **Status Verification Completed**: Legal status and 3-year rule checked

### Step 3: Report Generation

- [ ] **Template Filled**: All analysis results entered into evaluation template
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology"
  - [ ] Avoid citing specific court case examples
- [ ] **Report Saved**: `3-investigations/<patent-id>/evaluation.md` created

## Deliverables

1. `3-investigations/<patent-id>/evaluation.md`
