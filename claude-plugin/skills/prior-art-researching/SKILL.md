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

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

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
   - Call the `get_unresearched` MCP tool directly (do NOT use Bash or Skill):
     - `limit`: 5

2. **For each patent**, execute Steps 2a–2e in order:

   **2a. Get Patent Data**:
   - Call the `search_patents` MCP tool with `patent_number` to get full patent details (do NOT use Bash or Skill)
   - Call the `get_elements` MCP tool:
     - `patent_id`: "<patent_id>"

   **2b. Execute Multi-Layer Search**:
   - For each element, call the search MCP tools in parallel (do NOT use Bash or Skill):
     - Call `search_patents` MCP tool: `query`: "<element-specific query>", `limit`: 30
     - Call `search_papers` MCP tool: `query`: "<element-specific query>", `limit`: 20

   **2c. Screen and Analyze Results**:
   - Identify Grade A candidates (highly relevant), verify publication dates
   - For patent references: call `search_patents` MCP tool with `patent_number` to get full details
   - For NPL: call `fetch_paper` MCP tool for full text
   - Create claim charts with paragraph-level citations

   **2d. Record Results**:
   - Call the `record_prior_arts` MCP tool directly (do NOT use Bash or Skill):
     - `prior_arts`: [{ reference_id, reference_type, title, publication_date, elements: [{ patent_id, claim_number, element_label, relevance_level, analysis_notes, claim_chart }] }]
   - **CRITICAL**: Record at ELEMENT LEVEL (each reference linked to claim_number and element_label)

3. **Verify Results**: Call the `get_unresearched` MCP tool to confirm no patents remain. Provide summary with:
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
