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
metadata:
  author: sonesuke
  version: 1.0.0
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
   - Use `investigation-fetching` skill
   - Request: "Get list of patents with Moderate/Significant similarities without prior art"

2. **For each patent**, execute Steps 2a–2e in order:

   **2a. Get Patent Data**:
   - Invoke `Skill: google-patent-cli:patent-fetch` with patent ID
   - Invoke `Skill: investigation-fetching` with request "Get elements for patent <patent-id>"
   - Extract: title, abstract, claims, priority date, elements

   **2b. Execute Multi-Layer Search**:
   - For each element, invoke search Skills in parallel:
     ```
     Skill: skill="google-patent-cli:patent-search" args="<query>"
     Skill: skill="arxiv-cli:arxiv-search" args="<query>"
     ```
   - **Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session

   Execute three search layers per element:

   | Layer | Purpose | Keywords | Limit |
   |-------|---------|----------|-------|
   | 1 | General terminology | High-level terms from element description | 10–20 |
   | 2 | Specific nomenclature | Model names, algorithms, parameter names | 30–50 |
   | 3 | Functional/role-based | "configured to", "means for" | 10–20 |

   - Include `publication_before: "<priority date>"` in all searches

   **2c. Screen and Analyze Results**:
   - Identify Grade A candidates (highly relevant), verify publication dates
   - For patent references: invoke `Skill: google-patent-cli:patent-fetch` with patent ID to get full details
   - For NPL: invoke `Skill: arxiv-cli:arxiv-fetch` for full text
   - **Do NOT delegate to subagents (Agent tool)** — invoke Skills directly from this session
   - Create claim charts with paragraph-level citations

   **2d. Record Results**:
   - Invoke `Skill: investigation-recording` with prior art data for each reference:
     - patent_id, claim_number, element_label, reference_id, reference_type, title, relevance_level (Significant/Moderate/Limited), analysis_notes, publication_date, claim_chart
   - **CRITICAL**: Record at ELEMENT LEVEL (each reference linked to claim_number and element_label)

3. **Verify Results**: Confirm all prior arts recorded to database. Provide summary with:
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

