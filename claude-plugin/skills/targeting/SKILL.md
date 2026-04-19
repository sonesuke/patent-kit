---
name: targeting
description: |
  Searches patent databases to create a target population based on specifications.

  Triggered when:
  - The user asks to:
    * "create a target population"
    * "determine the target population"
    * "run the patent search"
---

# Targeting

## Purpose

Generate high-precision search queries and create a consolidated patent
population for screening.

## Prerequisites

- `specification.md` must exist (generated in concept-interviewing skill)

## Constitution

### Core Principles

**Search Query Optimization**:

- Start with broad, essential keywords (2-4 terms maximum)
- If zero results, progressively simplify:
  1. Remove technical modifiers and adjectives
  2. Break compound concepts into separate searches
  3. Try synonyms or broader terms
- Document query evolution in reports

### Template Adherence

- **Requirement**: Strict adherence to the output templates is required.
- **Templates**: Located in `assets/` directory.
  - `targeting-template.md` - Use for `targeting.md`
  - `keywords-template.md` - Use for `keywords.md`

### MCP Tool Direct Access

Call the following MCP tools directly. Do NOT use the Skill tool or Bash to call them.

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

- Patent search → `search_patents` MCP tool
- Assignee check → `check_assignee` MCP tool

### Search Scope

Target patent research MUST be scoped to the **Target Market** specified in
`specification.md`.

- **Rule**: Use the country code from the Target Market field (e.g., `US`,
  `JP`, `EP`, `CN`).
- **Mechanism**: If the target market uses a non-English language, use machine
  translation for keyword queries.

## Skill Orchestration

### Process

#### Step 1: Check Specification

Use the Glob tool to check if `specification.md` exists:

- **If exists**: Proceed to targeting execution
- **If NOT exists**:
  1. Use the Skill tool to load the `concept-interviewing` skill to create the
     specification
  2. Wait for the concept-interviewing to complete
  3. Verify that `specification.md` has been created
  4. Only proceed after the specification file exists

#### Step 2: Execute Targeting

Perform the following targeting process relative to the **Priority Date Cutoff**
from `specification.md`.

**IMPORTANT**: For prior art searches, use the **Priority Date** as the cutoff.
Patents published before the Priority Date are considered prior art.

**IMPORTANT**: This step should be conducted **interactively with the user**.
Show results, ask for feedback, and refine the queries together.

##### Phase 1: Competitor Patent Research

1. **Start Broad**:
   - Call the `search_patents` MCP tool directly (do NOT use Bash or Skill):
     - `assignee`: ["<Combined Assignees>"]
     - `country`: "<Country from Target Market in specification.md>"
     - `limit`: 20

2. **Check Volume**:
   - If total count is **under 2000**: This is a good starting point. Check the
     top 20 snippets to understand what kind of patents they are filing.
   - If total count is **over 2000**: You need to narrow it down.

3. **Iterative Narrowing & Keyword Extraction**:
   - Add a keyword representing the "Product Concept" to the query parameter.
   - **CRITICAL RULE 1**: **Always use quotes** for keywords (e.g.,
     `"smartphone"` instead of `smartphone`) to ensure exact matching and
     proper AND logic.
   - **CRITICAL RULE 2**: **Mandatory Noise Analysis**. After _every_ search
     command, inspect the top 20 snippets.
   - **CRITICAL RULE 3**: **Over-Filtering Check**. If adding a keyword reduces
     the count to **under 200**, ask the user if this is acceptable.
   - **Repeat**: Continue adding quoted keywords until the count is reasonable (< 2000)
     and relevance is high.

##### Phase 2: Market Patent Research

1. **Apply Keywords**:
   - Use the "Golden Keywords" discovered in Phase 1 (refer to `keywords.md`).
   - Call the `search_patents` MCP tool with the refined query (do NOT use Bash or Skill).

2. **Iterative Narrowing**:
   - Similar to Phase 1, if the count is > 2000, add more specific concept
     keywords (always quoted).
   - **Goal**: Reach < 2000 hits with high relevance.

#### Step 3: Create Output Files

- Create `targeting.md` using the template `assets/targeting-template.md`
- Create `keywords.md` using the template `assets/keywords-template.md`

#### Step 4: CSV Download and Import

Upon successful targeting, the user must download search results as CSV from Google Patents.

1. **Output Google Patents URL**: Present the final search query as a Google Patents URL
2. **Wait for CSV**: Do NOT proceed until the user has placed the CSV file in the `csv/` directory.
3. **Import CSV**: Call the `import_csv` MCP tool directly (do NOT use Bash or Skill):
   - `file_path`: "csv/<filename>.csv"
4. After import is complete, proceed to screening.

#### Step 5: Transition to Screening

- Invoke `/patent-kit:screening`

## Quality Gates

- [ ] **Ambiguity Check**: Did you check for and handle ambiguous keywords/abbreviations?
- [ ] **Over-Filtering Check**: If count < 200, did you confirm with the user?
- [ ] **Volume Control**: Is the final General Search count under 2000?
- [ ] **Output**: Is `targeting.md` created with both query patterns and the validation log?
- [ ] **Keywords Registry**: Is `keywords.md` created with golden keywords?

## State Management

### Initial State

- `specification.md` exists
- No `targeting.md` or `keywords.md`

### Final State

- `targeting.md` created with validated search commands
- `keywords.md` created with golden keywords registry
- CSV downloaded from Google Patents and imported into `patents.db`
- Ready to proceed to screening skill
