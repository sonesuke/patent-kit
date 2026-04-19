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

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

## Skill Orchestration

### Execute Report Generation

**Do NOT delegate to subagents (Agent tool)** — call MCP tools directly from this session.

### Step 0: Read Template (MANDATORY)

**Before doing anything else, read the template file.**

- For overall progress: Read `references/templates/progress-report.md`
- For specific patent: Read `references/templates/patent-report.md`

You MUST use the exact section names and metric names from the template. Do NOT invent your own structure.

### Step 1: Determine Report Mode

**Overall Progress Report Mode** (default):

- User asks: "What is the current progress?", "Give me a summary", "How is the investigation going?"
- Call the `get_progress` MCP tool directly (no parameters)
- Also query claim analysis and prior art statistics using `db-query` if needed
- Format using the template

**Specific Patent Report Mode**:

- User asks: "Tell me about US1234567A", "Report on patent US1234567A"
- Call `get_patent_detail` MCP tool with the patent_id
- Call `get_claims` MCP tool with the patent_id
- Call `get_elements` MCP tool with the patent_id
- Call `get_product_features` MCP tool for context
- Format using the template

### Step 2: Generate Report

Use the Write tool to create the report file:

- For overall progress: Create `PROGRESS.md` in the project root directory
- For specific patent: Create `<patent_id>.md` in the project root directory

**DO NOT just output the report as text** — you MUST use the Write tool to save it.

### Step 3: Legal Check

After writing the report, invoke `Skill: patent-kit:legal-checking` with the report file path to verify compliance.

## State Management

### Initial State

- `patents.db` exists with investigation data

### Final State

- `PROGRESS.md` or `<patent_id>.md` created in project root
- Legal-checking skill invoked on the generated report
