---
name: screening
description: "Phase 2: Screening"
---

# Phase 2: Screening

Your task is to filter the collected patents by legal status and relevance to prepare for Evaluation.

## Input

- **Target Patents**: `1-targeting/target.jsonl` (generated in Phase 1 Targeting).
- **Specification**: `0-specifications/specification.md` (Product/Theme definition).
- **Arguments** (optional):
  - `<start> - <end>`: Process records from line `start` to line `end` (inclusive).
  - `<start>`: Process records from line `start` to the last line.
  - (none): Process all records from the first to the last line.

## Process

1. **Read Constitution**: Read `.patent-kit/memory/constitution.md` to understand the core principles.
2. **Read Specification**: Read `0-specifications/specification.md` to fully understand the **Theme**, **Domain**, and **Target Product**. This is the CRITERIA for relevance.

### Step 1: Automated Screening

> [!NOTE]
> **Scripts Location**:
> 
> - Linux/Mac: `./.patent-kit/scripts/shell/*.sh`
> - Windows: `.\.patent-kit\scripts\powershell\*.ps1`

1. **Determine Range**:
   - Parse the arguments to determine `START_LINE` and `END_LINE`.
   - If no argument: `START_LINE = 1`, `END_LINE = (total lines in target.jsonl)`.
   - If `<start>` only: `START_LINE = start`, `END_LINE = (total lines)`.
   - If `<start> - <end>`: `START_LINE = start`, `END_LINE = end`.

2. **Initialize Output**:
    - The output file will be `2-screening/screened.jsonl`.
    - Check existing records to avoid duplicates (resume support).

3. **Iterative Screening Loop**:

    Process lines from `START_LINE` to `END_LINE` in `1-targeting/target.jsonl` **sequentially**:

    > [!WARNING]
    > **Long-Running Sequential Task**:
    > - Process records **one by one**. No batch processing, loops, or automation scripts (except provided tools).
    > - Do not ask questions or stop midway. Complete the entire task silently.
    > - No policy changes or proposals needed. If in doubt, proceed with your own judgment.
    > - Do not output intermediate results; only provide the final output. Long output is acceptable.
    > - Accuracy over speed. Self-check every 5 records: "Am I processing one by one?"

    1. **Extract Patent ID**:
       - Run: `extract-id <LINE_NUM>`

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
       - Run: `record-result "<ID>" "<TITLE>" "<LEGAL_STATUS>" "<JUDGMENT>" "<REASON>" "<ABSTRACT>"`

### Step 2: Generate Summary Report

1. **Aggregate Results & Top 10**:
   - Run: `report-progress`
   - Use the JSON output to fill the report.
     - Total: `phase1.total_targets`
     - Screened: `phase2.total_screened`
     - Relevant: `phase2.relevant`
     - Irrelevant: `phase2.irrelevant`
     - Expired: `phase2.expired`
   - Fill the **Top 10 Relevant Patents** table using the `phase2.top_10_relevant` array.

2. **Output Report**:
- Create `2-screening/screening.md` using the template from `screening-template.md`.
   - **Strictly follow the template structure.**
   - **DO NOT add any extra sections.**
   - Include: Progress (Screened/Total), Relevant, Irrelevant, Expired, Not processed.

## Output

- `2-screening/screened.jsonl`: The list of screened patents with legal_status, judgments, reasons, and abstract_texts.
- `2-screening/screening.md`: Summary report of the screening results.

## Quality Gates

- [ ] All records in `target.jsonl` have been processed.
- [ ] Each judgment is one of: `relevant`, `irrelevant`, `expired`.
- [ ] Screened count matches (Relevant + Irrelevant + Expired).
- [ ] Summary statistics are accurate.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology" or cite court cases.

Run /patent-kit:evaluation <patent-id>
