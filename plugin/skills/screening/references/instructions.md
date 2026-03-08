# Screening Instructions

## Purpose

Filter collected patents by legal status and relevance to prepare for evaluation skill.

## Prerequisites

- `patents.db` must exist (generated in targeting skill, `target_patents` table)
- `specification.md` must exist (Product/Theme definition)

## Process

**CRITICAL**: Always use subagents for patent screening, regardless of patent count.

**Steps**:

1. **Get Patents to Screen**:
   - Use `investigation-fetching` skill
   - Request: "Get list of unscreened patent IDs"

2. **Screen Patents**: Launch `patent-screener` subagents

   For each patent:
   - Start a `patent-screener` subagent
   - **Each subagent handles exactly one patent**

## Output

- `patents.db` (screened_patents table): Database of screened patents with judgments and reasons
