# Targeting - Detailed Instructions

## Template Adherence

- **Requirement**: Strict adherence to the output templates is required.
- **Templates**: Located in `assets/` directory.
  - `targeting-template.md` - Use for `targeting.md`
  - `keywords-template.md` - Use for `keywords.md`

## CRITICAL: Skill-Only MCP Access

**You MUST NOT call MCP tools (`search_patents`, `fetch_patent`, `execute_cypher`) directly.**

All patent operations MUST go through the Skill tool:

- Patent search → `google-patent-cli:patent-search` (via Skill tool)
- Patent fetch → `google-patent-cli:patent-fetch` (via Skill tool)
- Assignee check → `google-patent-cli:patent-assignee-check` (via Skill tool)

The Skill tool handles MCP tool invocation and cypher queries internally. Do NOT bypass the skill layer.

## Search Scope

Target patent research MUST be scoped to the **Target Market** specified in `specification.md`.

- **Rule**: Use the country code from the Target Market field (e.g., `US`, `JP`, `EP`, `CN`).
- **Mechanism**: If the target market uses a non-English language, use machine translation for keyword queries.

## Overview

Generate high-precision search queries based on the product concept and competitors defined in concept-interviewing. This concludes with a set of validated search commands.

## Input

- **Specification**: `specification.md` (generated in concept-interviewing skill).
- **Skills**: `google-patent-cli` (patent-search) from marketplace.

## Process

### Targeting Process

Perform the following targeting process relative to the `Priority Date Cutoff` from `specification.md`.

**IMPORTANT**: For prior art searches, use the **Priority Date** as the cutoff. Patents published before the Priority Date are considered prior art.

**IMPORTANT**: This step should be conducted **interactively with the user**. Show results, ask for feedback, and refine the queries together.

#### Noise Definition

A search result is considered **"High Noise"** if **8 or more** of the top 20 snippets fall into any of the following categories:

- **Different Field**: Clearly different technical field (e.g., Communication vs Medical).
- **Generic**: Keywords are too general and lack technical specificity.
- **Irrelevant**: Unrelated to the competitor's known products or the target use case.

#### Phase 1: Competitor Patent Research

1. **Start Broad**:
   - **Action**: Use the **Skill tool** to load `google-patent-cli:patent-search`
   - **Request format**:
     ```
     patent_search({
       assignee: ["<Combined Assignees>"],
       country: "<Country from Target Market in specification.md>",
       filing_before: "<Target Release Date>",
       filing_after: "<Priority Date Cutoff>",
       limit: 20
     })
     ```
   - **CRITICAL: Check skill response**:
     - Verify the skill completed successfully and returned results
     - **If skill fails**: Refer to `references/troubleshooting.md` for error handling
     - Do NOT proceed with fabricated search results

2. **Check Volume**:
   - If total count is **under 2000**: This is a good starting point. Check the top 20 snippets to understand what kind of patents they are filing.
   - If total count is **over 2000**: You need to narrow it down.
3. **Iterative Narrowing & Keyword Extraction**:
   - **Action**: Add a keyword representing the "Product Concept" to the query parameter.
   - **CRITICAL RULE 1**: **Always use quotes** for keywords (e.g., `"smartphone"` instead of `smartphone`) to ensure exact matching and proper AND logic. Unquoted terms might be treated as broad OR searches by the search engine.
   - **CRITICAL RULE 2**: **Mandatory Noise Analysis**. After _every_ search command, you MUST inspect the top 20 snippets.
     - **Check**: Does it meet the **High Noise** criteria (8+ irrelevant results)?
     - **Refine**: If **High Noise**, you MUST adjust the query (add exclusions or specific constraints) BEFORE proceeding to the next keyword.
     - **Identify**: Look for **Technical Terms** ("Golden Keywords").
     - **Register**: Immediately add verified keywords to `keywords.md` (see Output section for format).
   - **CRITICAL RULE 3**: **Over-Filtering Check**. If adding a keyword reduces the count to **under 200**, this might be too narrow. **Ask the user** if this is acceptable (e.g., for niche markets) or if they want to broaden the query.
   - **Repeat**: Continue adding quoted keywords (e.g., query: "\"keyword1\" AND \"keyword2\"") until the count is reasonable (< 2000) and relevance is high.

#### Phase 2: Market Patent Research

1. **Apply Keywords**:
   - Use the "Golden Keywords" discovered in Phase 1 (refer to `keywords.md`).
   - **Action**: Use the **Skill tool** to load `google-patent-cli:patent-search`
   - **Request format**:
     ```
     patent_search({
       query: "\"keyword1\" AND \"keyword2\" AND ...",
       country: "<Country from Target Market in specification.md>",
       filing_before: "<Target Release Date>",
       filing_after: "<Priority Date Cutoff>",
       limit: 20
     })
     ```
   - **CRITICAL: Check skill response**:
     - Verify the skill completed successfully and returned results
     - **If skill fails**: Refer to `references/troubleshooting.md` for error handling
     - Do NOT proceed with fabricated search results

2. **Iterative Narrowing**:
   - Similar to Phase 1, if the count is > 2000, add more specific concept keywords (always quoted).
   - **Mandatory Noise Analysis**:
     - After _every_ search, check the snippets against the **High Noise** criteria (8+ irrelevant results).
     - **Analyze**: Identify why irrelevant patents are appearing. Is it a polysemy issue?
     - **Correct**: Add context keywords (e.g., `AND "vehicle"`) or exclusions immediately. Do not blindly add more keywords without fixing the noise.
   - **Goal**: Reach < 2000 hits with high relevance.
   - **Over-Filtering**: If count < 200, **confirm with the user** before proceeding.

## Google Patents UI Query Formatting

When formatting queries for direct use in [Google Patents](https://patents.google.com/):

1. **Order**: Keywords MUST be placed **at the beginning** of the query string.
2. **Keywords**: MUST be quoted (e.g., `"smartphone"`).
3. **Assignees**: MUST be quoted and space-separated keys (e.g., `assignee:"Google LLC" assignee:"Microsoft Corp"`).
4. **Country/Language**: If a country is specified, the language MUST also be specified (e.g., `country:JP language:JAPANESE`, `country:CN language:CHINESE`).

## Output

- Create a file `targeting.md` using the template `[targeting-template.md](assets/targeting-template.md)`.
- Fill in the **Generated Search Commands** with:
  - **Query**: The final command.
  - **Hit Count**: Number of hits.
  - **Included Keywords**: List of positive keywords.
  - **Excluded Noise**: List of negative keywords/constraints.
  - **Rationale**: Explanation of why this query is optimal (balance of precision/recall).
- Fill in the **Validation & Adjustment Log** with:
  - **Initial Results**: Count before adjustment.
  - **Noise Cause**: Polysemy, Generic, Domain, etc. (Why was it noise?)
  - **Adjustment**: What keywords/exclusions were added.
  - **Result Count**: Count after adjustment.
- Create a file `keywords.md` using the template `[keywords-template.md](assets/keywords-template.md)`. This is the **Golden Keywords Registry**.

## Quality Gates

- [ ] **Ambiguity Check**: Did you check for and handle ambiguous keywords/abbreviations?
- [ ] **Over-Filtering Check**: If count < 200, did you confirm with the user that this is intended?
- [ ] **Volume Control**: Is the final General Search count under 2000 (or reasonably low)?
- [ ] **Output**: Is `targeting.md` created with both query patterns and the validation log?
- [ ] **Keywords Registry**: Is `keywords.md` created with golden keywords?

## Deliverables

1. `targeting.md`
2. `keywords.md`
