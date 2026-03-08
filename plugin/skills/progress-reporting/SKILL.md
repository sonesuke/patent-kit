---
name: progress-reporting
description: "Outputs a progress report for the current patent investigation workflow. Triggered when the user asks 'What is the current progress?' or 'Give me a summary'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Progress Report

Your task is to report the current status of the patent analysis workflow.

## Instructions

### Process

#### Step 1: Get Database Statistics

Use the database skill to get the current status:

- Use the Skill tool to load the `investigating-database` skill
- Request: "Get screening progress statistics"
- Or run: `bash plugin/skills/investigating-database/scripts/shell/get-statistics.sh`

This returns JSON with:

- `total_targets`: Total patents in targeting
- `total_screened`: Total patents screened
- `relevant`: Relevant patent count
- `irrelevant`: Irrelevant patent count
- `expired`: Expired patent count

#### Step 2: Analyze Output

Based on the database statistics and file analysis:

- **Phase 0**: Check `0-specifications/specification.md` exists.
- **Phase 1**: Check `1-targeting/targeting.md`, `1-targeting/keywords.md` exist and database has patents.
- **Phase 2**: Use database statistics (total_screened vs total_targets, relevant/irrelevant/expired counts).
- **Phase 3-5**: Parse investigation directories and JSON files.
  - Calculate **Claim Analysis Progress** (Claim Analysis Done / Relevant Patents from database).
  - Calculate **Prior Art Progress** (Prior Art Done / Claim Analysis Done).
  - **List Filtering (Critical)**:
    - **Include**: Patents where Claim Analysis is `Significant`, `Moderate`, or `Pending`.
    - **Exclude**: Patents where Claim Analysis is `Limited` (Safe/Low Risk).
  - For each INCLUDED investigation, format status as:
    - Claim Analysis: `Significant`, `Moderate`, or `Pending`.
    - Prior Art:
      - If Done: `Relevant`, `Alternative`, `Aligned`, `Escalated`.
      - Otherwise: `Pending`.

### Output

Generate a summary report using the template `[progress-template.md](templates/progress-template.md)`.

- **Strictly follow the template structure.**
- **DO NOT add any extra sections** (e.g., "Top Patents", "Current Status", "Risk Summary", "Recommendations").
- **DO NOT duplicate information.**

Save to `PROGRESS.md` in the project root.

### Quality Gates

- [ ] Database statistics are correctly retrieved and mapped.
- [ ] Used strictly standard sections (Overview, Screening Summary, Investigation Progress, Next Actions).
- [ ] No extra sections (e.g., "Top Patents", "Current Status") added.
- [ ] No duplicated information.
- [ ] **NO Legal Assertions**:
  - [ ] Ensure summary does not use terms like "Does not satisfy", "Does not infringe", "Is a core technology" or cite court cases.

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
