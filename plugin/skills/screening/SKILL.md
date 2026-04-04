---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `target_patents` table populated (will be prepared by this skill if missing)
metadata:
  author: sonesuke
  version: 1.0.0
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

2. **For each patent**, execute Steps 2a–2d:

   **2a. Read Specification**:
   - Read `specification.md` to understand Theme, Domain, and Target Product

   **2b. Fetch Patent Data**:
   - Invoke `Skill: google-patent-cli:patent-fetch` with patent ID
   - Extract: title, abstract, legal status

   **2c. Evaluate and Judge**:

   Judgment criteria:
   - **Expired or Withdrawn** → `expired`
   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Judgment values: `relevant`, `irrelevant`, `expired` (lowercase)

   **2d. Record Result**:
   - Invoke `Skill: investigation-recording` with request "Record screening result for patent <patent-id>: <judgment_data>"

3. **Verify Results**: Confirm all patents have corresponding `screened_patents` entries

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
