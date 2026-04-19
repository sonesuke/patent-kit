# Overall Progress Report Instructions

## Purpose

Generate a progress report for the entire patent investigation workflow.

## Process

### Step 1: Get Screening Statistics

```
Skill: investigation-fetching
Request: "Count screening progress"
```

Expected JSON output:

- `total_targets`: Total patents in targeting
- `total_screened`: Total patents screened
- `relevant`: Relevant patent count
- `irrelevant`: Irrelevant patent count
- `expired`: Expired patent count

### Step 2: Get Claim Analysis Statistics

```
Skill: investigation-fetching
Request: "Count claim analysis progress"
```

Expected JSON output:

- `all_count`: Total patents with similarity results
- `limited_count`: Patents where all similarities are Limited
- `not_limited_count`: Patents with at least one Significant or Moderate similarity

### Step 3: Get Prior Art Statistics

```
Skill: investigation-fetching
Request: "Count prior art progress"
```

Expected JSON output (scoped to Not Limited patents only):

- `all_count`: Total Not Limited patents
- `resolved_count`: Patents with prior art elements having Significant relevance
- `open_count`: Patents with prior art elements but none with Significant relevance
- `pending_count`: Not Limited patents with no prior art elements at all

### Step 4: Generate Report

**CRITICAL: Use the Write tool to create `PROGRESS.md` in the project root
directory.**

DO NOT just output the report as text - you MUST use the Write tool to save it
to `PROGRESS.md`.

1. Read template from `assets/investigation-report-template.md`
2. **EXACTLY follow the template structure** — use the exact section names and
   metric names from the template
3. Replace placeholder values (X, Y, Z, A, B, C, W) with actual counts
4. Write to `PROGRESS.md` using Write tool
5. Run legal-checking on the generated report:
   ```
   Skill: legal-checking
   Request: "<path_to_PROGRESS.md>"
   ```

**CRITICAL RULES**:

1. **Use EXACTLY these section names** (no other sections allowed):
   - `## Screening`
   - `## Claim Analysis`
   - `## Prior Art`
   - `## Next Actions`

2. **Use EXACTLY these metric names** in the Screening table:
   - `Targets` (not "Total Target Patents")
   - `Screened` (not "Patents Screened")
   - `Relevant`
   - `Irrelevant`
   - `Expired`

3. **Use EXACTLY these metric names** in the Claim Analysis table:
   - `All`
   - `Limited`
   - `Not Limited`

4. **Use EXACTLY these metric names** in the Prior Art table:
   - `All`
   - `Resolved`
   - `Open`
   - `Pending`

5. **DO NOT** add any prose text, explanations, or summaries between or after
   tables. Only tables and section headers.
6. **DO NOT** create an "Evaluation" section — Evaluation is part of the
   Screening phase.
7. **DO NOT** create an "Overview" section.

## Quality Checks

- [ ] All data retrieved from investigation-fetching (no raw SQL, no file parsing)
- [ ] Claim Analysis counts: All = Limited + Not Limited
- [ ] Prior Art counts: All = Resolved + Open + Pending
- [ ] Exactly 4 sections: Screening, Claim Analysis, Prior Art, Next Actions
- [ ] Metric names match template exactly
- [ ] NO extra sections (Evaluation, Overview, Top Patents, Current Status, etc.)
- [ ] NO prose text between or after tables
- [ ] NO legal assertions (Does not satisfy, Does not infringe, etc.)
- [ ] Write tool used to create PROGRESS.md
- [ ] Legal-checking skill invoked on the generated report
