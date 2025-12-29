---
description: "Phase 3: Evaluation"
---

# Phase 3: Evaluation

Your task is to Analyze the Patent and create the Specification.

## Input

- **Patent ID**: `<patent-id>`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md` to understand the core principles.
2. **Retrieve Data**:

   ```bash
   mkdir -p 3-investigations/<patent-id>/json
   ./.patent-kit/bin/google-patent-cli fetch "<patent-id>" > 3-investigations/<patent-id>/json/<patent-id>.json
   ```

3. **Analyze**: Identify Constituent Elements.
   - **Divisional Check**: Verify if this is a divisional application. If yes, use the parent application's filing date (or priority date) as the effective reference date for prior art.

4. **Draft**: Fill `.patent-kit/templates/evaluation-template.md`.
5. **Save**: `3-investigations/<patent-id>/evaluation.md`.

{{ NEXT_STEP_INSTRUCTION }}
