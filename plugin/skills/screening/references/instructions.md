# Screening Instructions

## Purpose

Filter collected patents by legal status and relevance to prepare for Evaluation phase.

## Prerequisites

- `patents.db` must exist (generated in Phase 1 Targeting, `target_patents` table)
- `0-specifications/specification.md` must exist (Product/Theme definition)
- Constitution-reminding skill loaded for core principles
- Legal-checking skill loaded for legal compliance guidelines

## Process Overview

### Phase 1: Preparation

1. **Load Constitution**: Use the Skill tool to load the `constitution-reminding` skill
2. **Load Legal Checker**: Use the Skill tool to load the `legal-checking` skill
3. **Read Specification**: Read `0-specifications/specification.md` to understand Theme, Domain, and Target Product

### Phase 2: Automated Screening

#### Database Integration

Use the Skill tool to load the `investigating-database` skill for:

- Getting next patent ID
- Recording screening results
- Getting progress statistics

#### Screening Loop

Process all patents from the `target_patents` table **sequentially**:

> [!WARNING]
> **Long-Running Sequential Task**:
>
> - Process records **one by one**. No batch processing, loops, or automation scripts.
> - Do not ask questions or stop midway. Complete the entire task silently.
> - No policy changes or proposals needed. If in doubt, proceed with your own judgment.
> - Do not output intermediate results; only provide the final output.
> - Accuracy over speed. Self-check every 5 records: "Am I processing one by one?"

**For each patent**:

1. **Get Patent ID**:
   - Use the Skill tool to load the `investigating-database` skill
   - Request: "Get next patent ID"

2. **Fetch Data**:
   - Run: `fetch-patent <PATENT_ID>`
   - Saves to `2-screening/json/<PATENT_ID>.json`

3. **Read & Judgment**:
   - Use Read tool to read `2-screening/json/<PATENT_ID>.json`
   - Check `abstract_text` and `legal_status` (if available)
   - **Auto-Reject**: If status is Expired/Withdrawn → `expired`
     - Reason: "Status is [actual status]"
   - **Relevance**: Compare against Theme/Domain from specification
     - **Criteria**: Check at Theme/Domain level. Is it relevant to the business area?
     - **Exception**: KEEP if technology could serve as infrastructure/platform
     - **Examples**:
       - **Relevant**: Defined Theme, Direct Competitors, Core Tech
       - **Irrelevant**: Completely different industry (e.g., Medical vs Web)

   > [!IMPORTANT]
   > **Judgment Values**: Use ONLY one of: `relevant`, `irrelevant`, `expired` (lowercase)

4. **Record Result**:
   - Use the Skill tool to load the `investigating-database` skill
   - Request: "Record screening result for patent <ID>: judgment=<JUDGMENT>, reason=<REASON>"

### Phase 3: Generate Summary Report

1. **Aggregate Results**:
   - Use the Skill tool to load the `investigating-database` skill
   - Request: "Get screening progress statistics"
   - Use JSON output to fill report:
     - Total: `total_targets`
     - Screened: `total_screened`
     - Relevant: `relevant`
     - Irrelevant: `irrelevant`
     - Expired: `expired`

2. **Top 10 Relevant Patents**:

   ```sql
   SELECT patent_id, title, reason
   FROM screened_patents
   WHERE judgment = 'relevant'
   ORDER BY screened_at DESC
   LIMIT 10;
   ```

3. **Output Report**:
   - Create `2-screening/screening.md` using template from `screening-template.md`
   - **Strictly follow template structure**
   - **DO NOT add extra sections**
   - Include: Progress, Relevant, Irrelevant, Expired, Not processed

## Output Management

To maintain context window efficiency:

- **Rule**: `fetch_patent` results MUST be saved to JSON file
  - Path: `2-screening/json/<patent-id>.json`
  - **Requirement**: Do NOT load large JSON outputs directly into context
  - **Action**: Use Read tool to access specific fields from saved JSON

## Output

- `patents.db` (screened_patents table): Database of screened patents
- `2-screening/screening.md`: Summary report of screening results

## Quality Gates

- [ ] All patents in `target_patents` table have been processed
- [ ] Each judgment is one of: `relevant`, `irrelevant`, `expired`
- [ ] Screened count matches (Relevant + Irrelevant + Expired)
- [ ] Summary statistics are accurate
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology"
  - [ ] Do NOT cite court cases
