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
---

# Claim Analysis

## Purpose

Perform detailed claim analysis by comparing product specification against patent elements from database and recording similarity results.

## Prerequisites

- `features` table must exist with product features populated
- `patents.db` must exist with `elements` table populated (from evaluation skill)

## Constitution

### Core Principles

**Descriptive Technical Language**:

- Avoid legal assertions ("invalid", "valid", "Does not satisfy")
- Use descriptive technical language for analysis notes

**MCP Tool Direct Access**:

- Use MCP tools directly for all database operations
- No need to invoke intermediate skills

## Skill Orchestration

### Execute Claim Analysis

**Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session.

**Process**:

1. **Get Patents to Analyze**:
   - Use the `get_unanalyzed` MCP tool:
     ```
     get_unanalyzed({ limit: 5 })
     ```

2. **For each patent**, execute Steps 2a–2e in order:

   **2a. Get Data from Database**:
   - Use `get_product_features` MCP tool to retrieve product features
   - Use `get_elements` MCP tool for each patent:
     ```
     get_elements({ patent_id: "<patent_id>" })
     ```

   **2b. Check Feature Coverage for Each Element**:
   - For each patent element, check if a matching product feature exists in the results
   - **If feature NOT found**: Do NOT record as 'absent' automatically — collect it
   - After checking ALL elements, if any unmatched elements remain, present them to the user in a single batch using `AskUserQuestion` (max 4 questions per call, group by unique functionality — do NOT ask about duplicate capabilities across patents)
   - If positive: Use `record_product_feature` MCP tool with `presence='present'`
   - If negative: Use `record_product_feature` MCP tool with `presence='absent'`

   **2c. Comparison Analysis**:
   - Compare product features against patent elements
   - Determine similarity level: `Significant`, `Moderate`, or `Limited`
   - Write detailed analysis notes

   **2d. Record Similarities**:
   - Use `record_similarities` MCP tool:
     ```
     record_similarities({
       similarities: [
         { patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", similarity_level: "Significant", analysis_notes: "..." },
         { patent_id: "<patent_id>", claim_number: 1, element_label: "Element B", similarity_level: "Limited", analysis_notes: "..." }
       ]
     })
     ```

   **2e. Legal Compliance Check**:
   - Use `Skill: legal-checking` with request "Check the following analysis notes for legal compliance: <analysis_notes>"
   - Revise if violations found

3. **Verify Results**: Use `get_unanalyzed` MCP tool to confirm no patents remain

## State Management

### Initial State

- Patents in `elements` table without corresponding `similarities` entries exist

### Final State

- No patents in `elements` without corresponding `similarities` entries (all analyzed)
