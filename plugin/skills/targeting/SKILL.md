---
name: targeting
description: "Searches patent databases to create a target population based on specifications. Triggered when the user asks to 'create a target population' or 'run the search (Step 1)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 1: Targeting

Your task is to generate high-precision search queries based on the product concept and competitors defined in Phase 0. This phase concludes with a set of validated search commands and merged patent data for screening.

## Instructions

### Input

- **Specification**: `0-specifications/specification.md` (generated in Phase 0).
- **Tools**: `MCP tool` (assume updated version with assignee search capability).

### Process

1. **Read Constitution**: Load the `constitution` skill to understand the core principles.

#### Step 1: Targeting Process

Perform the following targeting process relative to the `Target Release Date` and `Cutoff Date` from `0-specifications/specification.md`.

**IMPORTANT**: This step should be conducted **interactively with the user**. Show results, ask for feedback, and refine the queries together.

##### Noise Definition

A search result is considered **"High Noise"** if **8 or more** of the top 20 snippets fall into any of the following categories:

- **Different Field**: Clearly different technical field (e.g., Communication vs Medical).
- **Generic**: Keywords are too general and lack technical specificity.
- **Irrelevant**: Unrelated to the competitor's known products or the target use case.

##### Phase 1.1: Competitor Patent Research

1. **Start Broad**:
   - Command: Use the MCP tool `search_patents` (Arguments: --assignee "<Combined Assignees>" --country "<Target Country>" --before "<Target Release Date>" --after "<Cutoff Date>" --limit 20)
2. **Check Volume**:
   - If total count is **under 1000**: This is a good starting point. Check the top 20 snippets to understand what kind of patents they are filing.
   - If total count is **over 1000**: You need to narrow it down.
3. **Iterative Narrowing & Keyword Extraction**:
   - **Action**: Add a keyword representing the "Product Concept" to the `--query`.
   - **CRITICAL RULE 1**: **Always use quotes** for keywords (e.g., `"smartphone"` instead of `smartphone`) to ensure exact matching and proper AND logic. Unquoted terms might be treated as broad OR searches by the search engine.
   - **CRITICAL RULE 2**: **Mandatory Noise Analysis**. After _every_ search command, you MUST inspect the top 20 snippets.
     - **Check**: Does it meet the **High Noise** criteria (8+ irrelevant results)?
     - **Refine**: If **High Noise**, you MUST adjust the query (add exclusions or specific constraints) BEFORE proceeding to the next keyword.
     - **Identify**: Look for **Technical Terms** ("Golden Keywords").
     - **Register**: Immediately add verified keywords to `1-targeting/keywords.md` (see Output section for format).
   - **CRITICAL RULE 3**: **Over-Filtering Check**. If adding a keyword reduces the count to **under 200**, this might be too narrow. **Ask the user** if this is acceptable (e.g., for niche markets) or if they want to broaden the query.
   - **Repeat**: Continue adding quoted keywords (e.g., `--query "\"keyword1\" AND \"keyword2\""`) until the count is reasonable (< 1000) and relevance is high.

##### Phase 1.2: Market Patent Research

1. **Apply Keywords**:
   - Use the "Golden Keywords" discovered in Phase 1.1 (refer to `1-targeting/keywords.md`).
   - Command: Use the MCP tool `search_patents` (Arguments: --query "\"keyword1\" AND \"keyword2\"" ...) (Wrap details below to avoid length issues)
   - Real Command: Use the MCP tool `search_patents` (Arguments: --query "\"keyword1\" AND \"keyword2\"" --country "<Target Country>" --before "<Target Release Date>" --after "<Cutoff Date>" --limit 20)
2. **Iterative Narrowing**:
   - Similar to Phase 3.1, if the count is > 1000, add more specific concept keywords (always quoted).
   - **Mandatory Noise Analysis**:
     - After _every_ search, check the snippets against the **High Noise** criteria (8+ irrelevant results).
     - **Analyze**: Identify why irrelevant patents are appearing. Is it a polysemy issue?
     - **Correct**: Add context keywords (e.g., `AND "vehicle"`) or exclusions immediately. Do not blindly add more keywords without fixing the noise.
   - **Goal**: Reach < 1000 hits with high relevance.
   - **Over-Filtering**: If count < 200, **confirm with the user** before proceeding.

#### Step 2: Data Acquisition

1. **Instruct User**: Ask the user to perform the following:
   - **Action**: Go to Google Patents (<https://patents.google.com/>).
   - For each query generated in Step 1:
     - Execute the query.
     - Download the results as a CSV file.
   - **Save Location**: Place all downloaded CSV files in `1-targeting/csv/`.

#### Step 3: Merge & Deduplicate

1. **Run Merge Command**:
   - Execute the following command to combine the CSV files and remove duplicates.
   - **Important**: Use `patent-kit` command, NOT `MCP tool`.
   - Command: `patent-kit merge --input-dir 1-targeting/csv --output 1-targeting/target.jsonl`

2. **Verify Output**:
   - Check that `1-targeting/target.jsonl` has been created.
   - This file contains the consolidated list of unique patents to be screened/evaluated.

3. **Check Count**:
   - The `patent-kit merge` command output displays the number of unique patents (e.g., `Merged 150 unique patents...`).
   - Confirm this count to understand the volume of patents to be screened.

### Output

- Create a file `1-targeting/targeting.md` using the template `[targeting-template.md](templates/targeting-template.md)`.
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
- Create a file `1-targeting/keywords.md` using the template `[keywords-template.md](templates/keywords-template.md)`. This is the **Golden Keywords Registry**.
- `1-targeting/target.jsonl`: The merged list of unique patents ready for screening.

### Quality Gates

- [ ] **Ambiguity Check**: Did you check for and handle ambiguous keywords/abbreviations?
- [ ] **Over-Filtering Check**: If count < 200, did you confirm with the user that this is intended?
- [ ] **Volume Control**: Is the final General Search count under 1000 (or reasonably low)?
- [ ] **Output**: Is `targeting.md` created with both query patterns and the validation log?
- [ ] **Data Acquisition**: Are all CSV files downloaded to `1-targeting/csv/`?
- [ ] **Merge**: Is `1-targeting/target.jsonl` created with unique patents?

### Deliverables

1. `1-targeting/targeting.md`
2. `1-targeting/keywords.md`
3. `1-targeting/target.jsonl`

Run /patent-kit:screening

# Examples

Example 1: Forming the Target Population
User says: "The requirements are solid, build the search query and create the target population"
Actions:
1. Extract keywords from specification.md and search using the MCP tool
2. Adjust the query while checking search volume (< 1000) and noise levels
3. Combine the downloaded CSVs into JSONL using the merge command
Result: 1-targeting/target.jsonl is generated, preparing for screening.

# Troubleshooting

Error: "patent-kit command not found"
Cause: Python script path is incorrect or environment is not fully setup.
Solution: Ensure plugin/skills/targeting/scripts/merge.py is executable and Python 3 is installed.
