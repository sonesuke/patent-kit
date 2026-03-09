# Overall Progress Report Instructions

## Purpose

Generate a comprehensive progress report for the entire patent investigation workflow.

## Process

### Step 1: Get Database Statistics

Use the investigation-preparing skill to get current screening statistics:

```
Skill: investigation-preparing
Request: "Get screening progress statistics"
```

Expected JSON output:

- `total_targets`: Total patents in targeting
- `total_screened`: Total patents screened
- `relevant`: Relevant patent count
- `irrelevant`: Irrelevant patent count
- `expired`: Expired patent count

### Step 2: Analyze Workflow Phases

Check each phase status:

1. **Concept Interviewing**: Verify `specification.md` exists.
2. **Targeting**: Verify `targeting.md` and `keywords.md` exist and database has patents.
3. **Screening**: Use database statistics (total_screened vs total_targets).
4. **Evaluation**: Parse investigation directories for evaluation.md files.
5. **Claim Analysis**: Parse claim-analysis.md files and calculate progress.
6. **Prior Art**: Parse prior-art.md files and calculate progress.

### Step 3: Filter Patents for Report

**CRITICAL: Filter based on claim-analysis.md element similarity levels.**

- **Include** patents in report where:
  - Claim Analysis shows: `Significant`, `Moderate`, or `Pending`
  - At least ONE element is NOT `Limited`

- **Exclude** patents from report where:
  - Claim Analysis shows: `Limited` (all elements are Limited)
  - Safe/Low Risk patents should NOT appear in Investigation Progress table

**For each included patent**, format status as:

- **Claim Analysis**: `Significant`, `Moderate`, or `Pending`
- **Prior Art**:
  - If done: `Relevant`, `Alternative`, `Aligned`, or `Escalated`
  - Otherwise: `Pending`

### Step 4: Generate Report

**CRITICAL: Use the Write tool to create `PROGRESS.md` in the project root directory.**

DO NOT just output the report as text - you MUST use the Write tool to save it to `PROGRESS.md`.

1. Read template from `assets/investigation-report-template.md`
2. Fill in statistics and patent table following the template structure
3. Write to `PROGRESS.md` using Write tool

**Template sections**:

- Overview: Workflow phase status summary
- Screening Summary: Database statistics table
- Investigation Progress: Filtered patent table (exclude Limited/low-risk)
- Next Actions: Recommended next steps

## Template Sections

Follow the template structure strictly:

1. **Overview**: Quick summary of workflow status
2. **Screening Summary**: Database statistics table
3. **Investigation Progress**: Filtered patent table (exclude Limited/low-risk)
4. **Next Actions**: Recommended next steps

## Quality Checks

- [ ] Database statistics correctly retrieved
- [ ] Standard template sections used
- [ ] NO extra sections (Top Patents, Current Status, Risk Summary, Recommendations)
- [ ] NO duplicated information
- [ ] NO legal assertions (Does not satisfy, Does not infringe, etc.)
- [ ] Limited/low-risk patents EXCLUDED from Investigation Progress table
- [ ] Write tool used to create PROGRESS.md
