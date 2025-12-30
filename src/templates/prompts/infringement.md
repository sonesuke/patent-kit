---
description: "Phase 4: Infringement"
---

# Phase 4: Infringement

Your task is to create the Investigation Plan based on the Spec.

## Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next patent pending infringement analysis will be automatically selected.

## Process

1. **Read Constitution**: Read `.patent-kit/memory/constitution.md` to understand the core principles.

### Step 0: Determine Patent ID

If no patent ID is provided, run the following to get the next patent:
- Run: `next-infringement-patent`

**If a Patent ID IS provided**:
- Check if `3-investigations/<patent-id>/evaluation.md` already exists.
- **If it exists**: **ASK the User for confirmation** via `notify_user`.
  - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with Infringement Analysis based on this evaluation?"
- **If it does NOT exist**: Proceed with the standard process.

> [!NOTE]
> **Scripts Location**:
> - Linux/Mac: `./.patent-kit/scripts/shell/next-infringement-patent.sh`
> - Windows: `.\.patent-kit\scripts\powershell\next-infringement-patent.ps1`

This script finds the first patent in `3-investigations/` that has `evaluation.md` but no `infringement.md` yet.

### Step 1: Conflict Analysis

1. **Read Inputs**: `evaluation.md` (Patent) and `0-specifications/specification.md` (Product) if available.
   - **Check Sufficiency**: Is the product specification detailed enough to determine the presence/absence of EACH element?
     - **Potential Feature Check**: Even if a patent feature is MISSING in the spec, if it seems like a useful feature that fits the product concept, **DO NOT assume it is absent**. Instead, **ASK the User** via `notify_user` if they plan to implement it or if it exists.
   - **Update Specification IMMEDIATELY**: If you conduct a hearing or receive ANY new information (e.g., specific features, presence/absence of elements) from the user, YOU MUST UPDATE `0-specifications/specification.md` FIRST. Do not proceed with analysis until the specification is updated.

2. **Analyze Conflict**:
   - Compare Product Features vs Patent Elements.
   - Identify Matches/Risks.
     - **Literal Infringement**: All constituent elements are fully satisfied.
     - **Doctrine of Equivalents (5 Requirements)**: Even if literal infringement is not found, "Medium Risk" applies if ALL 5 requirements are met (Japan Supreme Court, Ball Spline Case):
       1. **Non-Essential Part**: The difference is NOT the essential part of the claimed invention.
       2. **Interchangeability**: The modification produces the SAME result and function.
       3. **Ease of Interchangeability**: Easily conceived by a person skilled in the art at the time of filing.
       4. **No Intentional Exclusion**: The feature was NOT intentionally excluded during prosecution (Estoppel).
       5. **Not Prior Art**: The modified product is NOT part of the prior art at the time of filing.

3. **Draft**: Fill `.patent-kit/templates/infringement-template.md`.
   - **Risk Assessment**:
     - **Definitions**:
       - **High**: All elements overlap (Literal Infringement).
       - **Medium**: Most elements overlap, or partial overlap (Doctrine of Equivalents - See Step 1).
       - **Low**: Clear difference in at least one element.
     - **Format**:
       - Overall Risk MUST be written exactly as: `Overall Risk: High Risk` (or Medium Risk, Low Risk).
       - Do NOT use other formats like "High (高リスク)".

4. **Save**: `3-investigations/<patent-id>/infringement.md`.

## Output

- `3-investigations/<patent-id>/infringement.md`: The infringement analysis report.

## Quality Gates

- [ ] Product specification is complete and up-to-date.
- [ ] Conflict Analysis (Claim Chart) is complete and compares all elements.
- [ ] Risk levels are assigned to each element (High/Medium/Low).
- [ ] Overall Risk follows strict format: `Overall Risk: High Risk` (or Medium/Low).
- [ ] Infringement report follows the template format.

{{ NEXT_STEP_INSTRUCTION }}
