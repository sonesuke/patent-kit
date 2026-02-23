---
name: prior-art
description: "Conducts an invalidation (prior art) search for a target patent. Triggered when the user asks to 'perform a prior art search' or 'find invalidating materials (Step 5)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 5: Prior Art

Your task is to Execute the Plan and Report Findings.

## Instructions

### Input

- **Plan File**: `3-investigations/<patent-id>/claim-analysis.md`

### Process

#### Step 0: Check Existing Report

**If a Patent ID IS provided**:

- Check if `3-investigations/<patent-id>/prior-art.md` already exists.
- **If it exists**: **ASK the User for confirmation** via `notify_user`.
  - Message: "Prior Art report already exists for <patent-id>. Do you want to proceed with re-investigation?"
- **If it does NOT exist**: Proceed with the standard process.

1. **Initialize**: Load the `constitution` skill.
2. **Load Legal Checker**: Load the `legal-checker` skill for legal compliance guidelines.
3. **Read Similarity**: Read `claim-analysis.md` to understand the comparison results.
4. **Plan & Execute Search**:
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
       - **Purpose**: Catch patents describing the _function_ rather than the specific name.
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
     - **CRITICAL**: Use `--before <priority-date>` for both `MCP tool search_patents / fetch_patent` and `MCP tool search_papers / fetch_paper`.
     - **MUST** use `MCP tool search_patents / fetch_patent` for patent literature.
     - **MUST** use `MCP tool search_papers / fetch_paper` for non-patent literature (academic papers).
     - Example: `MCP tool search_papers --query "<query>" --before "<priority-date>" --limit 50`.
     - **Requirement**: Save output to `3-investigations/<patent-id>/json/search_results_<desc>.json`.
     - **Check**: Did the command succeed? IF NO -> **STOP** and Debug.

5. **Screen Results** (MANDATORY for BOTH patent and non-patent literature):
   - **Non-Patent Literature Screening** (CRITICAL - DO NOT SKIP):
     - **RULE**: Papers with titles directly relevant to the target patent's technical field MUST be included for detailed analysis.
     - Identify Grade A NPL candidates and summarize their technical contributions.
     - Map the technical elements of the paper to the patent's constituent elements.

6. **Detailed Analysis** (MANDATORY):
   - **For Non-Patent Literature (Grade A)** (CRITICAL):
     - **Full-Text Acquisition**:
       - **MUST** run Use the MCP tool `fetch_paper` (Arguments: --id <arxiv-id>) to get full-text JSON for Grade A NPLs.
       - Save output to `3-investigations/<patent-id>/json/npl_<id>.json`.
     - **Claim Chart Creation**:
       - **Requirement**: Create a Claim Chart comparing the NPL against the Patent Claims.
       - **Citation**: **MUST** include specific **paragraph-level citations** (or section/line numbers) from the fetched JSON text.
     - **Evidence Quality Check**:
       - Verify that the cited paragraph explicitly supports the mapping.
       - Verify that the publication date is strictly before the priority date.
     - **RULE**: Even if strong prior art is found in patent literature, NPL analysis results MUST be included in the report (Constitution III).

7. **Draft Report**: Fill `[prior-art-template.md](templates/prior-art-template.md)`.
   - **Verdict Selection**:
     - **Relevant prior art identified**: Strong evidence found (investigation required).
     - **Alternative implementation selected**: Path changed to avoid conflict.
     - **Aligned with existing techniques**: Technology is standard/safe.
     - **Escalated for legal review**: Use when none of the above apply (e.g., complex legal interpretation needed).
   - **Similarity Assessment (Prior Art)**:
     - **Definitions**:
       - **Significant**: References likely demonstrate significant similarity (Strong Relevance).
       - **Moderate**: References show partial/arguable similarity.
       - **Limited**: No strong references found (Patent Potentially Valid).
     - **Format**:
       - Overall Similarity MUST be written exactly as: `Overall Similarity: Significant Similarity` (or Moderate Similarity, Limited Similarity).
       - Do NOT use other formats.
8. **Save**: `3-investigations/<patent-id>/prior-art.md`.

### Quality Gates

- [ ] **Multi-Layer Search**: Did you execute comprehensive searches across all 3 layers (General, Specific, Functional)?
- [ ] **NPL Coverage**: Did you specifically target NPL (Layer 2) with expanded limits (30-50)?
- [ ] **Full-Text Analysis**: Did you fetch the JSON using `fetch_paper` for top NPLs?
- [ ] **Claim Chart**: Does the report include a Claim Chart with precise paragraph-level citations?
- [ ] **Priority Date**: Is every piece of evidence confirmed to be prior to the cutoff?
- [ ] **Overall Similarity**: Does it follow the strict format `Overall Similarity: Significant Similarity` (or Moderate/Limited)?
- [ ] **Conclusion**: Verdict is strictly one of the 4 standard options.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid definitive legal terms (e.g., "invalid", "valid") in favor of technical comparisons.
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe".
  - [ ] **Terminology**: Avoid "Is a core technology". Instead, use:
    - "Characteristic configuration"
    - "Major technical configuration"
    - "Characteristic implementation described in the patent"
  - [ ] Avoid citing specific court case examples.
  - [ ] Use descriptive technical language.

# Examples

Example 1: Executing Prior Art Search
User says: "Find prior art for US-9876543-B2, which looked promising in Step 4"
Actions:

1. Read claim-analysis.md to identify similarities
2. Perform a hybrid search on patent and non-patent literature across General/Specific/Functional layers
3. Compare the MCP tool results and create a claim chart
   Result: 3-investigations/US-9876543-B2/prior-art.md is generated.

# Troubleshooting

Error: "No results found"
Cause: The search query is too long or the AND conditions are too strict.
Solution: Follow Rule IX and simplify the search query (e.g., remove modifiers) to search again.
