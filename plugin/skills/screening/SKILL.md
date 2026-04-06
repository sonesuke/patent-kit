---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `target_patents` table populated (will be prepared by this skill if missing)
---

# Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for evaluation skill.

## Prerequisites

- `patents.db` will be initialized by this skill via `investigation-preparing` if it does not exist
- `specification.md` must exist (Product/Theme definition)
- Load `investigation-fetching` skill for data retrieval operations

## Constitution

### Core Principles

**Risk-Averse Screening**:

- When in doubt, err on the side of inclusion
- If a reference is "borderline", mark it as 'relevant' rather than 'irrelevant'
- Missing a risk is worse than reviewing an extra document

**Skill-Only Database Access**:

- Use `investigation-recording` skill for elements recording (LLM interpretation task)
- For claims and screening recording, use sqlite3 JSON functions directly with `output_file` — do NOT pass text through LLM generation

## Skill Orchestration

### 1. Ensure Database is Ready

**CRITICAL**: Before attempting any screening, ensure the database exists and is populated.

1. **Use the Glob tool to check if `csv/*.csv` files exist**
2. **Use the Skill tool to load `investigation-preparing`**:
   - If CSV files exist: Request "Initialize the patent database and import CSV files from csv/"
   - If no CSV files exist: Request "Initialize the patent database"
3. **Verify**: Use `investigation-fetching` skill to confirm patents are available in the database

### 2. Execute Screening

**Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session.

**Process**:

1. **Get Patents to Screen**:

   - Invoke `Skill: investigation-fetching` with request "Get list of unscreened patent IDs"

2. **Read Specification** (once):

   - Read `specification.md` to understand Theme, Domain, and Target Product

3. **Batch Fetch Patent Data** (up to 10 patents in parallel):

   - Split unscreened patents into batches of 10
   - For each batch, invoke `Skill: google-patent-cli:patent-fetch` for all patents **in parallel**
   - From each result, note the `output_file` path — this contains `abstract_text`, `legal_status`, and `title` as JSON fields
   - **Do NOT use `execute_cypher`** — all needed data is in the `output_file`, extract with `json_extract()`
   - **CRITICAL**: Do NOT use `snippet` — `snippet` is a search result summary, NOT the official abstract.

4. **Evaluate and Record** (for each patent):

   Judgment criteria (relevance only):

   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Judgment values: `relevant`, `irrelevant` (lowercase)

   After determining judgment and reason, record using sqlite3 JSON functions directly.
   **Do NOT pass `abstract_text` through LLM generation — use `readfile()` to extract from `output_file` mechanically:**

   ```bash
   sqlite3 patents.db "INSERT OR REPLACE INTO screened_patents (patent_id, judgment, legal_status, reason, abstract_text, updated_at)
   VALUES (
     '<patent_id>',
     '<judgment>',
     json_extract(CAST(readfile('<output_file>') AS TEXT), '$.legal_status'),
     '<reason>',
     json_extract(CAST(readfile('<output_file>') AS TEXT), '$.abstract_text'),
     datetime('now')
   );"
   ```

   Note: Only `judgment` and `reason` come from LLM analysis. `abstract_text` and `legal_status` are extracted mechanically from the `output_file`.

5. **Verify Results**: Confirm all patents have corresponding `screened_patents` entries

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
