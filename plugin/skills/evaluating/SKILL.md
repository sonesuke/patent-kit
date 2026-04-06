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
- Load `investigation-recording` skill for elements recording

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Skill-Only Database Access**:

- Use `investigation-recording` skill for elements recording (LLM interpretation task)
- For claims recording, use sqlite3 JSON functions directly with `output_file` — do NOT pass claim text through LLM generation (see Step 3)

## Skill Orchestration

### Execute Evaluation

**Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session.

**Process**:

1. **Get Patents to Analyze**:
   - Invoke `Skill: investigation-fetching` with request "Get list of relevant patents without evaluation"

2. **Batch Fetch Patent Data** (up to 10 patents in parallel):
   - Split patents into batches of 10
   - For each batch, invoke `Skill: google-patent-cli:patent-fetch` for all patents **in parallel**

3. **Record Claims** (for each patent — mechanical, no LLM text generation):
   - After `fetch_patent` returns the `output_file`, use sqlite3 JSON functions to INSERT directly.
     **Do NOT read claim text and regenerate it — LLM will summarize/compress long repetitive structures.**
     ```bash
     sqlite3 patents.db "
     INSERT OR REPLACE INTO claims (patent_id, claim_number, claim_type, claim_text, created_at, updated_at)
     SELECT
       '<patent_id>',
       CAST(json_extract(value, '$.number') AS INTEGER),
       CASE
         WHEN CAST(json_extract(value, '$.number') AS INTEGER) = 1 THEN 'independent'
         ELSE 'dependent'
       END,
       json_extract(value, '$.text'),
       datetime('now'),
       datetime('now')
     FROM json_each(json_extract(CAST(readfile('<output_file>') AS TEXT), '$.claims'));
     "
     ```
   - After INSERT, verify with: `sqlite3 patents.db "SELECT COUNT(*) FROM claims WHERE patent_id = '<patent_id>'"`
   - Then UPDATE `claim_type` for each independent claim identified by reading claims from the DB:
     ```bash
     sqlite3 patents.db "SELECT claim_number, substr(claim_text, 1, 80) FROM claims WHERE patent_id = '<patent_id>'"
     ```
     Identify independent claims (those NOT starting with "前記", "The ... of claim", "請求項", etc.) and UPDATE:
     ```bash
     sqlite3 patents.db "UPDATE claims SET claim_type = 'independent', updated_at = datetime('now') WHERE patent_id = '<patent_id>' AND claim_number IN (<independent_numbers>)"
     ```

4. **Analyze and Record Elements** (for each patent — LLM interpretation task):
   - Read claims from the DB: `sqlite3 patents.db "SELECT claim_number, claim_text FROM claims WHERE patent_id = '<patent_id>'"`
   - For EACH claim, decompose into constituent elements (A, B, C...)
   - Invoke `Skill: investigation-recording` with request "Record elements for patent <patent-id>: <elements_data>"

5. **Verify Results**: Confirm all claims and elements are recorded in the database

## State Management

### Initial State

- Patents in `screened_patents` table marked as `relevant` without corresponding claims/elements entries exist

### Final State

- No patents in `screened_patents` marked as `relevant` without corresponding claims/elements entries (all evaluated)
