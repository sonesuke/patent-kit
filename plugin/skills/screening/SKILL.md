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
- Load `investigation-recording` skill for data recording operations

## Constitution

### Core Principles

**Risk-Averse Screening**:

- When in doubt, err on the side of inclusion
- If a reference is "borderline", mark it as 'relevant' rather than 'irrelevant'
- Missing a risk is worse than reviewing an extra document

**Skill-Only Database Access**:

- ALWAYS use the Skill tool to load `investigation-recording` for ALL database operations
- NEVER write raw SQL commands or read instruction files from investigation-recording

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
   - From each result, extract:
     - `abstract_text` property — the official patent abstract (with 【課題】【解決手段】 format for JP patents)
     - `legal_status` property — the patent's current legal status (e.g., `Pending`, `Expired`, `Withdrawn`)
     - `title` property
   - **CRITICAL**: Do NOT use `snippet` — `snippet` is a search result summary, NOT the official abstract. Always use `abstract_text`.

4. **Evaluate and Record** (for each patent):

   Judgment criteria (relevance only):
   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Legal status handling:
   - Record `legal_status` from `fetch_patent` as-is in the database
   - Note expired/withdrawn patents in the reason field, but judgment remains based on relevance

   Judgment values: `relevant`, `irrelevant` (lowercase)

   For each patent, invoke `Skill: investigation-recording` with request "Record screening result for patent <patent-id>: judgment=<judgment>, legal_status=<legal_status>, reason=<reason>, abstract_text=<abstract_text from fetch_patent>"
   - **CRITICAL**: The `abstract_text` passed to recording MUST be the `abstract_text` from `fetch_patent`, NOT the `snippet` from `search_patents`.

5. **Verify Results**: Confirm all patents have corresponding `screened_patents` entries

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
