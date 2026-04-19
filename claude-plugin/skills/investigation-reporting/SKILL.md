---
name: investigation-reporting
description: |
  Outputs a progress report for the current patent investigation workflow.

  Triggered when the user asks for:
  - Progress summary: "What is the current progress?", "Give me a summary", "How is the investigation going?", "Show me the status"
  - Specific patent report: "Tell me about US1234567A", "Report on patent US1234567A", "What's the status of US1234567A?"
context: fork
---

# Investigation Report

Your task is to report the current status of the patent analysis workflow.

## For External Skills and Agents

**To use this skill**:

1. Invoke via Skill tool: `Skill: investigation-reporting`
2. Provide your request with data
3. The skill will handle all operations automatically

**Example requests**:

- "What is the current progress?"
- "Give me a summary"
- "Tell me about US20240292070A1"
- "What's the status of patent US9876543B2?"

## Internal Reference (For This Skill Only)

### Process

#### Step 0: Read Template (MANDATORY)

**Before doing anything else, read the template file.**

- For overall progress: Read `assets/investigation-report-template.md`
- For specific patent: Read `assets/specific-patent-report-template.md`

You MUST use the exact section names and metric names from the template. Do NOT
invent your own structure.

#### Step 1: Determine Report Mode

**Overall Progress Report Mode** (default):

- User asks: "What is the current progress?", "Give me a summary", "How is the investigation going?"
- Use the `get_progress` MCP tool to retrieve investigation statistics:
  ```
  get_progress({})
  ```
- The result includes: total_targets, total_screened, relevant, irrelevant, expired
- Format using the template from `assets/investigation-report-template.md`

**Specific Patent Report Mode**:

- User asks: "Tell me about US1234567A", "Report on patent US1234567A"
- Use `get_patent_detail` MCP tool:
  ```
  get_patent_detail({ patent_id: "<patent_id>" })
  ```
- Additionally use `get_claims`, `get_elements`, and `get_product_features` MCP tools as needed
- Format using the template from `assets/specific-patent-report-template.md`

### Output

**CRITICAL: Use the Write tool to create the report file.**

- For overall progress: Create `PROGRESS.md` in the project root directory.
- For specific patent: Create `<patent_id>.md` in the project root directory.

**DO NOT just output the report as text** - you MUST use the Write tool to save it.

## State Management

### Initial State

- No `PROGRESS.md` file exists (for overall progress)

### Final State

- `PROGRESS.md` created in project root with current investigation status (for overall progress)
- `<patent_id>.md` created in project root with patent report (for specific patent)
