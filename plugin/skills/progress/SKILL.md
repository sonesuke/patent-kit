---
name: progress
description: "現在の特許調査ワークフローの進捗状況をレポートとして出力する。ユーザーが「今の進捗を教えて」「サマリーを出して」と求めた場合に使用。"
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

Example 1: 進捗の確認
User says: "今のプロジェクトの進捗を教えて"
Actions:

1. report-progressスクリプトを実行し、JSONを取得
2. 各フェーズの完了件数や、評価待ちの特許件数を集計
   Result: PROGRESS.md がプロジェクトルートに出力される

# Troubleshooting

Error: "report-progress.sh execution failed"
Cause: 必要な実行権限がないか、ディレクトリ構造が壊れている
Solution: スクリプトに実行権限（chmod +x）があるか確認し、正しいプロジェクトルートで実行しているか確認してください
