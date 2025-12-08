---
description: "Phase 2: Infringement"
---

# Phase 2: Infringement

Your task is to create the Investigation Plan based on the Spec.

## Input

- **Spec File**: `<path/to/evaluation.md>`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md`.
2. **Read Inputs**: `evaluation.md` (Patent) and `hearing.md` (Product).
3. **Analyze Conflict**:

- Compare Product Features vs Patent Elements.
- Identify Matches/Risks.

4. **Draft**: Fill `.patent-kit/templates/infringement-template.md`.
5. **Save**: `investigations/<patent-id>/infringement.md`.

## Next Step

Run `/patent-kit.prior investigations/<patent-id>/infringement.md`
