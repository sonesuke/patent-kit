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
- Load `constitution-reminding` skill before starting analysis
- Load `investigating-database` skill for database operations
- `google-patent-cli:patent-fetch` skill available for retrieving patent data

## Process

The evaluation process consists of the following steps:

| Step | Description      | Instruction File                   |
| ---- | ---------------- | ---------------------------------- |
| 0    | Select Patent ID | Use `investigating-database` skill |
| 1    | Patent Analysis  | `references/instructions.md`       |

## Skill Orchestration

### 1. Load Required Skills (MANDATORY)

Use the Skill tool to load skills BEFORE starting any work:

1. **Constitution**: `constitution-reminding` - Understand core principles

### 2. Execute Evaluation

Follow the detailed evaluation process in `references/instructions.md`.

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
