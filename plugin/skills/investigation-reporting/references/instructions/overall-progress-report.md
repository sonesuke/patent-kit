# Overall Progress Report Instructions

## Purpose

Generate a comprehensive progress report for the entire patent investigation
workflow.

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

### Step 2: Get Investigation Progress from Database

**CRITICAL: Use `investigation-fetching` skill for all data retrieval.**
Do NOT parse files from investigation directories.

#### 2a. Evaluation Progress

```
Skill: investigation-fetching
Request: "Get list of relevant patents without evaluation"
```

Returns patents that have been screened as relevant but have no claims
recorded yet.

#### 2b. Claim Analysis Progress

```
Skill: investigation-fetching
Request: "Get list of patents with elements but no similarities"
```

Returns patents that have elements decomposed but no similarity analysis
completed.

#### 2c. Prior Art Progress

```
Skill: investigation-fetching
Request: "Get list of patents without prior arts"
```

Returns patents with Moderate/Significant similarities that have no prior art
research yet.

### Step 3: Build Patent Summary Table

For each relevant patent, determine its investigation status by querying the
database:

| Patent ID | Evaluation | Similarity (Inv.) | Prior Art | Verdict |
|-----------|-----------|-------------------|-----------|---------|

- **Evaluation**: `Done` if claims exist in DB, `Pending` otherwise
- **Similarity**: Max similarity level from DB (`Significant` > `Moderate` > `Pending`)
- **Prior Art**: `Done` if prior_art_elements exist, `Pending` otherwise
- **Verdict**: Based on similarity and prior art results

**CRITICAL: Filter based on claim-analysis similarity levels.**

- **Include** patents where:
  - Similarity shows: `Significant`, `Moderate`, or `Pending`
  - At least ONE element is NOT `Limited`

- **Exclude** patents where:
  - All similarities are `Limited`
  - Safe/Low Risk patents should NOT appear in the table

### Step 4: Generate Report

**CRITICAL: Use the Write tool to create `PROGRESS.md` in the project root
directory.**

DO NOT just output the report as text - you MUST use the Write tool to save it
to `PROGRESS.md`.

1. Read template from `assets/investigation-report-template.md`
2. Fill in statistics and patent table following the template structure
3. Write to `PROGRESS.md` using Write tool
4. Run legal-checking on the generated report:
   ```
   Skill: legal-checking
   Request: "<path_to_PROGRESS.md>"
   ```

**Template sections**:

- Overview: Workflow phase status summary
- Screening Summary: Database statistics table
- Investigation Progress: Filtered patent table (exclude Limited/low-risk)
- Next Actions: Recommended next steps

## Quality Checks

- [ ] Database statistics correctly retrieved
- [ ] Investigation progress derived from DB queries, not file parsing
- [ ] Standard template sections used
- [ ] NO extra sections (Top Patents, Current Status, Risk Summary, Recommendations)
- [ ] NO duplicated information
- [ ] NO legal assertions (Does not satisfy, Does not infringe, etc.)
- [ ] Limited/low-risk patents EXCLUDED from Investigation Progress table
- [ ] Write tool used to create PROGRESS.md
- [ ] Legal-checking skill invoked on the generated report
