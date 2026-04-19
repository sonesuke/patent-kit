---
name: evaluating
description: |
  Analyzes screened patents by decomposing claims and elements.

  Triggered when:
  - The user asks to:
    * "evaluate the patent"
    * "analyze claim elements"
  - `patents.db` exists with screened and indexed patents
---

# Evaluation

## Purpose

Analyze screened patents by decomposing claims into elements and storing analysis data in the database for further processing.

## Prerequisites

- `patents.db` must exist with screened and indexed patents (from screening skill)

## Constitution

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Mechanical Claims Recording**:

- Claims are already stored in the database by `index_patents` — read them via `get_claims`
- Do NOT re-generate or summarize claim text

## Skill Orchestration

### Execute Evaluation

**Do NOT delegate to subagents (Agent tool)** — call MCP tools directly from this session. Do NOT use Bash or Skill to invoke MCP tools.

**Process**:

1. **Get Patents to Analyze**:
   - Call the `get_unevaluated` MCP tool directly (do NOT use Bash or Skill):
     - `limit`: 10
   - If no patents returned → Evaluation is complete

2. **Analyze and Record Elements** (for each patent — LLM interpretation task):
   - For EACH claim (independent AND dependent), execute the following:
     1. Call the `get_claims` MCP tool to read the claim text
     2. Decompose into constituent elements based on the means/steps described in the claim text
     3. Call the `record_elements` MCP tool directly (do NOT use Bash or Skill):
        - `elements`: [{ patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", element_description: "..." }, ...]

   **CRITICAL Rules for Element Decomposition**:
   - Decompose ALL claims including dependent claims — do NOT skip dependent claims
   - Do NOT reference `specification.md` during decomposition — decompose based on claim text alone
   - Cut elements by the number of means/steps in the claim — do NOT force a specific number of elements

3. **Repeat** from step 1 until `get_unevaluated` returns no patents

## State Management

### Initial State

- Patents marked as `relevant` in `screened_patents` without corresponding claims/elements entries exist

### Final State

- No patents marked as `relevant` without corresponding claims/elements entries (all evaluated)
