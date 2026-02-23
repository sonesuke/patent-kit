---
name: evaluation
description: "Generates a detailed evaluation report for a screened patent. Triggered when the user asks to 'evaluate the patent' or 'analyze claim elements (Step 3)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 3: Evaluation

Your task is to Analyze the Patent and create the Specification.

## Instructions

### Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next uninvestigated relevant patent will be automatically selected.

### Process

1. **Read Constitution**: Load the `constitution` skill to understand the core principles.
2. **Read Legal Checker**: Load the `legal-checker` skill to understand legal compliance guidelines.

#### Step 0: Determine Patent ID

If no patent ID is provided, run the following to get the next patent:

- Run: `next-evaluation-patent`

> [!NOTE]
> **Scripts Location**:
>
> - Linux/Mac: `./scripts/shell/next-evaluation-patent.sh`
> - Windows: `.\scripts\powershell\next-evaluation-patent.ps1`

This script finds the first patent marked as `relevant` in `2-screening/screened.jsonl` that doesn't yet have a folder in `3-investigations/`.

**If a Patent ID IS provided**:

- Check if `3-investigations/<patent-id>/evaluation.md` already exists.
- **If it exists**: **ASK the User for confirmation** via `notify_user`.
  - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with re-evaluating?"
- **If it does NOT exist**: Proceed with the standard process.

#### Step 1: Patent Analysis

1. **Retrieve Data**:

   ```bash
   mkdir -p 3-investigations/<patent-id>/json
   ./.patent-kit/bin/fetch_patent "<patent-id>" > 3-investigations/<patent-id>/json/<patent-id>.json
   ```

2. **Analyze**: Identify Constituent Elements.
   - **Independent Claim**: Decompose Claim 1 into elements (A, B, C...).
   - **Dependent Claims**: Identify key dependent claims that meaningfully narrow the scope or add critical features.
   - **Divisional Check**: Verify if this is a divisional application. If yes, use the parent application's filing date (or priority date) as the effective reference date for prior art.
   - **Status Verification**:
     - **3-Year Rule**: In Japan, examination must be requested within 3 years of filing.
     - **Zombie Pending**: If Filing Date is > 3 years ago AND Status is "Pending" (and not Granted), it is likely "Deemed Withdrawn".
     - **Action**: In such cases, mark the Status as `Pending (Likely Withdrawn - Examination Deadline Exceeded)` in the report.

3. **Draft**: Fill `[evaluation-template.md](templates/evaluation-template.md)`.

4. **Save**: `3-investigations/<patent-id>/evaluation.md`.

### Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

### Quality Gates

- [ ] Patent data successfully fetched and saved.
- [ ] Constituent elements are clearly identified.
- [ ] Notable dependent claims are summarized.
- [ ] Divisional application check completed (if applicable).
- [ ] Evaluation report follows the template format.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology".
  - [ ] Avoid citing specific court case examples.

Run /patent-kit:claim-analysis <patent-id>

# Examples

Example 1: Evaluating a Specific Patent
User says: "Please evaluate JP-2023-12345-A"
Actions:

1. Fetch patent info using the MCP tool
2. Break down the claims into elements and check the legal status
3. Generate the report according to evaluation-template.md
   Result: 3-investigations/JP-2023-12345-A/evaluation.md is generated.

# Troubleshooting

Error: "Failed to fetch patent data"
Cause: Invalid Patent ID or network error.
Solution: Verify that the Patent ID format is correct and try again.
