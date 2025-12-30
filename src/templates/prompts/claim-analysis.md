---
description: "Phase 4: Claim Analysis"
---

# Phase 4: Claim Analysis

Your task is to create the Claim Analysis Report based on the Spec.

## Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next patent pending claim analysis will be automatically selected.

## Process

1. **Read Constitution**: Read `.patent-kit/memory/constitution.md` to understand the core principles.

### Step 0: Determine Patent ID

If no patent ID is provided, run the following to get the next patent:

- Run: `next-claim-analysis-patent`

**If a Patent ID IS provided**:

- Check if `3-investigations/<patent-id>/evaluation.md` already exists.
- **If it exists**: **ASK the User for confirmation** via `notify_user`.
  - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with Claim Analysis based on this evaluation?"
- **If it does NOT exist**: Proceed with the standard process.

> [!NOTE]
> **Scripts Location**:
> 
> - Linux/Mac: `./.patent-kit/scripts/shell/next-claim-analysis-patent.sh`
> - Windows: `.\.patent-kit\scripts\powershell\next-claim-analysis-patent.ps1`

This script finds the first patent in `3-investigations/` that has `evaluation.md` but no `claim-analysis.md` yet.

### Step 1: Comparison Analysis

1. **Read Inputs**: `evaluation.md` (Patent) and `0-specifications/specification.md` (Product) if available.
   - **Check Sufficiency**: Is the product specification detailed enough to determine the presence/absence of EACH element?
     - **Potential Feature Check**: Even if a patent feature is MISSING in the spec, if it seems like a useful feature that fits the product concept, **DO NOT assume it is absent**. Instead, **ASK the User** via `notify_user` if they plan to implement it or if it exists.
   - **Update Specification IMMEDIATELY**: If you conduct a hearing or receive ANY new information (e.g., specific features, presence/absence of elements) from the user, YOU MUST UPDATE `0-specifications/specification.md` FIRST. Do not proceed with analysis until the specification is updated.

2. **Analyze Comparison**:
   - Compare Product Features vs Patent Elements.
   - Identify Matches/Similarities.
     - **Literal Match (Significant Similarity)**: All constituent elements are fully satisfied.
     - **Equivalence Analysis (5 Requirements)**: Even if literal match is not found, "Moderate Similarity" applies if ALL 5 requirements are met (Japan Supreme Court, Ball Spline Case):
       1. **Non-Essential Part**: The difference is NOT the essential part of the claimed invention.
       2. **Interchangeability**: The modification produces the SAME result and function.
       3. **Ease of Interchangeability**: Easily conceived by a person skilled in the art at the time of filing.
       4. **No Intentional Exclusion**: The feature was NOT intentionally excluded during prosecution (Estoppel).
       5. **Not Prior Art**: The modified product is NOT part of the prior art at the time of filing.

3. **Draft**: Fill `.patent-kit/templates/claim-analysis-template.md`.
   - **Similarity Assessment**:
     - **Definitions**:
       - **Significant**: All elements overlap (Literal Match).
       - **Moderate**: Most elements overlap, or partial overlap (Equivalence - See Step 1).
       - **Limited**: Clear difference in at least one element.
     - **Format**:
       - Overall Similarity MUST be written exactly as: `Overall Similarity: Significant Similarity` (or Moderate Similarity, Limited Similarity).
       - Do NOT use other formats like "High (高リスク)".

4. **Save**: `3-investigations/<patent-id>/claim-analysis.md`.

## Output

- `3-investigations/<patent-id>/claim-analysis.md`: The claim analysis report.

## Quality Gates

- [ ] Product specification is complete and up-to-date.
- [ ] Conflict Analysis (Claim Chart) is complete and compares all elements.
- [ ] Similarity levels are assigned to each element (Significant/Moderate/Limited).
- [ ] Overall Similarity follows strict format: `Overall Similarity: Significant Similarity` (or Moderate/Limited).
- [ ] Claim analysis report follows the template format.

{{ NEXT_STEP_INSTRUCTION }}
