# Specific Patent Report Instructions

## Purpose

Generate a detailed report for a single specified patent.

## Process

### Step 1: Extract Patent ID

Parse user request to extract patent ID:

- "Tell me about US20240292070A1" → Extract: `US20240292070A1`
- "Report on patent US9876543B2" → Extract: `US9876543B2`

### Step 2: Locate Investigation Directory

Find investigation directory: `investigation/{patent_id}/`

If not found, report: "No investigation found for {patent_id}"

### Step 3: Parse Investigation Files

Read and parse:

1. `evaluation.md`: Overall similarity assessment
2. `claim-analysis.md`: Detailed claim-by-claim analysis
3. `prior-art.md`: Prior art research results (if exists)

### Step 4: Format Element-by-Element Table

**For claim-analysis.md**, create table:

| Element           | Target        | Disclosure          | Verdict                |
| ----------------- | ------------- | ------------------- | ---------------------- |
| A. [element name] | [target spec] | [patent disclosure] | Present/Partial/Absent |
| B. [element name] | [target spec] | [patent disclosure] | Present/Partial/Absent |

**For prior-art.md** (if exists):

- List prior art patents found
- Summarize relevance level

### Step 5: Output Report

**For specific patent reports, output directly as text. DO NOT create a file.**

Use the template from `assets/specific-patent-report-template.md`:

1. Read template
2. Fill in patent-specific information
3. Output as formatted text (no file creation)

Template includes:

- Basic Information
- Similarity Assessment
- Element Analysis
- Claim Analysis
- Prior Art Research (with prior-art-researching template structure)

## Quality Checks

- [ ] Patent ID correctly extracted
- [ ] Investigation files parsed successfully
- [ ] Element table includes all elements from claim-analysis.md
- [ ] NO legal assertions (infringement, validity conclusions)
- [ ] Output as text (no file creation for specific patents)
