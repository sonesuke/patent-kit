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

| Step | Description       | Instruction File                             |
| ---- | ----------------- | -------------------------------------------- |
| 0    | Select Patent ID  | Use `investigating-database` skill           |
| 1    | Patent Analysis   | `references/instructions/analyze-patent.md`  |
| 2    | Report Generation | `references/instructions/generate-report.md` |

## Step Summaries

### Step 0: Select Patent ID

Select which patent to evaluate:

**If no patent ID provided**: Use the `investigating-database` skill to get the next relevant patent without evaluation

- Request: "Select patent ID for evaluation"
- The skill will find the first patent marked as `relevant` that doesn't yet have an evaluation report

**If patent ID provided**: Check for existing evaluation report

- If exists: Ask user for re-evaluation confirmation
- If not exists: Proceed with standard process

### Step 1: Patent Analysis

Analyze the patent to extract key information:

- Retrieve patent data using `google-patent-cli:patent-fetch`
- Analyze independent and dependent claims
- Check for divisional applications
- Verify legal status and 3-year rule

**Details**: See `references/instructions/analyze-patent.md`

### Step 2: Report Generation

Generate the evaluation report based on patent analysis:

- Fill in evaluation template
- Avoid legal assertions
- Save report to `3-investigations/<patent-id>/evaluation.md`
- Record evaluation completion using `investigating-database` skill

**Details**: See `references/instructions/generate-report.md`

## Output

- `3-investigations/<patent-id>/evaluation.md`: The evaluation report for the patent.

## Quality Gates

See individual instruction files for detailed quality gates:

- **Step 1**: `analyze-patent.md`
- **Step 2**: `generate-report.md`

## Deliverables

1. `3-investigations/<patent-id>/evaluation.md`
