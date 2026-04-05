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
- Load `investigation-fetching` skill for data retrieval operations
- Load `investigation-recording` skill for data recording operations

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Skill-Only Database Access**:

- ALWAYS use the Skill tool to load `investigation-recording` for ALL database operations
- NEVER write raw SQL commands or read instruction files from investigation-recording
- The investigation-recording skill handles SQL operations internally when invoked via Skill tool

## Skill Orchestration

### Execute Evaluation

**Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session.

**Process**:

1. **Get Patents to Analyze**:
   - Invoke `Skill: investigation-fetching` with request "Get list of relevant patents without evaluation"

2. **Batch Fetch Patent Data** (up to 10 patents in parallel):
   - Split patents into batches of 10
   - For each batch, invoke `Skill: google-patent-cli:patent-fetch` for all patents **in parallel**
   - After `fetch_patent` returns each dataset, use `execute_cypher` to get claims.
     **You MUST use this EXACT query — do NOT modify the node label or property names:**
     ```cypher
     MATCH (c:claims) RETURN c.number, c.text
     ```
   - **CRITICAL**: Do NOT add `ORDER BY` or `WHERE` clauses — they cause parse errors or return null due to Cypher parser bugs.
     Also do NOT use `MATCH (p:Patent)-[:claims]->(c:claims)` (relationship pattern), `[:HAS_CHILD]->(c:claim)`, `[:claim]->(c:claim)`, `p.claims`, or `[:claims]->(c:claim)`.

3. **Analyze and Record** (for each patent):
   - Extract ALL claims (both independent and dependent)
   - For EACH claim, decompose into constituent elements (A, B, C...)
   - Invoke `Skill: investigation-recording` with request "Record claims for patent <patent-id>: <claims_data>"
   - Invoke `Skill: investigation-recording` with request "Record elements for patent <patent-id>: <elements_data>"

4. **Verify Results**: Confirm all claims and elements are recorded in the database

## State Management

### Initial State

- Patents in `screened_patents` table marked as `relevant` without corresponding claims/elements entries exist

### Final State

- No patents in `screened_patents` marked as `relevant` without corresponding claims/elements entries (all evaluated)
