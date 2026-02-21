---
name: claim-analysis
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
     - **Direct correspondence (Significant Similarity)**: All constituent elements are fully satisfied.
       - **Note**: In Japanese output, use "対応関係が確認" instead of "文言的一致".
     - **Equivalence/Similarity**: If direct correspondence is not found but functionality is similar:
       - **Strict Rule**: Do NOT state "Satisfies the 5 requirements" or "Equivalent".
       - **Requirement**: Use descriptive language focusing on function and behavior.
         - **Example**: "The alternative implementation achieves the same functional outcome and exhibits comparable system behavior under typical operating conditions."
         - **Example**: "The variation represents a commonly used implementation approach."
       - **Logic Check (Internal only)**: You may consider the standard equivalence factors (Interchangeability, Ease of Interchangeability, etc.) to form your technical opinion, but do NOT explicitly list them as legal requirements in the output.

3. **Draft**: Fill `.patent-kit/templates/claim-analysis-template.md`.
   - **Similarity Assessment**:
     - **Definitions**:
       - **Significant**: All elements overlap (Direct correspondence).
       - **Moderate**: Functional overlap without direct correspondence (See Equivalence).
       - **Limited**: Clear difference in at least one element.
     - **Format**:
       - Overall Similarity MUST be written exactly as: `Overall Similarity: Significant Similarity` (or Moderate Similarity, Limited Similarity).
       - **Reiteration**: Add the following line at the end of the conclusion: "Note: This technical comparison does not constitute a legal opinion."
       - Do NOT use other formats like "High (高リスク)".

4. **Save**: `3-investigations/<patent-id>/claim-analysis.md`.

## Output

- `3-investigations/<patent-id>/claim-analysis.md`: The claim analysis report.

## Quality Gates

- [ ] Product specification is complete and up-to-date.
- [ ] Conflict Analysis (Claim Chart) is complete and compares all elements.
- [ ] Similarity levels are assigned to each element (Significant/Moderate/Limited).
- [ ] Overall Similarity follows strict format: `Overall Similarity: Significant Similarity` (or Moderate/Limited).
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology".
  - [ ] Avoid citing specific court case examples.
  - [ ] Use descriptive technical language (e.g., "features not found", "low likelihood of mapping", "fundamental feature").
- [ ] Claim analysis report follows the template format.

## Next Step

Run Phase 5 (Prior Art).
