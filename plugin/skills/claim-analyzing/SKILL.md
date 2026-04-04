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

## Constitution

### Core Principles

**Skill-Only Database Access**:

- ALWAYS use the Skill tool to load `investigation-fetching` for ALL database retrieval operations
- ALWAYS use the Skill tool to load `investigation-recording` for ALL database recording operations
- NEVER write raw SQL commands or read instruction files from investigation-fetching/investigation-recording

**Descriptive Technical Language**:

- Avoid legal assertions ("invalid", "valid", "Does not satisfy")
- Use descriptive technical language for analysis notes

## Skill Orchestration

### Execute Claim Analysis

**Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session.

**Process**:

1. **Get Patents to Analyze**:
   - Invoke `Skill: investigation-fetching` with request "Get list of patents with elements but no similarities"

2. **For each patent**, execute Steps 2a–2e in order:

   **2a. Get Data from Database**:
   - Invoke `Skill: investigation-fetching` with request "Search features"
   - Invoke `Skill: investigation-fetching` with request "Get elements for patent <patent-id>"

   **2b. Check Feature Coverage for Each Element**:
   - For each patent element, invoke `Skill: investigation-fetching` with request "Search feature: <element_label>"
   - **If feature NOT found**: Do NOT record as 'absent' automatically
     - Check test environment: `echo $SKILL_BENCH_TEST_CASE`
     - **If SKILL_BENCH_TEST_CASE is set** (testing mode): Use `Skill: skill-bench-harness:question-responder` with "Does the product have this feature: <element_description>?"
     - **If SKILL_BENCH_TEST_CASE is NOT set** (normal mode): Use `AskUserQuestion` tool
     - If positive: Invoke `Skill: investigation-recording` to record feature with `presence='present'`
     - If negative: Invoke `Skill: investigation-recording` to record feature with `presence='absent'`
     - If positive: Invoke `Skill: investigation-recording` to record feature with `presence='present'`
     - If negative: Invoke `Skill: investigation-recording` to record feature with `presence='absent'`

   **2c. Comparison Analysis**:
   - Compare product features against patent elements
   - Determine similarity level: `Significant`, `Moderate`, or `Limited`
   - Write detailed analysis notes

   **2d. Record Similarities**:
   - Invoke `Skill: investigation-recording` with request "Record similarities for patent <patent-id>: <similarities_data>"
   - Include: patent_id, claim_number, element_label, similarity_level, analysis_notes

   **2e. Legal Compliance Check**:
   - Invoke `Skill: legal-checking` with request "Check the following analysis notes for legal compliance: <analysis_notes>"
   - Revise if violations found

3. **Verify Results**: Confirm similarities were recorded to database

## State Management

### Initial State

- Patents in `elements` table without corresponding `similarities` entries exist

### Final State

- No patents in `elements` without corresponding `similarities` entries (all analyzed)
