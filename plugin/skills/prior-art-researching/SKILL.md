---
name: prior-art-researching
description: |
  Conducts prior art search for patents with Moderate/Significant similarities.

  Triggered when:
  - The user asks to:
    * "search for prior art"
    * "perform prior art research"
  - `patents.db` exists with `similarities` table containing Moderate/Significant entries
metadata:
  author: sonesuke
  version: 1.0.0
---

# Prior Art Researching

## Purpose

Search for prior art references (both patent and non-patent literature) for patents with Moderate/Significant similarity levels and store results in the database for further analysis.

## Prerequisites

- `patents.db` must exist with `similarities` table containing Moderate/Significant entries (from claim-analyzing skill)
- Load `investigation-fetching` skill for data retrieval operations
- Load `investigation-recording` skill for data recording operations

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Comprehensive Literature Coverage**:

- Use BOTH patent and non-patent literature sources
- Check academic papers, conference proceedings, and technical publications
- Document search results from both sources

**Evidence-Based Reporting**:

- Every assertion MUST be backed by specific citations
- Never say "This feature is known"
- Say "This feature is disclosed in [Patent ID], Column X, Line Y"

**Prior Art Cutoff Date**:

- Prior art must be published BEFORE the target's priority date
- Use publication dates, not priority dates, for cutoff determination

## Skill Orchestration

### Execute Prior Art Search

**CRITICAL**: Always use subagents for prior art search. **EVEN FOR A SINGLE PATENT - always launch a subagent.**

**Process**:

1. **Get Patents to Search**:
   - Use `investigation-fetching` skill
   - Request: "Get list of patents with Moderate/Significant similarities without prior art"

2. **Search Prior Art**: Launch `prior-art-searcher` subagents

   For each patent:
   - Start a `prior-art-searcher` subagent
   - **Each subagent handles exactly one patent**
   - **CRITICAL: Even if there is only ONE patent, you MUST still use a subagent**

3. **Verify Results**: Query database to confirm data recorded

## State Management

### Initial State

- Patents in `similarities` table with Moderate/Significant levels without corresponding `prior_arts` entries exist

### Final State

- No patents in `similarities` table with Moderate/Significant levels without corresponding `prior_arts` entries (all searched)
