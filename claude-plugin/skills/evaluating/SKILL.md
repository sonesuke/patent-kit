---
name: evaluating
description: |
  Analyzes screened patents by decomposing claims and elements.

  Triggered when:
  - The user asks to:
    * "evaluate the patent"
    * "analyze claim elements"
  - `patents.db` exists with `screened_patents` table populated
---

# Evaluation

## Purpose

Analyze screened patents by decomposing claims into elements and storing analysis data in the database for further processing.

## Prerequisites

- `patents.db` must exist with `screened_patents` table populated (from screening skill)

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Mechanical Claims Recording**:

- Claims should be recorded directly from fetch results without LLM re-generation
- Use `search_patents` MCP tool with `patent_number` to get the full claims data
- Record claims mechanically (preserving original claim text)

## Skill Orchestration

### Execute Evaluation

**Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session.

**Process**:

1. **Get Patents to Analyze**:
   - Use the `get_unevaluated` MCP tool:
     ```
     get_unevaluated({ limit: 10 })
     ```

2. **Batch Fetch Patent Data** (up to 10 patents in parallel):
   - Split patents into batches of 10
   - For each patent, use `search_patents` MCP tool with `patent_number` to get full patent details including claims

3. **Record Claims** (for each patent — mechanical, no LLM text generation):
   - From the fetch result, extract claims data directly
   - Use the `record_claims` MCP tool:
     ```
     record_claims({
       patent_id: "<patent_id>",
       claims: [
         { claim_number: 1, claim_type: "independent", claim_text: "<original text>" },
         { claim_number: 2, claim_type: "dependent", claim_text: "<original text>" }
       ]
     })
     ```
   - **CRITICAL**: Use the original claim text from fetch results — do NOT pass through LLM generation which may compress or summarize long repetitive structures
   - After recording, verify with `get_claims` MCP tool

4. **Analyze and Record Elements** (for each patent — LLM interpretation task):
   - For EACH claim (independent AND dependent), execute the following:
     1. Use `get_claims` MCP tool to read the claim text
     2. Decompose into constituent elements based on the means/steps described in the claim text
     3. Use `record_elements` MCP tool:
        ```
        record_elements({
          elements: [
            { patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", element_description: "..." },
            { patent_id: "<patent_id>", claim_number: 1, element_label: "Element B", element_description: "..." }
          ]
        })
        ```

   **CRITICAL Rules for Element Decomposition**:
   - Decompose ALL claims including dependent claims — do NOT skip dependent claims
   - Do NOT reference `specification.md` during decomposition — decompose based on claim text alone
   - Cut elements by the number of means/steps in the claim — do NOT force a specific number of elements

5. **Verify Results**: Use `get_claims` and `get_elements` MCP tools to confirm all data is recorded

## State Management

### Initial State

- Patents in `screened_patents` table marked as `relevant` without corresponding claims/elements entries exist

### Final State

- No patents in `screened_patents` marked as `relevant` without corresponding claims/elements entries (all evaluated)
