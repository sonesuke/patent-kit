# Specific Patent Report Instructions

## Purpose

Generate a detailed report for a single specified patent, reflecting the
current investigation progress. Only completed phases are shown with data;
incomplete phases display "Pending".

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
   Request: "Execute SQL: SELECT tp.*, sp.judgment, sp.reason FROM target_patents tp LEFT JOIN screened_patents sp ON tp.patent_id = sp.patent_id WHERE tp.patent_id='<patent_id>'"
   ```

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

### Step 3: Determine Phase Status

Based on the database query results, determine which phases are complete:

| Phase              | Complete When                 | Status         |
| ------------------ | ----------------------------- | -------------- |
| Screening          | `screened_patents` has entry  | Done / Pending |
| Evaluation         | `claims` and `elements` exist | Done / Pending |
| Claim Analysis     | `similarities` exist          | Done / Pending |
| Prior Art Research | `prior_art_elements` exist    | Done / Pending |

### Step 4: Generate Report

Use the template from `assets/specific-patent-report-template.md`.
Fill in sections based on phase status:

#### Sections to Always Include

- **Basic Information**: Patent ID, title, assignee, dates, screening judgment

#### Sections Based on Phase Status

- **Similarity Assessment** (if claim analysis is done):
  - Overall similarity from `similarities` (max of Significant > Moderate > Limited)
  - Per-element similarity breakdown

- **Element Analysis** (if claim analysis is done):
  - Element-by-element table from `similarities` and `elements`

- **Claim Analysis** (if evaluation is done):
  - Claim text and decomposition from `claims` and `elements`

- **Prior Art Research** (if prior art research is done):
  - Prior art references from `prior_art_elements`
  - Claim chart comparison

- **Pending Sections**:
  - Mark incomplete phases as "Pending" with brief description of what
    remains to be done

### Step 5: Output Report

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
- [ ] Phase status correctly determined from DB (not hardcoded)
- [ ] Only completed phases show data; incomplete phases show "Pending"
- [ ] NO legal assertions (infringement, validity conclusions)
- [ ] Write tool used to create `<patent_id>.md`
- [ ] Legal-checking skill invoked on the generated report
