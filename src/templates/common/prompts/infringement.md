---
description: "Phase 3: Infringement"
---

# Phase 3: Infringement

Your task is to create the Investigation Plan based on the Spec.

## Input

- **Spec File**: `investigations/<patent-id>/evaluation.md`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md`.
2. **Read Inputs**: `evaluation.md` (Patent) and `specification/specification.md` (Product) if available.
   - **If information is insufficient**: Conduct an additional hearing with the user to gather missing details. Update `specification/specification.md` accordingly.
3. **Analyze Conflict**:
   - Compare Product Features vs Patent Elements.
   - Identify Matches/Risks.

4. **Draft**: Fill `.patent-kit/templates/infringement-template.md`.
5. **Save**: `investigations/<patent-id>/infringement.md`.

{{ NEXT_STEP_INSTRUCTION }}
