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

## Skill Orchestration

### Execute Evaluation

**CRITICAL**: Always use subagents for patent evaluation. **EVEN FOR A SINGLE PATENT - always launch a subagent.**

**Process**:

1. **Get Patents to Analyze**:
   - Use `investigation-fetching` skill
   - Request: "Get list of relevant patents without evaluation"

2. **Analyze Patents**: Launch `patent-evaluator` subagents

   For each patent:
   - Start a `patent-evaluator` subagent
   - **Each subagent handles exactly one patent**
   - **CRITICAL: Even if there is only ONE patent, you MUST still use a subagent**

3. **Verify Results**: Query database to confirm data recorded

## State Management

### Initial State

- Patents in `screened_patents` table marked as `relevant` without corresponding claims/elements entries exist

### Final State

- No patents in `screened_patents` marked as `relevant` without corresponding claims/elements entries (all evaluated)
