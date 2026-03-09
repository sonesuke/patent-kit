---
name: investigation-reporting
description: |
  Outputs a progress report for the current patent investigation workflow.

  Triggered when the user asks for:
  - Progress summary: "What is the current progress?", "Give me a summary", "How is the investigation going?", "Show me the status"
  - Specific patent report: "Tell me about US1234567A", "Report on patent US1234567A", "What's the status of US1234567A?"
metadata:
  author: sonesuke
  version: 1.0.0
context: fork
---

# Investigation Report

Your task is to report the current status of the patent analysis workflow.

## For External Skills and Agents

**WARNING**: DO NOT read files from `references/instructions/` directory. Those are
internal reference files for this skill's internal use only.

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

The following sections are for the skill's internal operations when processing
requests from external agents.

### Process

#### Step 1: Get Database Statistics

Use the investigation-preparing skill to get the current status:

- Invoke via Skill tool: `Skill: investigation-preparing`
- Request: "Get screening progress statistics"

This returns JSON with:

- `total_targets`: Total patents in targeting
- `total_screened`: Total patents screened
- `relevant`: Relevant patent count
- `irrelevant`: Irrelevant patent count
- `expired`: Expired patent count

#### Step 2: Determine Report Mode

Based on the user's request, determine which mode to use:

**Overall Progress Report Mode** (default):

- User asks: "What is the current progress?", "Give me a summary", "How is the investigation going?"
- Refer to: `references/instructions/overall-progress-report.md`

**Specific Patent Report Mode**:

- User asks: "Tell me about US1234567A", "Report on patent US1234567A"
- Refer to: `references/instructions/specific-patent-report.md`

### Output

**CRITICAL: Use the Write tool to create the report file.**

- For overall progress: Create `PROGRESS.md` in the project root directory.
- For specific patent: Output directly as text (no file creation).

**DO NOT just output the report as text** - you MUST use the Write tool to save it for overall progress reports.

### Quality Gates

- [ ] Database statistics are correctly retrieved and mapped.
- [ ] Used strictly standard sections from template.
- [ ] No extra sections added (e.g., "Top Patents", "Current Status").
- [ ] No duplicated information.
- [ ] **NO Legal Assertions**: Ensure summary does not use terms like "Does not satisfy", "Does not infringe", "Is a core technology" or cite court cases.
- [ ] **Write tool used** for overall progress reports (not just text output).

## Internal Workflows (For This Skill Only)

### Workflow 1: Overall Progress Report

1. External: "What is the current progress?"
2. Internal: Get database statistics → Analyze investigation directories → Generate report using template → Write to PROGRESS.md

### Workflow 2: Specific Patent Report

1. External: "Tell me about US20240292070A1"
2. Internal: Extract patent ID from request → Parse investigation directory → Format element-by-element table → Output as text

## State Management

### Initial State

- No `PROGRESS.md` file exists (for overall progress)

### Final State

- `PROGRESS.md` created in project root with current investigation status (for overall progress)
- Or formatted patent report displayed to user (for specific patent)

## Internal References (For This Skill Only)

These files are for the skill's internal use when processing requests. External
agents should NOT read these:

- **references/instructions/**: Mode-specific operation instructions
  - `overall-progress-report.md`: Overall progress report generation
  - `specific-patent-report.md`: Single patent detailed report
- **assets/**: Templates and reference materials
  - `investigation-report-template.md`: Standard report template

**IMPORTANT**: External agents should invoke this skill via the Skill tool, not
access these internal files directly.

# Examples

Example 1: Checking Progress
User says: "Tell me the progress of the current project"
Actions:

1. Parse the directories for statuses
2. Tally the completed items in each phase and patents pending evaluation
   Result: PROGRESS.md is generated in the project root.

# Troubleshooting

Error: "Failed to read directories"
Cause: The directory structure is broken or missing.
Solution: Ensure you are running within the initialized project root.
