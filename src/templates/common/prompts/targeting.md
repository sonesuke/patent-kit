---
description: "Phase 1: Targeting"
---

# Phase 1: Targeting

Your task is to define the product concept, identify competitors, and generate high-precision search queries. This phase concludes with a set of validated search commands to be used for screening.

## Input

- **User Input**: Product Concept, Competitors.
- **Tools**: `google-patent-cli` (assume updated version with assignee search capability).

## Process

### Step 1: Concept Interview

1. **Initialize**: Read `.patent-kit/memory/constitution.md` to understand the core principles.
2. **Ask**: Request the following information from the user:
   - **Product Concept**: Detailed description of what they want to realize.
   - **Target Country**: Where the product will be released (e.g., US, JP).
   - **Target Release Date**: Approximate date.
   - **Cutoff Date**: Calculate `Target Release Date - 20 years`. Patents filed before this date are likely expired.
   - **Competitors**: List of key competitor companies (Mandatory).

   > [!IMPORTANT]
   > If `1-specifications/specification.md` already exists, **skip the interview** and use the information from that file as the source of truth describing the concept.

3. **Refine**: If the concept is too vague, ask clarifying questions to break it down into technical elements relevant for patent search.

4. **Save**: Write the gathered information to `1-specifications/specification.md` using the template `.patent-kit/templates/specification-template.md`.

### Step 2: Assignee Identification

1. **Verify**: For each competitor named by the user, verify the correct "Assignee Name" used in patent databases.
   - **Action**: Run a search (e.g., `google-patent-cli search --assignee "<Company Name>"`) **without** `--limit`.
   - **Check `top_assignees`**: The output will include `top_assignees`. Look for **name variations** (表記揺れ) for the same company (e.g., "Google LLC", "Google Inc.", "GOOGLE LLC").
   - **Confirm**: Display the top assignees found and ask the user if they represent the intended competitor.
   - **Refine**: If incorrect or no hits, try variations (e.g., "Google LLC" instead of "Google").

2. **Finalize**:
   - Fill the **Verified Assignee Names (Canonicalized)** table in `2-targeting/targeting.md`.
   - Record **all** identified official Assignee Names, **including all name variations** found in `top_assignees`. These variations must be included in the final search query.
   - Record the verification status and any notes (e.g., holding company, subsidiary).

### Step 3: Targeting Process

Perform the following targeting process relative to the `Target Release Date` and `Cutoff Date`.

**IMPORTANT**: This step should be conducted **interactively with the user**. Show results, ask for feedback, and refine the queries together.

#### Noise Definition

A search result is considered **"High Noise"** if **8 or more** of the top 20 snippets fall into any of the following categories:

- **Different Field**: Clearly different technical field (e.g., Communication vs Medical).
- **Generic**: Keywords are too general and lack technical specificity.
- **Irrelevant**: Unrelated to the competitor's known products or the target use case.

#### Phase 3.1: Competitor Patent Research

1. **Start Broad**:
   - Command: `google-patent-cli search --assignee "<Combined Assignees>" --country "<Target Country>" --before "<Target Release Date>" --after "<Cutoff Date>" --limit 20`
2. **Check Volume**:
   - If total count is **under 1000**: This is a good starting point. Check the top 20 snippets to understand what kind of patents they are filing.
   - If total count is **over 1000**: You need to narrow it down.
3. **Iterative Narrowing & Keyword Extraction**:
   - **Action**: Add a keyword representing the "Product Concept" to the `--query`.
   - **CRITICAL RULE 1**: **Always use quotes** for keywords (e.g., `"smartphone"` instead of `smartphone`) to ensure exact matching and proper AND logic. Unquoted terms might be treated as broad OR searches by the search engine.
   - **CRITICAL RULE 2**: **Mandatory Noise Analysis**. After *every* search command, you MUST inspect the top 20 snippets.
     - **Check**: Does it meet the **High Noise** criteria (8+ irrelevant results)?
     - **Refine**: If **High Noise**, you MUST adjust the query (add exclusions or specific constraints) BEFORE proceeding to the next keyword.
     - **Identify**: Look for **Technical Terms** ("Golden Keywords").
     - **Register**: Immediately add verified keywords to `2-targeting/keywords.md` (see Output section for format).
   - **CRITICAL RULE 3**: **Over-Filtering Check**. If adding a keyword reduces the count to **under 200**, this might be too narrow. **Ask the user** if this is acceptable (e.g., for niche markets) or if they want to broaden the query.
   - **Repeat**: Continue adding quoted keywords (e.g., `--query "\"keyword1\" AND \"keyword2\""`) until the count is reasonable (< 1000) and relevance is high.

#### Phase 3.2: Market Patent Research

1. **Apply Keywords**:
   - Use the "Golden Keywords" discovered in Phase 3.1 (refer to `2-targeting/keywords.md`).
   - Command: `google-patent-cli search --query "\"keyword1\" AND \"keyword2\"" ...` (Wrap details below to avoid length issues)
   - Real Command: `google-patent-cli search --query "\"keyword1\" AND \"keyword2\"" --country "<Target Country>" --before "<Target Release Date>" --after "<Cutoff Date>" --limit 20`
2. **Iterative Narrowing**:
   - Similar to Phase 3.1, if the count is > 1000, add more specific concept keywords (always quoted).
   - **Mandatory Noise Analysis**:
     - After *every* search, check the snippets against the **High Noise** criteria (8+ irrelevant results).
     - **Analyze**: Identify why irrelevant patents are appearing. Is it a polysemy issue?
     - **Correct**: Add context keywords (e.g., `AND "vehicle"`) or exclusions immediately. Do not blindly add more keywords without fixing the noise.
   - **Goal**: Reach < 1000 hits with high relevance.
   - **Over-Filtering**: If count < 200, **confirm with the user** before proceeding.

### Step 4: Final Output Generation

1. **Select Best Queries**: Choose the final query set for "Competitor Patent Research" and "Market Patent Research".
2. **Log Validation**: Record the initial counts, what noise you found, and how adding specific keywords reduced that noise.

## Output

- Create a file `2-targeting/targeting.md` using the template `.patent-kit/templates/targeting-template.md`.
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
- Create a file `2-targeting/keywords.md` using the template `.patent-kit/templates/keywords-template.md`. This is the **Golden Keywords Registry**.

## Quality Gates

- [ ] **Assignee Verification**: Did you confirm the exact assignee names exist in the DB?
- [ ] **Ambiguity Check**: Did you check for and handle ambiguous keywords/abbreviations?
- [ ] **Over-Filtering Check**: If count < 200, did you confirm with the user that this is intended?
- [ ] **Volume Control**: Is the final General Search count under 1000 (or reasonably low)?
- [ ] **Output**: Is `targeting.md` created with both query patterns and the validation log?

## Deliverables

1. `targeting.md`
2. `targeting/keywords.md`

{{ NEXT_STEP_INSTRUCTION }}
