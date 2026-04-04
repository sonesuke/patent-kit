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

2. **For each patent**, execute Steps 2a–2d in order:

   **2a. Fetch Patent Data**:
   - Invoke `Skill: google-patent-cli:patent-fetch` with patent ID
   - Extract: title, abstract, all claims

   **2b. Analyze Claims**:
   - Extract ALL claims from the patent (both independent and dependent)
   - For EACH claim, decompose into constituent elements (A, B, C...)

   **2c. Record Claims**:
   - Invoke `Skill: investigation-recording` with request "Record claims for patent <patent-id>: <claims_data>"

   **2d. Record Elements**:
   - Invoke `Skill: investigation-recording` with request "Record elements for patent <patent-id>: <elements_data>"

3. **Verify Results**: Query database to confirm all claims and elements recorded

## State Management

### Initial State

- Patents in `screened_patents` table marked as `relevant` without corresponding claims/elements entries exist

### Final State

- No patents in `screened_patents` marked as `relevant` without corresponding claims/elements entries (all evaluated)
