# Specific Patent Report Instructions

## Purpose

Generate a detailed report for a single specified patent.

## Process

### Step 1: Extract Patent ID

Parse user request to extract patent ID:

- "Tell me about US20240292070A1" → Extract: `US20240292070A1`
- "Report on patent US9876543B2" → Extract: `US9876543B2`

### Step 2: Get Patent Data from Database

**CRITICAL: Use `investigation-fetching` skill for all data retrieval.**
Do NOT parse files from investigation directories.

1. **Patent basic info**:
   ```
   Skill: investigation-fetching
   Request: "Execute SQL: SELECT * FROM target_patents WHERE patent_id='<patent_id>'"
   ```
   Also join with `screened_patents` for screening judgment and reason.

2. **Claims and elements**:
   ```
   Skill: investigation-fetching
   Request: "Get elements for patent <patent_id>"
   ```

3. **Similarities**:
   ```
   Skill: investigation-fetching
   Request: "Execute SQL: SELECT * FROM similarities WHERE patent_id='<patent_id>'"
   ```

4. **Prior art** (if exists):
   ```
   Skill: investigation-fetching
   Request: "Execute SQL: SELECT * FROM prior_art_elements WHERE patent_id='<patent_id>'"
   ```

### Step 3: Format Report

Build the report using the template from
`assets/specific-patent-report-template.md`.

**Element-by-Element Table** (from `similarities` query):

| Element | Target Specification | Patent Disclosure | Similarity |
|---------|---------------------|-------------------|------------|
| A. [element name] | [target spec] | [patent disclosure] | [Similarity Level] |
| B. [element name] | [target spec] | [patent disclosure] | [Similarity Level] |

**Prior Art Section** (from `prior_art_elements` query, if data exists):

- List prior art references found
- Relevance level for each element

### Step 4: Output Report

**CRITICAL: Use the Write tool to create the report file.**

1. Read template from `assets/specific-patent-report-template.md`
2. Fill in patent-specific information from database queries
3. Write to `<patent_id>.md` using Write tool
4. Run legal-checking on the generated report:
   ```
   Skill: legal-checking
   Request: "<patent_id>.md"
   ```

## Quality Checks

- [ ] Patent ID correctly extracted
- [ ] All data retrieved from database via investigation-fetching skill
- [ ] Element table includes all elements from similarities query
- [ ] NO legal assertions (infringement, validity conclusions)
- [ ] Write tool used to create `<patent_id>.md`
- [ ] Legal-checking skill invoked on the generated report
