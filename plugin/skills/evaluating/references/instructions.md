# Evaluating - Detailed Instructions

## Template Adherence

- **Requirement**: Strict adherence to the output template is required.
- **Template**: Located in `assets/` directory.
  - `evaluation-template.md` - Use for `3-investigations/<patent-id>/evaluation.md`

## Overview

Generate a detailed evaluation report for a screened patent. This phase analyzes claim elements, legal status, and creates investigation specifications for prior art search.

## Input

- **Patent ID**: `<patent-id>` (optional)
  - If not specified, the next uninvestigated relevant patent will be automatically selected from the database.

## Process

The evaluation process consists of the following steps:

| Step | Description          | Instruction File                                 |
| ---- | -------------------- | ------------------------------------------------ |
| 0    | Determine Patent ID  | `references/instructions/determine-patent-id.md` |
| 1    | Load Required Skills | `references/instructions/load-skills.md`         |
| 2    | Patent Analysis      | `references/instructions/analyze-patent.md`      |
| 3    | Report Generation    | `references/instructions/generate-report.md`     |

## Step Summaries

### Step 0: Determine Patent ID

Determine which patent to evaluate based on user input or database query.

**Details**: See `references/instructions/determine-patent-id.md`

### Step 1: Load Required Skills

Load required skills (`constitution-reminding`, `legal-checking`) before starting patent evaluation.

**Details**: See `references/instructions/load-skills.md`

### Step 2: Patent Analysis

Analyze the patent to extract key information:

- Retrieve patent data using `google-patent-cli:patent-fetch`
- Analyze independent and dependent claims
- Check for divisional applications
- Verify legal status and 3-year rule

**Details**: See `references/instructions/analyze-patent.md`

### Step 3: Report Generation

Generate the evaluation report based on patent analysis:

- Fill in evaluation template
- Avoid legal assertions
- Save report to `3-investigations/<patent-id>/evaluation.md`

**Details**: See `references/instructions/generate-report.md`

## Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

## Quality Gates

See individual instruction files for detailed quality gates:

- **Step 1**: `load-skills.md`
- **Step 2**: `analyze-patent.md`
- **Step 3**: `generate-report.md`

## Deliverables

1. `3-investigations/<patent-id>/evaluation.md`
