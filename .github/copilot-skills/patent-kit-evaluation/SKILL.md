---
name: evaluation
description: "Phase 3: Evaluation"
---

# Phase 3: Evaluation

Your task is to Analyze the Patent and create the Specification.

## Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next uninvestigated relevant patent will be automatically selected.

## Process

1. **Read Constitution**: Read `.patent-kit/memory/constitution.md` to understand the core principles.

### Step 0: Determine Patent ID

If no patent ID is provided, run the following to get the next patent:

- Run: `next-evaluation-patent`

> [!NOTE]
> **Scripts Location**:
> 
> - Linux/Mac: `./.patent-kit/scripts/shell/next-evaluation-patent.sh`
> - Windows: `.\.patent-kit\scripts\powershell\next-evaluation-patent.ps1`

This script finds the first patent marked as `relevant` in `2-screening/screened.jsonl` that doesn't yet have a folder in `3-investigations/`.

**If a Patent ID IS provided**:

- Check if `3-investigations/<patent-id>/evaluation.md` already exists.
- **If it exists**: **ASK the User for confirmation** via `notify_user`.
  - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with re-evaluating?"
- **If it does NOT exist**: Proceed with the standard process.

### Step 1: Patent Analysis

1. **Retrieve Data**:

   ```bash
   mkdir -p 3-investigations/<patent-id>/json
   ./.patent-kit/bin/google-patent-cli fetch "<patent-id>" > 3-investigations/<patent-id>/json/<patent-id>.json
   ```

2. **Analyze**: Identify Constituent Elements.
   - **Independent Claim**: Decompose Claim 1 into elements (A, B, C...).
   - **Dependent Claims**: Identify key dependent claims that meaningfully narrow the scope or add critical features.
   - **Divisional Check**: Verify if this is a divisional application. If yes, use the parent application's filing date (or priority date) as the effective reference date for prior art.
   - **Status Verification**:
     - **3-Year Rule**: In Japan, examination must be requested within 3 years of filing.
     - **Zombie Pending**: If Filing Date is > 3 years ago AND Status is "Pending" (and not Granted), it is likely "Deemed Withdrawn".
     - **Action**: In such cases, mark the Status as `Pending (Likely Withdrawn - Examination Deadline Exceeded)` in the report.

3. **Draft**: Fill `.patent-kit/templates/evaluation-template.md`.

4. **Save**: `3-investigations/<patent-id>/evaluation.md`.

## Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

## Quality Gates

- [ ] Patent data successfully fetched and saved.
- [ ] Constituent elements are clearly identified.
- [ ] Notable dependent claims are summarized.
- [ ] Divisional application check completed (if applicable).
- [ ] Evaluation report follows the template format.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology".
  - [ ] Avoid citing specific court case examples.

## Next Step

Run Phase 4 (Claim Analysis).
