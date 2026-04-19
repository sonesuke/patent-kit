---
name: prior-art-researching
description: |
  Conducts prior art search for patents with Moderate/Significant similarities.

  Triggered when:
  - The user asks to:
    * "search for prior art"
    * "perform prior art research"
    * "find prior art references"
    * "conduct prior art search"
  - The user mentions:
    * "prior art" with "database" or "similarities"
    * "Moderate/Significant" with "prior art"
  - `patents.db` exists with `similarities` table containing Moderate/Significant entries
---

# Prior Art Researching

## Purpose

Search for prior art references (both patent and non-patent literature) for patents with Moderate/Significant similarity levels and store results in the database for further analysis.

## Prerequisites

- `patents.db` must exist with `similarities` table containing Moderate/Significant entries (from claim-analyzing skill)

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every analysis MUST test the target invention against prior art element by element
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

**Process**:

1. **Get Patents to Search**:
   - Use the `get_unresearched` MCP tool:
     ```
     get_unresearched({ limit: 5 })
     ```

2. **For each patent**, execute Steps 2a–2e in order:

   **2a. Get Patent Data**:
   - Use `search_patents` MCP tool with `patent_number` to get full patent details
   - Use `get_elements` MCP tool:
     ```
     get_elements({ patent_id: "<patent_id>" })
     ```

   **2b. Execute Multi-Layer Search**:
   - For each element, use search MCP tools in parallel:
     ```
     search_patents({ query: "<element-specific query>", limit: 30 })
     search_papers({ query: "<element-specific query>", limit: 20 })
     ```
   - **Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session

   **2c. Screen and Analyze Results**:
   - Identify Grade A candidates (highly relevant), verify publication dates
   - For patent references: use `search_patents` MCP tool with `patent_number` to get full details
   - For NPL: use `fetch_paper` MCP tool for full text
   - **Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session
   - Create claim charts with paragraph-level citations

   **2d. Record Results**:
   - Use `record_prior_arts` MCP tool:
     ```
     record_prior_arts({
       prior_arts: [
         {
           reference_id: "<patent_id or paper_id>",
           reference_type: "patent",
           title: "<title>",
           publication_date: "<YYYY-MM-DD>",
           elements: [
             { patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", relevance_level: "Significant", analysis_notes: "...", claim_chart: "..." }
           ]
         },
         {
           reference_id: "<paper_id>",
           reference_type: "npl",
           title: "<title>",
           publication_date: "<YYYY-MM-DD>",
           elements: [
             { patent_id: "<patent_id>", claim_number: 1, element_label: "Element A", relevance_level: "Moderate", analysis_notes: "..." }
           ]
         }
       ]
     })
     ```
   - **CRITICAL**: Record at ELEMENT LEVEL (each reference linked to claim_number and element_label)

3. **Verify Results**: Use `get_unresearched` MCP tool to confirm no patents remain. Provide summary with:
   - Patent ID and title
   - Number of prior art references found
   - Relevance levels for each reference
   - Key findings summary
   - Overall similarity assessment

## State Management

### Initial State

- Patents in `similarities` table with Moderate/Significant levels without corresponding `prior_arts` entries exist

### Final State

- No patents in `similarities` table with Moderate/Significant levels without corresponding `prior_arts` entries (all searched)
