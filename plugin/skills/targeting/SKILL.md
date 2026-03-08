---
name: targeting
description: |
  Searches patent databases to create a target population based on specifications.

  Triggered when:
  - The user asks to:
    * "create a target population"
    * "determine the target population"
    * "run the patent search"
  - CSV files are detected in 1-targeting/csv/
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 1: Targeting

## Purpose

Generate high-precision search queries and create a consolidated patent population for screening.

## Prerequisites

- `0-specifications/specification.md` must exist (generated in Phase 0)

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Search Query Optimization**:

- Start with broad, essential keywords (2-4 terms maximum)
- If zero results, progressively simplify:
  1. Remove technical modifiers and adjectives
  2. Break compound concepts into separate searches
  3. Try synonyms or broader terms
- Document query evolution in reports

## Skill Orchestration

### 2. Check Specification

Use the Glob tool to check if `0-specifications/specification.md` exists:

- **If exists**: Proceed to targeting execution
- **If NOT exists**:
  1. Use the Skill tool to load the `concept-interviewing` skill to create the specification
  2. Wait for the concept-interviewing to complete
  3. Verify that `0-specifications/specification.md` has been created
  4. Only proceed after the specification file exists

### 3. Execute Targeting

**IMPORTANT: First, check if CSV files already exist:**

Use the Glob tool to check if `1-targeting/csv/*.csv` files exist:

- **If CSV files exist**:
  1. **Do NOT** ask the user what to do. **Immediately proceed to database import.**
  2. **Skip** the patent search and keyword extraction steps (Step 1 & 2 from instructions)
  3. **Initialize database and import CSV files**:
     - Use the Skill tool to load the `investigating-database` skill
     - Request: "Initialize the patent database and import CSV files from 1-targeting/csv/"
     - This will:
       - Create `patents.db` if it doesn't exist
       - Import all CSV files into the `target_patents` table
  4. Verify import completed successfully by checking the database statistics
  5. **Do NOT** create targeting.md or keywords.md when CSV files are pre-downloaded
  6. Report completion: "Imported X patents from CSV files into the patent database"

- **If NO CSV files**:
  1. **Execute Competitor Patent Research**:
     - Use `google-patent-cli:patent-search` with assignee search
     - Analyze results and extract "Golden Keywords"
     - Save keywords to `1-targeting/keywords.md`
  2. **Execute Market Patent Research**:
     - Use `google-patent-cli:patent-search` with keyword queries
     - Refine queries based on noise analysis
  3. **Create Output Files**:
     - Fill `1-targeting/targeting.md` using the template
     - Update `1-targeting/keywords.md` with golden keywords registry

### 4. Transition to Screening

Upon successful completion:

- Deliverables: `1-targeting/targeting.md`, `1-targeting/keywords.md` (if not from CSV), `patents.db`
- Next skill: `/patent-kit:screening`

## State Management

### Initial State

- `0-specifications/specification.md` exists
- No `1-targeting/` directory (or empty)

### Final State

- `1-targeting/targeting.md` created with validated search commands (if not from CSV)
- `1-targeting/keywords.md` created with golden keywords registry (if not from CSV)
- `patents.db` created with patents imported into `target_patents` table
- Ready to proceed to screening phase

## References

- `references/instructions.md` - Detailed targeting process instructions
- `references/examples.md` - Usage examples
- `references/troubleshooting.md` - Common issues and solutions
- `assets/templates/targeting-template.md` - Output template for targeting results
- `assets/templates/keywords-template.md` - Output template for keywords registry
