---
description: "Phase 1: Screening"
---

# Phase 1: Screening

Your task is to identify potential patent infringement risks based on the user's product concept and competitor analysis. This is a preliminary screening to determine which patents require detailed evaluation (Phase 2).

## Input

- **User Input**: Product Concept, Competitors.
- **Tools**: `google-patent-cli` (assume updated version with assignee search capability or standard keyword search if not available yet).

## Process

### Step 1: Concept Interview

1.  **Ask**: Request the following information from the user:
    - **Product Concept**: Detailed description of what they want to realize.
    - **Target Country**: Where the product will be released (e.g., US, JP).
    - **Target Release Date**: Approximate date.
    - **Cutoff Date**: Calculate `Target Release Date - 20 years`. Patents filed before this date are likely expired.
    - **Competitors**: List of key competitor companies (Mandatory).
2.  **Refine**: If the concept is too vague, ask clarifying questions to break it down into technical elements relevant for patent search.

### Step 2: Assignee Identification

1.  **Verify**: For each competitor named by the user, verify the correct "Assignee Name" used in patent databases.
    - **Action**: Run a search (e.g., `google-patent-cli search --assignee "<Company Name>" --limit 1`) to check if it hits.
    - **Confirm**: Display the **Title** and **Abstract** of the first result and ask the user if it represents the intended competitor.
    - **Refine**: If strictly incorrect or no hits, try variations (e.g., "Google LLC" instead of "Google").
2.  **Finalize**: List the identified official Assignee Names.

### Step 3: Search Strategy & Pre-Search

1.  **Keywords**:
    - **Broad Terms**: Core technical concepts (high recall). **Must be in the language of the Target Country** (e.g., Japanese for JP).
    - **Narrow Terms**: Specific features, configurations, or unique combinations (high precision). **Must be in the language of the Target Country**.
    - **Ambiguity Check**:
        - Check if keywords (especially abbreviations) have multiple meanings (polysemy).
        - **Action**: If ambiguous, replace with **Full Term** OR add a **Domain Keyword** (AND constraint) to exclude irrelevant contexts.
2.  **Query Generation**: Create differentiating query strategies using CLI flags:
    - **Strategy A: Competitor Watch (Broad)**:
        - Command: `google-patent-cli search --query "<Broad Term>" --assignee "<Competitor>" --country "<Target Country>" --after "<Cutoff Date>"`
        - Goal: Catch ALL relevant patents from competitors in the target market.
    - **Strategy B: General Search (Narrow)**:
        - Command: `google-patent-cli search --query "<Broad Term> AND <Narrow Term>" --country "<Target Country>" --after "<Cutoff Date>"`
        - Goal: Find only highly relevant patents from the rest of the world (avoiding noise).
3.  **Pre-Search execution**:
    - Run the generated commands to get the **count** of results (using `--limit 1` and checking total results if possible).
4.  **Report (Intermediate)**:
    - Create a file `screening/prescreening.md` using the template `.patent-kit/templates/prescreening-template.md`.
    - Fill in:
        - **Target Competitors** (Verified Assignee Names)
        - **Search Commands** used (showing flags).
        - **Hit Counts** (approximate).
        - **Proposed Screening Scope**: Recommendation on which queries/list to proceed with for detailed screening.

### Step 4: Executive Screening

1.  **Execute**: Run the selected search queries to fetch patent details (Title, Abstract, Claims).
    - **Requirement**: Save JSON output to `screening/json/search_results_<strategy>.json`.
2.  **Evaluate**: Compare each patent against the Product Concept.
    - **Criteria**:
        - Does the patent cover the technical field?
        - Do the claims seemingly cover the core features of the concept?
    - **Risk Level**:
        - **High**: Direct conflict likely.
        - **Medium**: Potential conflict, needs detailed check.
        - **Low**: Different approach or irrelevant.
3.  **Output**:
    - Create a final report `screening/screening.md` using the template `.patent-kit/templates/screening-template.md`.
    - List "High" and "Medium" risk patents.
    - Format:
        - **Patent ID**: link
        - **Title**: ...
        - **Assignee**: ...
        - **Risk**: High/Medium
        - **Concern**: Brief explanation of why it's a risk.
    - **Recommendation**: "Proceed to Phase 2 Evaluation for [Patent ID]."

## Deliverables

1.  `prescreening.md` (Intermediate)
2.  `screening.md` (Final)
