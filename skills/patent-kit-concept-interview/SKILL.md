---
name: patent-kit-concept-interview
description: "Phase 0: Concept Interview"
---

# Phase 0: Concept Interview

Your task is to define the product concept and identify competitors. This phase establishes the foundation for patent targeting.

## Instructions

### Input

- **User Input**: Product Concept, Competitors.

### Process

1. **Read Constitution**: Read `.patent-kit/memory/constitution.md` to understand the core principles.

#### Step 1: Concept Interview

1. **Ask**: Request the following information from the user:
   - **Product Concept**: Detailed description of what they want to realize.
   - **Target Country**: Where the product will be released (e.g., US, JP).
   - **Target Release Date**: Approximate date.
   - **Cutoff Date**: Calculate `Target Release Date - 20 years`. Patents filed before this date are likely expired.
   - **Competitors**: List of key competitor companies (Mandatory).

   > [!IMPORTANT]
   > If `0-specifications/specification.md` already exists, **skip the interview** and use the information from that file as the source of truth describing the concept.

2. **Refine**: If the concept is too vague, ask clarifying questions to break it down into technical elements relevant for patent search.

3. **Save**: Write the gathered information to `0-specifications/specification.md` using the template `[specification-template.md](templates/specification-template.md)`.

#### Step 2: Assignee Identification

1. **Verify**: For each competitor named by the user, verify the correct "Assignee Name" used in patent databases.
   - **Action**: Run a search (e.g., `google-patent-cli search --assignee "<Company Name>"`) **without** `--limit`.
   - **Check `top_assignees`**: The output will include `top_assignees`. Look for **name variations** (表記揺れ) for the same company (e.g., "Google LLC", "Google Inc.", "GOOGLE LLC").
   - **Confirm**: Display the top assignees found and ask the user if they represent the intended competitor.
   - **Refine**: If incorrect or no hits, try variations (e.g., "Google LLC" instead of "Google").

2. **Finalize**:
   - Fill the **Verified Assignee Names (Canonicalized)** table in `0-specifications/specification.md`.
   - Record **all** identified official Assignee Names, **including all name variations** found in `top_assignees`. These variations must be included in the final search query.
   - Record the verification status and any notes (e.g., holding company, subsidiary).

### Output

- `0-specifications/specification.md`: The product specification with verified assignee names.

### Quality Gates

- [ ] Product concept is clearly defined.
- [ ] Target country and release date are specified.
- [ ] All competitors' assignee names are verified in the database.
- [ ] Specification file is saved with complete information.

Run /patent-kit:targeting
