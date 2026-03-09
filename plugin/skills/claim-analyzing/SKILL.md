---
name: claim-analyzing
description: |
  Performs claim analysis by comparing product features against patent elements.

  Triggered when:
  - The user asks to:
    * "perform claim analysis"
    * "analyze claim elements"
    * "analyze claims"
    * "analyze claim similarities"
    * "compare product features against patent elements"
  - The user mentions:
    * "claim analysis" with "patent" or "elements"
    * "similarity" with "elements" or "claims"
  - `patents.db` exists with `elements` table populated and `features` table populated
metadata:
  author: sonesuke
  version: 1.0.0
---

# Claim Analysis

## Purpose

Perform detailed claim analysis by comparing product specification against patent elements from database and recording similarity results.

## Prerequisites

- `features` table must exist with product features populated
- `patents.db` must exist with `elements` table populated (from evaluation skill)
- Load `investigation-fetching` skill for data retrieval operations
- Load `investigation-recording` skill for data recording operations

## Skill Orchestration

### Execute Claim Analysis

**CRITICAL**: Always use subagents for claim analysis. **EVEN FOR A SINGLE PATENT - always launch a subagent.**

**Process**:

1. **Get Patents to Analyze**:
   - Use `investigation-fetching` skill
   - Request: "Get list of patents with elements but no similarities"

2. **Analyze Patents**: Launch `claim-analyzer` subagents

   For each patent:
   - Start a `claim-analyzer` subagent
   - **Each subagent handles exactly one patent**
   - **CRITICAL: Even if there is only ONE patent, you MUST still use a subagent**

3. **Verify Results**: Confirm similarities were recorded to database

## State Management

### Initial State

- Patents in `elements` table without corresponding `similarities` entries exist

### Final State

- No patents in `elements` without corresponding `similarities` entries (all analyzed)
