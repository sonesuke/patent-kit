---
name: evaluating
description: |
  Analyzes screened patents by decomposing claims and elements.

  Triggered when:
  - The user asks to:
    * "evaluate the patent"
    * "analyze claim elements"
  - `patents.db` exists with `screened_patents` table populated
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 3: Evaluation

## Purpose

Analyze screened patents by decomposing claims into elements and storing analysis data in the database for further processing.

## Prerequisites

- `patents.db` must exist with `screened_patents` table populated (from Phase 2 Screening)
- Load `investigation-preparing` skill for data retrieval operations
- Load `investigation-recording` skill for data recording operations
- `google-patent-cli:patent-fetch` skill available for retrieving patent data

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

## Skill Orchestration

### Execute Evaluation

**CRITICAL**: For multiple patents (2+), you MUST use the Agent tool with patent-evaluator subagent for parallel processing.

**Process**:

1. **Get Patents to Analyze**:
   - Use `investigation-preparing` skill
   - Request: "Get list of relevant patents without evaluation"

2. **Analyze Patents**:

   **If single patent**: Process directly following steps 3-4

   **If multiple patents (2+)**: MUST use Agent tool with patent-evaluator subagent

   ```
   Agent tool parameters:
   - subagent_type: "patent-evaluator"
   - name: "evaluator-<patent-id>"
   - description: "Analyze patent <PATENT_ID> and record claims/elements"
   - prompt: "Fetch patent <PATENT_ID> using google-patent-cli:patent-fetch skill, decompose Claim 1 into elements, and record all claims and elements using investigation-recording skill"
   ```

3. **Record Claims**: Use `investigation-recording` skill
4. **Record Elements**: Use `investigation-recording` skill

5. **Verify Results**: Query database to confirm data recorded

## State Management

### Initial State

- `patents.db` exists with `screened_patents` table populated (from Phase 2 Screening)
- No claims/elements data in database (or partial evaluation in progress)

### Final State

- Claims and elements stored in database (`claims` and `elements` tables)
- Analysis data available for further processing

## Examples

- See `references/examples.md` for detailed usage examples

## References

- `references/instructions.md` - Detailed evaluation process instructions
- `references/examples.md` - Usage examples and detailed workflows
- `references/troubleshooting.md` - Common issues and solutions
