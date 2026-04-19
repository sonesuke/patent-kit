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

1. **Get Patents to Analyze**:
   - Call the `get_unevaluated` MCP tool directly (do NOT use Bash or Skill):
     - `limit`: 5
   - If no patents returned → Claim analysis is complete

2. **For each patent**, execute Steps 2a–2d in order:

   **2a. Decompose Claims into Elements**:
   - Call the `get_claims` MCP tool to read the claim text
   - For EACH claim (independent AND dependent):
     1. Decompose into constituent elements based on the means/steps described in the claim text
     2. Call the `record_elements` MCP tool:
        - `elements`: [{ patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", element_description: "..." }, ...]

   **CRITICAL Rules for Element Decomposition**:
   - Decompose ALL claims including dependent claims — do NOT skip dependent claims
   - Do NOT reference `specification.md` during decomposition — decompose based on claim text alone
   - Cut elements by the number of means/steps in the claim — do NOT force a specific number of elements

   **2b. Check Feature Coverage**:
   - Call the `get_product_features` MCP tool to retrieve product features
   - Call the `get_elements` MCP tool for each patent
   - For each patent element, check if a matching product feature exists
   - **If feature NOT found**: Do NOT record as 'absent' automatically — collect unmatched elements and present them to the user in a single batch using `AskUserQuestion` (max 4 questions per call)
   - If positive: Call the `record_product_feature` MCP tool with `presence='present'`
   - If negative: Call the `record_product_feature` MCP tool with `presence='absent'`

   **2c. Comparison Analysis & Record Similarities**:
   - Compare product features against patent elements
   - Determine similarity level: `Significant`, `Moderate`, or `Limited`
   - Write detailed analysis notes
   - Call the `record_similarities` MCP tool:
     - `similarities`: [{ patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", similarity_level: "Significant", analysis_notes: "...", ... }]

   **2d. Legal Compliance Check**:
   - Use `Skill: legal-checking` with request "Check the following analysis notes for legal compliance: <analysis_notes>"
   - Revise if violations found

3. **Repeat** from step 1 until `get_unevaluated` returns no patents

## State Management

### Initial State

- Patents marked as `relevant` without corresponding elements/similarities entries exist

### Final State

- No patents marked as `relevant` without corresponding elements/similarities entries (all analyzed)
