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

## Skill Orchestration

### 1. Ensure Database is Ready

**CRITICAL**: Before attempting any screening, ensure the database exists and is populated.

1. **Use the Glob tool to check if `csv/*.csv` files exist**
2. **Use the Skill tool to load `investigation-preparing`**:
   - If CSV files exist: Request "Initialize the patent database and import CSV files from csv/"
   - If no CSV files exist: Request "Initialize the patent database"
3. **Verify**: Use `investigation-fetching` skill to confirm patents are available in the database

### 2. Execute Screening

**CRITICAL**: Always use subagents for patent screening, regardless of patent count.

**Process**:

1. **Get Patents to Screen**:
   - Use `investigation-fetching` skill
   - Request: "Get list of unscreened patent IDs"

2. **Screen Patents**: Launch `patent-screener` subagents

   For each patent:
   - Start a `patent-screener` subagent
   - **Each subagent handles exactly one patent**

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
