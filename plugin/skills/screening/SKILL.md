---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `target_patents` table populated
metadata:
  author: sonesuke
  version: 1.0.0
---

# Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for evaluation skill.

## Prerequisites

- `patents.db` must exist (generated in targeting skill, `target_patents` table)
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

### Execute Screening

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

- `patents.db` exists with `target_patents` table populated
- No `screened_patents` entries (or partial screening in progress)

### Final State

- All patents in `target_patents` have corresponding entries in `screened_patents`

## References

- `references/instructions.md` - Detailed screening process instructions
