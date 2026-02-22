---
name: progress
description: "Outputs a progress report for the current patent investigation workflow. Triggered when the user asks 'What is the current progress?' or 'Give me a summary'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Progress Report

Your task is to report the current status of the patent analysis workflow.

## Instructions

### Process

1. **Read Constitution**: Load the `constitution` skill to understand the core principles.

#### Step 1: Run Progress Script

Run the following script to get the current status in JSON format:

- Run: `report-progress`

> [!NOTE]
> **Scripts Location**:
>
> - Linux/Mac: `./scripts/shell/report-progress.sh`
> - Windows: `.\scripts\powershell\report-progress.ps1`

#### Step 2: Analyze Output

Based on the JSON output:

- **Phase 0**: Check `phase0.specification_md`.
- **Phase 1**: Check `phase1.targeting_md`, `keywords_md`, `target_jsonl`.
- **Phase 2**: Check `phase2` counts (screened vs total).
- **Phase 3-5**: Check `investigations` array.
  - Calculate **Claim Analysis Progress** (Claim Analysis Done / Relevant Patents from Phase 2).
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

- [ ] JSON data from `report-progress` is correctly mapped.
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
