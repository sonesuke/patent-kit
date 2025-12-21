---
description: "Phase 2: Evaluation"
---

# Phase 2: Evaluation

Your task is to Analyze the Patent and create the Specification.

## Input

- **Patent ID**: `<patent-id>`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md` to understand the core principles.
2. **Retrieve Data**:

    ```bash
    mkdir -p investigations/<patent-id>/json
    ./.patent-kit/bin/google-patent-cli fetch "<patent-id>" > investigations/<patent-id>/json/<patent-id>.json
    ```

3. **Analyze**: Identify Constituent Elements.
4. **Draft**: Fill `.patent-kit/templates/evaluation-template.md`.
5. **Save**: `investigations/<patent-id>/evaluation.md`.

Run `/patent-kit.infringement investigations/<patent-id>/evaluation.md`
