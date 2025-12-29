---
description: "Phase 4: Prior Art"
---

# Phase 4: Prior Art

Your task is to Execute the Plan and Report Findings.

## Input

- **Plan File**: `investigations/<patent-id>/infringement.md`

## Process

1. **Initialize**: Read `.patent-kit/memory/constitution.md`.
2. **Read Risk**: Read `infringement.md` to understand the conflict.
3. **Plan & Execute Search**:

- **Strategy: Multi-Layer Search** (Standard Procedure):
- **Layer 1: General Terminology**:
- **Purpose**: Capture broad technical concepts and context.
- **Keywords**: High-level terms (e.g., "Language Model", "Search").
- **Limit**: Recommended **10-20**.
- **Layer 2: Specific Nomenclature**:
- **Purpose**: Find exact matches using specific technical terms (Critical for finding key NPL like arXiv:2305.13657).
- **Keywords**: Specific model names, exact algorithms, unique parameter names.
- **Limit**: **MUST** Expand to **30-50** to capture subtle matches.
- **Layer 3: Functional/Role-based**:
- **Purpose**: Catch patents describing the *function* rather than the specific name.
- **Keywords**: "Means for...", "configured to...", functional descriptions.
- **Limit**: Recommended **10-20**.

- **Adaptive Verification Loop** (New Standard):

  1. **Analyze**: Review initial results. Are there key terms missing?
  2. **Re-Search**: If gaps exist, refine queries and run a targeted search (e.g., specific authors, new synonyms).
  3. **Check**: Verify if the new top results cover the missing aspects.
  4. **Document**: Record the logic for the refined search.

- **Strategic Limit Expansion**:
- **RULE**: For critical search axes (high relevance probability), expand `--limit` to **30-50**.
- Standard searches can use lower limits (e.g., 10-20).

- **Synonym Expansion**:
- Construct a list of frequent synonyms for the technical field to avoid missing documents due to terminology mismatch.

- **Tools & Configuration** (Both Required):
- **CRITICAL**: Use `--before <priority-date>` for both `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli`.
- **MUST** use `./.patent-kit/bin/google-patent-cli` for patent literature.
- **MUST** use `./.patent-kit/bin/arxiv-cli` for non-patent literature (academic papers).
- Example: `./.patent-kit/bin/arxiv-cli search --query "<query>" --before "<priority-date>" --limit 50`.
- **Requirement**: Save output to `investigations/<patent-id>/json/search_results_<desc>.json`.
- **Check**: Did the command succeed? IF NO -> **STOP** and Debug.

1. **Screen Results** (MANDATORY for BOTH patent and non-patent literature):

- **Non-Patent Literature Screening** (CRITICAL - DO NOT SKIP):
- **RULE**: Papers with titles directly relevant to the target patent's technical field MUST be included for detailed analysis.
- Identify Grade A NPL candidates and summarize their technical contributions.
- Map the technical elements of the paper to the patent's constituent elements.

1. **Detailed Analysis** (MANDATORY):

- **For Non-Patent Literature (Grade A)** (CRITICAL):
- **Full-Text Acquisition**:
- **MUST** run `arxiv-cli fetch --id <arxiv-id>` to get full-text JSON for Grade A NPLs.
- Save output to `investigations/<patent-id>/json/npl_<id>.json`.
- **Claim Chart Creation**:
- **Requirement**: Create a Claim Chart comparing the NPL against the Patent Claims.
- **Citation**: **MUST** include specific **paragraph-level citations** (or section/line numbers) from the fetched JSON text.
- **Evidence Quality Check**:
- Verify that the cited paragraph explicitly supports the mapping.
- Verify that the publication date is strictly before the priority date.
- **RULE**: Even if sufficient invalidation evidence is found in patent literature, NPL analysis results MUST be included in the report (Constitution III).

- Determine the winning logic.

1. **Draft Report**: Fill `.patent-kit/templates/prior-template.md`.
2. **Save**: `investigations/<patent-id>/prior.md`.

## Quality Gates

- [ ] **Multi-Layer Search**: Did you execute comprehensive searches across all 3 layers (General, Specific, Functional)?
- [ ] **NPL Coverage**: Did you specifically target NPL (Layer 2) with expanded limits (30-50)?
- [ ] **Full-Text Analysis**: Did you fetch the JSON using `arxiv-cli fetch` for top NPLs?
- [ ] **Claim Chart**: Does the report include a Claim Chart with precise paragraph-level citations?
- [ ] **Priority Date**: Is every piece of evidence confirmed to be prior to the cutoff?
- [ ] **Conclusion**: Is the final verdict clearly guided by the evidence found?
