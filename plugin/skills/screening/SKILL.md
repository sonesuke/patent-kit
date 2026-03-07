---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise (Step 2)"
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 2: Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for Evaluation phase.

## Prerequisites

- `patents.db` must exist (generated in Phase 1 Targeting, `target_patents` table)
- `0-specifications/specification.md` must exist (Product/Theme definition)
- Constitution-reminding skill must be loaded
- Legal-checking skill must be loaded

## Skill Orchestration

### 1. Load Required Skills (MANDATORY)

Use the Skill tool to load skills BEFORE starting any work:

1. **Constitution**: `constitution-reminding` - Understand core principles
2. **Legal Checker**: `legal-checking` - Legal compliance guidelines

### 2. Execute Screening

Follow the detailed screening process in `references/instructions.md`.

Key operations:

- Use `investigating-database` skill to get next patent ID
- Use `fetch-patent` MCP tool to retrieve patent details
- Use `investigating-database` skill to record screening results
- Use `investigating-database` skill to get progress statistics

### 3. Generate Report

Create `2-screening/screening.md` using template from `screening-template.md`.

## State Management

### Initial State

- `patents.db` exists with `target_patents` table populated
- No `screened_patents` entries (or partial screening in progress)

### Final State

- All patents in `target_patents` have corresponding entries in `screened_patents`
- `2-screening/screening.md` created with screening summary
- `2-screening/json/<patent-id>.json` files created for each patent

## References

See `references/` directory for:

- **instructions.md**: Detailed screening process and workflow
- **examples.md**: Usage examples and judgment examples
- **troubleshooting.md**: Common issues and solutions

#### Step 1: Automated Screening

> [!NOTE]
> **Database Skill**:
>
> Use the Skill tool to load the `investigating-database` skill for:
>
> - Getting patent IDs by row number
> - Recording screening results
> - Getting progress statistics

1. **Initialize Database**:
   - Ensure `patents.db` exists (created in Phase 1 Targeting).
   - Check existing screened patents to avoid duplicates (resume support).

2. **Iterative Screening Loop**:

   Process all patents from the `target_patents` table **sequentially**:

   > [!WARNING]
   > **Long-Running Sequential Task**:
   >
   > - Process records **one by one**. No batch processing, loops, or automation scripts (except provided tools).
   > - Do not ask questions or stop midway. Complete the entire task silently.
   > - No policy changes or proposals needed. If in doubt, proceed with your own judgment.
   > - Do not output intermediate results; only provide the final output. Long output is acceptable.
   > - Accuracy over speed. Self-check every 5 records: "Am I processing one by one?"
   1. **Get Patent ID**:
      - Use the Skill tool to load the `investigating-database` skill
      - Request: "Get next patent ID" (this automatically gets the next unscreened patent)

   2. **Fetch Data**:
      - Run: `fetch-patent <PATENT_ID>`
      - Saves to `2-screening/json/<PATENT_ID>.json`.

   3. **Read & Judgement**:
      - **Action**: Use `read_file` tool to read `2-screening/json/<PATENT_ID>.json`.
      - **Check**: Read `abstract_text` and `legal_status` (if available).
      - **Auto-Reject**: If status is Expired/Withdrawn -> `expired` (Reason: "Status is [actual status]").
      - **Relevance**: Compare against **Theme/Domain** defined in `0-specifications/specification.md`.
        - **Criteria**:
          - **Level**: Check at the **Theme/Domain level**. Is it relevant to the business area?
          - **Exception**: Even if the domain differs, **KEEP** if the technology could serve as **infrastructure** or a common platform for the product.
        - **Examples**:
          - **Relevant**: Defined Theme, Direct Competitors, Core Tech.
          - **Irrelevant**: Completely different industry (e.g., Medical vs Web), unrelated method.

      > [!IMPORTANT]
      > **Judgment Values**: Use ONLY one of: `relevant`, `irrelevant`, `expired` (lowercase).

   4. **Record Result**:
      - Use the Skill tool to load the `investigating-database` skill
      - Request: "Record screening result for patent <ID>: judgment=<JUDGMENT>, reason=<REASON>, legal_status=<STATUS>"

#### Step 2: Generate Summary Report

1. **Aggregate Results**:
   - Use the Skill tool to load the `investigating-database` skill
   - Request: "Get screening progress statistics"
   - Use the JSON output to fill the report:
     - Total: `total_targets`
     - Screened: `total_screened`
     - Relevant: `relevant`
     - Irrelevant: `irrelevant`
     - Expired: `expired`
   - For the **Top 10 Relevant Patents** table, query the database:
     ```sql
     SELECT patent_id, title, reason
     FROM screened_patents
     WHERE judgment = 'relevant'
     ORDER BY screened_at DESC
     LIMIT 10;
     ```

2. **Output Report**:

- Create `2-screening/screening.md` using the template from `screening-template.md`.
  - **Strictly follow the template structure.**
  - **DO NOT add any extra sections.**
  - Include: Progress (Screened/Total), Relevant, Irrelevant, Expired, Not processed.

### Output Management

To maintain context window efficiency:

- **Rule**: `fetch_patent` results MUST be saved to a JSON file.
  - Path: `2-screening/json/<patent-id>.json`
  - **Requirement**: Do NOT load large JSON outputs directly into context.
  - **Action**: Use Read tool or jq to access specific fields from saved JSON when needed.

### Output

- `patents.db` (screened_patents table): The database of screened patents with legal_status, judgments, reasons, and abstract_texts.
- `2-screening/screening.md`: Summary report of the screening results.

### Quality Gates

- [ ] All patents in `target_patents` table have been processed.
- [ ] Each judgment is one of: `relevant`, `irrelevant`, `expired`.
- [ ] Screened count matches (Relevant + Irrelevant + Expired).
- [ ] Summary statistics are accurate.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology" or cite court cases.

Run /patent-kit:evaluating <patent-id>

# Examples

Example 1: Starting Bulk Screening
User says: "Screen the 150 extracted patents"
Actions:

1. Read the theme and domain from specification.md
2. For each line in target.jsonl, use the MCP tool to fetch the patent
3. Determine if it is relevant / irrelevant / expired, and summarize
   Result: 2-screening/screened.jsonl and screening.md are generated.

# Troubleshooting

Error: "Rate limit exceeded / Timeout"
Cause: Sent too many fetch requests in a short period.
Solution: Resume from the unprocessed rows.
