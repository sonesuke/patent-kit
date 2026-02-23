# Concept Interview - Detailed Instructions

## Template Adherence

- **Requirement**: Strict adherence to the output template is required.
- **Template**: `assets/templates/specification-template.md` - Use for `0-specifications/specification.md`

## Overview

Define the product concept and identify competitors. This phase establishes the foundation for patent targeting.

## Input

- **User Input**: Product Concept, Competitors.

## Process

### Step 1: Load Constitution (MANDATORY)

Use the Skill tool to load the `constitution` skill BEFORE starting any work. This is required to understand the core principles.

### Step 2: Concept Interview

1. **Check Existing Specification**: Use the Glob tool to check if `0-specifications/specification.md` exists.

   **If exists**: Skip the interview and use the information from that file as the source of truth.

   **If NOT exists**: Proceed with the interview.

2. **Ask**: Request the following information from the user:
   - **Product Concept**: Detailed description of what they want to realize.
   - **Target Country**: Where the product will be released (e.g., US, JP).
   - **Target Release Date**: Approximate date.
   - **Cutoff Date**: Calculate `Target Release Date - 20 years`. Patents filed before this date are likely expired.
   - **Competitors**: List of key competitor companies (Mandatory).

   > [!NOTE]
   > If the user has provided sufficient information (product concept, target country, release date, competitors), proceed directly to assignee verification without asking additional clarifying questions.

3. **Refine**: If the concept is too vague, ask clarifying questions to break it down into technical elements relevant for patent search.

4. **Save**: Write the gathered information to `0-specifications/specification.md` using the template `assets/specification-template.md`.

### Step 3: Assignee Identification

1. **Verify**: For each competitor named by the user, verify the correct "Assignee Name" used in patent databases.
   - **Action**: Run a search (e.g., Use the MCP tool `search_patents` (Arguments: --assignee "<Company Name>")) **without** `--limit`.
   - **CRITICAL: Check MCP response**:
     - Verify the response does NOT contain `isError: true`
     - **If MCP tool fails**: Refer to `references/troubleshooting.md` for "MCP Server Errors" section
     - Do NOT proceed with fabricated or assumed assignee names
   - **Check `top_assignees`**: The output will include `top_assignees`. Look for **name variations** (表記揺れ) for the same company (e.g., "Google LLC", "Google Inc.", "GOOGLE LLC").
   - **Confirm**: Display the top assignees found and ask the user if they represent the intended competitor.
   - **Refine**: If incorrect or no hits, try variations (e.g., "Google LLC" instead of "Google").

2. **Finalize**:
   - Fill the **Verified Assignee Names (Canonicalized)** table in `0-specifications/specification.md`.
   - Record **all** identified official Assignee Names, **including all name variations** found in `top_assignees`. These variations must be included in the final search query.
   - Record the verification status and any notes (e.g., holding company, subsidiary).

## Output

- `0-specifications/specification.md`: The product specification with verified assignee names.

## Quality Gates

- [ ] Product concept is clearly defined.
- [ ] Target country and release date are specified.
- [ ] All competitors' assignee names are verified in the database.
- [ ] Specification file is saved with complete information.
