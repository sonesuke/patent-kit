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

   - **Strategy: Multi-Layer Search** (Standard Procedure):
     - **Layer 1: General Terminology**: Search for broad technical concepts.
     - **Layer 2: Specific Nomenclature**: Search for exact keywords and technical names.
     - **Layer 3: Functional/Role-based**: Search by function or role (e.g., "means for X").
   - **Strategic Limit Expansion**:
     - **RULE**: For critical search axes (high relevance probability), expand `--limit` to **30-50**.
     - Standard searches can use lower limits (e.g., 10-20).
   - **Iterative Improvement**:
     - **Phase 1**: Initial broad search. Analyze results.
     - **Phase 2 Refinement**: Use analysis to refine keywords and target specific gaps.
   - **Synonym Expansion**:
     - Construct a list of frequent synonyms for the technical field to avoid missing documents due to terminology mismatch.
   - **CRITICAL**: Use `--before <priority-date>` for both `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli`.
   - **Tools** (Both Required):
     - **MUST** use `./.patent-kit/bin/google-patent-cli` for patent literature.
     - **MUST** use `./.patent-kit/bin/arxiv-cli` for non-patent literature (academic papers).
     - Example: `./.patent-kit/bin/arxiv-cli search --query "<query>" --before "<priority-date>" --limit 50`.
   - **Requirement**: Save output to `investigations/<patent-id>/json/search_results_<desc>.json`.
   - **Check**: Did the command succeed? IF NO -> **STOP** and Debug.

4. **Screen Results** (MANDATORY for BOTH patent and non-patent literature):

   - **Non-Patent Literature Screening** (CRITICAL - DO NOT SKIP):
     - **RULE**: Papers with titles directly relevant to the target patent's technical field MUST be included for detailed analysis.
     - Identify Grade A NPL candidates and summarize their technical contributions.
     - Map the technical elements of the paper to the patent's constituent elements.

5. **Detailed Analysis** (MANDATORY):

   - **For Non-Patent Literature (Grade A)** (CRITICAL):
     - **MUST** perform detailed analysis for Grade A NPL.
     - **RULE**: Even if sufficient invalidation evidence is found in patent literature, NPL analysis results MUST be included in the report (Constitution III).
   - Determine the winning logic.

6. **Draft Report**: Fill `.patent-kit/templates/prior-template.md`.
7. **Save**: `investigations/<patent-id>/prior.md`.

## Conclusion

Check "Quality Gates" and finalize the report.
