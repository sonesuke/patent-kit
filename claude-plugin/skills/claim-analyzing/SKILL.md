---
name: claim-analyzing
description: |
  Analyzes screened patents by decomposing claims into elements and comparing against product features.

  Triggered when:
  - The user asks to:
    * "evaluate the patent"
    * "analyze claims"
    * "perform claim analysis"
    * "analyze claim elements"
    * "analyze claim similarities"
    * "compare product features against patent elements"
  - The user mentions:
    * "claim analysis" with "patent" or "elements"
    * "similarity" with "elements" or "claims"
  - `patents.db` exists with screened and indexed patents
---

# Claim Analysis

## Purpose

Analyze screened patents by decomposing claims into elements, comparing product features against patent elements, and recording similarity results.

## Prerequisites

- `patents.db` must exist with screened and indexed patents (from screening skill)
- `features` table must exist with product features populated

## Constitution

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Descriptive Technical Language**:

- Avoid legal assertions ("invalid", "valid", "Does not satisfy")
- Use descriptive technical language for analysis notes

**Mechanical Claims Recording**:

- Claims are already stored in the database by `index_patents` — read them via `get_claims`
- Do NOT re-generate or summarize claim text

## Skill Orchestration

### Execute Claim Analysis

**Do NOT delegate to subagents (Agent tool)** — call MCP tools directly from this session. Do NOT use Bash or Skill to invoke MCP tools.

**Process**:

1. **Get Next Patent**:
   - Call the `get_unanalyzed` MCP tool directly (no parameters):
     - If it says "All patents have been analyzed" → Analysis is complete
     - Otherwise → Returns 1 patent with `needs: "elements"` or `needs: "similarities"`

2. **If needs: "elements"**:

   a. Call `get_claims` with `decomposed: false` to get claims that have NOT been decomposed yet

   b. For EACH claim:
      1. Read the claim text
      2. Decompose into constituent elements based on the means/steps described in the claim text
      3. Call `record_elements`:
         - `elements`: [{ patent_id, claim_number, element_label, element_description }, ...]

   **CRITICAL Rules for Element Decomposition**:
   - Decompose ALL claims including dependent claims — do NOT skip dependent claims
   - Do NOT reference `specification.md` during decomposition — decompose based on claim text alone
   - Cut elements by the number of means/steps in the claim — do NOT force a specific number of elements

   c. **Go back to step 1** (get next patent — may return the same patent with needs: "similarities")

3. **If needs: "similarities"**:

   a. Call `get_product_features` to retrieve product features

   b. Call `get_elements` with `analyzed: false` to get elements that have NOT been analyzed yet

   c. For EACH element:
      1. Check if a matching product feature exists
      2. If feature NOT found: present to the user using `AskUserQuestion` (max 4 questions per call, group by unique functionality)
      3. If positive: Call `record_product_feature` with `presence='present'`
      4. If negative: Call `record_product_feature` with `presence='absent'`

   d. Determine similarity level: `Significant`, `Moderate`, or `Limited`

   e. Call `record_similarities`:
      - `similarities`: [{ patent_id, claim_number, element_label, similarity_level, analysis_notes }]

   f. Use `Skill: legal-checking` with request "Check the following analysis notes for legal compliance: <analysis_notes>"
      - Revise if violations found

   g. **Go back to step 1** (get next patent)

## State Management

### Initial State

- Patents marked as `relevant` without corresponding elements/similarities entries exist

### Final State

- No patents marked as `relevant` without corresponding elements/similarities entries (all analyzed)
