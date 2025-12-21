---
description: "Phase 1: Screening"
---

# Phase 1: Screening

Your task is to Execute the Screening Phase.

## Input

- No file input initially. Start with User Interview.

## Process

1.  **Initialize**: Read `.patent-kit/memory/constitution.md`.

2.  **Step 1: Concept Interview**:
    - **Ask**: Request the following information from the user:
        - **Product Concept**: Detailed description of what they want to realize.
        - **Target Country**: Where the product will be released (e.g., US, JP).
        - **Target Release Date**: Approximate date (to determine prior art cutoff).
        - **Competitors**: List of key competitor companies (Mandatory).
    - **Refine**: If the concept is too vague, ask clarifying questions to break it down.

3.  **Step 2: Assignee Identification**:
    - **Verify**: For each competitor, run `google-patent-cli search --assignee "<Company Name>" --limit 1` to check for hits.
    - **Confirm**:
        - Show the **Title** and **Abstract** of the found patent.
        - Ask the user: "Is this the correct competitor?"
    - **Refine**: If incorrect or no hits, try variations (e.g., "Google LLC").

4.  **Step 3: Search Strategy & Pre-Search**:
    - **Keywords**: Extract Broad Terms and Narrow Terms **in the language of the Target Country** (e.g., Japanese for JP, English for US).
    - **Query Generation**:
        - **Strategy A: Competitor Watch (Broad)**:
            - Command: `google-patent-cli search --query "<Broad Term>" --assignee "<Competitor>" --country "<Target Country>"`
        - **Strategy B: General Search (Narrow)**:
            - Command: `google-patent-cli search --query "<Broad Term> AND <Narrow Term>" --country "<Target Country>"`
    - **Pre-Search**: Run commands to get result **counts** (using `--limit 1`).
    - **Report (Intermediate)**:
        - Create `prescreening.md` using `.patent-kit/templates/prescreening-template.md`.
        - Save to: `screening/prescreening.md`.
    - **STOP** and ask user for confirmation to proceed.

5.  **Step 4: Executive Screening**:
    - **Execute**: Upon user approval, run selected searches to fetch patent details.
        - **Save**: Save JSON output to `screening/json/search_results_<strategy>.json`.
    - **Evaluate**: Compare against Product Concept.
        - **Risk Level**: High/Medium/Low.
    - **Output**:
        - Create `screening.md` using `.patent-kit/templates/screening-template.md`.
        - Save to: `screening/screening.md`.
        - **Recommendation**: "Proceed to Phase 2 Evaluation for [Patent ID]."

## Quality Gates

- [ ] **Assignee Verification**: Did you confirm the exact assignee names exist in the DB?
- [ ] **Pre-Screening Report**: Is `prescreening.md` created with query counts?
- [ ] **Risk Assessment**: Are High/Medium risk patents clearly identified with reasons?
