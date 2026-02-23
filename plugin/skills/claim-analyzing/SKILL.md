---
name: claim-analyzing
description: "Generates a claim analysis report for a patent. Triggered when the user asks to 'perform claim analysis' or 'execute step 4'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 4: Claim Analysis

Your task is to create the Claim Analysis Report based on the Spec.

## Instructions

### User Interview for Product Understanding

For accurate claim analysis, understanding the target product is crucial.

- **Rule**: Ensure `0-specifications/specification.md` exists and contains complete product information.
- **Check**: If specification is incomplete or missing, notify the user before proceeding.
- **Information Needed**: Clear definition of the "Target Product" to compare against claim elements.

### Template Adherence

- **Requirement**: Strict adherence to the output template is required.
- **Template**: `templates/claim-analysis-template.md` - Use for `3-investigations/<patent-id>/claim-analysis.md`

### Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next patent pending claim analysis will be automatically selected.

### Process

1. **Read Constitution**: Load the `constitution-reminding` skill to understand the core principles.
2. **Read Legal Checker**: Load the `legal-checking` skill to understand legal compliance guidelines.

#### Step 0: Determine Patent ID

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
> - Linux/Mac: `./scripts/shell/next-claim-analysis-patent.sh`
> - Windows: `.\scripts\powershell\next-claim-analysis-patent.ps1`

This script finds the first patent in `3-investigations/` that has `evaluation.md` but no `claim-analysis.md` yet.

#### Step 1: Comparison Analysis

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

3. **Draft**: Fill `[claim-analysis-template.md](templates/claim-analysis-template.md)`.
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

### Output Management

To maintain context window efficiency:

- **Rule**: When reading evaluation.md, use the saved JSON file for patent data.
  - Path: `3-investigations/<patent-id>/json/<patent-id>.json`
  - **Requirement**: Do NOT load large JSON outputs directly into context.
  - **Action**: Use Read tool or jq to access specific fields (e.g., constituent_elements, dependent_claims) from saved JSON.

### Output

- `3-investigations/<patent-id>/claim-analysis.md`: The claim analysis report.

### Quality Gates

- [ ] Product specification is complete and up-to-date.
- [ ] Conflict Analysis (Claim Chart) is complete and compares all elements.
- [ ] Similarity levels are assigned to each element (Significant/Moderate/Limited).
- [ ] Overall Similarity follows strict format: `Overall Similarity: Significant Similarity` (or Moderate/Limited).
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology".
  - [ ] Avoid citing specific court case examples.
  - [ ] Use descriptive technical language (e.g., "features not found", "low likelihood of mapping", "fundamental feature").
- [ ] Claim analysis report follows the template format.

Run /patent-kit:prior-art-researching <patent-id>

# Examples

Example 1: Starting Claim Analysis
User says: "Please perform a claim analysis on US-1234567-B2"
Actions:

1. Load the constitution
2. Read 3-investigations/US-1234567-B2/evaluation.md and the product specification
3. Perform comparative analysis on each claim element
   Result: claim-analysis.md is generated, saving the comparison between the specific patent and the product

# Troubleshooting

Error: "Missing evaluation.md"
Cause: Attempted to run claim analysis on a patent that hasn't completed the evaluation phase (Phase 3).
Solution: Run `/patent-kit:evaluating <patent-id>` first to generate the evaluation report.
