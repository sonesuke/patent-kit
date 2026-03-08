# Concept Interview - Detailed Instructions

## Template Adherence

- **Requirement**: Strict adherence to the output template is required.
- **Template**: `assets/templates/specification-template.md` - Use for `specification.md`

## Overview

Define the product concept and identify competitors. This establishes the foundation for patent targeting.

## Input

- **User Input**: Product Concept, Competitors.

## Process

### Step 1: Load Constitution (MANDATORY)

Use the Skill tool to load the `constitution` skill BEFORE starting any work. This is required to understand the core principles.

### Step 2: Concept Interview

1. **Check Existing Specification**: Use the Glob tool to check if `specification.md` exists.

   **If exists**:
   - Read the existing specification
   - Check if "Verified Assignee Names" table contains proper assignee name variations:
     - **If assignee names are listed** with variations (e.g., "Google LLC, Google Inc."): Assignee verification already complete - skip to confirmation
     - **If assignee names are missing** or incomplete: Perform assignee verification using `google-patent-cli:patent-assignee-check`

   **If NOT exists**: Proceed to information gathering below.

2. **Extract Information**: Analyze the user's input to extract the following information:

   **Required Information**:
   - **Product Concept**: Detailed description of what they want to realize.
   - **Competitors**: List of key competitor companies (Mandatory).
   - **Target Country**: Where the product will be released (e.g., US, JP).
   - **Target Release Date**: Approximate date.
   - **Cutoff Date**: Calculate `Target Release Date - 20 years`. Patents filed before this date are likely expired.

   **Extraction Logic**:
   - If the user provides a country (e.g., "in the US", "US market"), extract and use that
   - If the user provides a release date (e.g., "2025", "June 2025"), extract and use that
   - Extract competitors from mentions of company names (e.g., "Competitors are Google and Amazon")

   - **If any required information is missing** (product concept, country, release date, or competitors):
     - Ask the user to provide the missing information
     - Do not make assumptions or use default values

   > [!NOTE]
   > In automated test environments, ensure all required information is provided in the initial request to avoid interactive prompts.

3. **Proceed to Assignee Verification**: Once all required information is collected, proceed directly to Step 3 to verify assignee names.

### Step 3: Assignee Identification

1. **Verify**: For each competitor named by the user, verify the correct "Assignee Name" used in patent databases.
   - **Action**: Use the Skill tool to invoke `google-patent-cli:patent-assignee-check` with:
     - company_name: "<Company Name>"
     - country: "<Target Country from Step 2>"
     - Note: Omit the limit parameter to get all assignee variations (default: 100)
   - **CRITICAL: Check skill response**:
     - Verify the response does NOT contain errors
     - **If skill fails**: Refer to `references/troubleshooting.md` for error handling
     - Do NOT proceed with fabricated or assumed assignee names
   - **Extract and Analyze**: The skill returns assignee name variations with frequency information.
     - The skill automatically provides a frequency histogram of assignee names
   - **Confirm**: Display the top assignee variations found and ask the user if they represent the intended competitor.
   - **Refine**: If incorrect or no hits, try variations (e.g., "Google LLC" instead of "Google").

2. **Finalize**:
   - Fill the **Verified Assignee Names (Canonicalized)** table in `specification.md`.
   - Record **all** identified official Assignee Names, **including all name variations** found in the skill results. These variations must be included in the final search query.
   - Record the verification status and any notes (e.g., holding company, subsidiary).

## Output

- `specification.md`: The product specification with verified assignee names.

## Quality Gates

- [ ] Product concept is clearly defined.
- [ ] Target country and release date are specified.
- [ ] All competitors' assignee names are verified in the database.
- [ ] Specification file is saved with complete information.
