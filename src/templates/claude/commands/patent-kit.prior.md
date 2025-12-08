---
description: "Phase 3: Prior Art"
---

# Phase 3: Prior Art

Your task is to Execute the Plan and Report Findings.

## Input

- **Plan File**: `<path/to/infringement.md>`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md`.
2. **Read Risk**: Read `infringement.md` to understand the conflict.
3. **Plan & Execute Search**:

- **Adaptive Loop**:
- Start with broad keywords.
- *Check*: Did we find Product Features? -> **Adopt FTO**.
- *Check*: Did we find Patent Elements? -> **Adopt Invalidation**.
- **CRITICAL**: Use `--before <priority-date>` for both `google-patent-cli` and `arxiv-cli`.
- *Warning**: Do NOT use unsupported flags (e.g., `--country`).
- **Requirement**: Save output to `investigations/<patent-id>/json/search_results_<desc>.json`.
- **Tools** (Both Required):
- **MUST** use `google-patent-cli` for patent literature.
- **MUST** use `arxiv-cli` for non-patent literature (academic papers).
- Example: `arxiv-cli search --query "<query>" --before "<priority-date>" --limit 10`.
- Run searches with BOTH tools to ensure comprehensive coverage.
- **Check**: Did the command succeed? IF NO -> **STOP** and Debug.

4. **Analyze**: Determine the winning logic.
5. **Draft Report**: Fill `.patent-kit/templates/prior-template.md`.
6. **Save**: `investigations/<patent-id>/prior.md`.

## Conclusion

Check "Quality Gates" and finalize the report.
