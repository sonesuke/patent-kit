---
description: "Phase 2: Screening"
---

# Phase 2: Screening

Your task is to consolidate the search results from the Targeting Phase and prepare the list of patents for Evaluation.

## Input

- **Search Queries**: Generated in Phase 1 (`1-targeting/targeting.md`).

## Process

### Step 1: Data Acquisition

1. **Instruct User**: Ask the user to perform the following:
   - **Action**: Go to Google Patents (<https://patents.google.com/>).
   - For each query generated in Phase 1:
     - Execute the query.
     - Download the results as a CSV file.
   - **Save Location**: Place all downloaded CSV files in `2-screening/csv/`.

### Step 2: Merge & Deduplicate

1. **Run Merge Command**:
   - Execute the following command to combine the CSV files and remove duplicates.
   - **Important**: Use `ftoc` command, NOT `google-patent-cli`.
   - Command: `ftoc merge --input-dir 2-screening/csv --output 2-screening/target.jsonl`

2. **Verify Output**:
   - Check that `2-screening/target.jsonl` has been created.
   - This file contains the consolidated list of unique patents to be screened/evaluated.

3. **Check Count**:
   - The `ftoc merge` command output displays the number of unique patents (e.g., `Merged 150 unique patents...`).
   - Confirm this count to understand the volume of patents to be screened.

### Step 3: Interactive Screening (Linux/Mac)

1. **Initialize Output**:
    - The output file will be `2-screening/screened.jsonl`.
    - Detect the current line number to resume from if the file exists (count lines).

2. **Iterative Screening Loop**:

    **For each line** in `2-screening/target.jsonl`:

    > [!WARNING]
    > **Strict Sequential Process**:
    > - You MUST process records **one by one**. Do NOT parallelize.
    > - Do NOT use batch processing. Process each record individually.
    > - Do NOT write Python scripts or use rule-based automation. You must manually fetch, read, and judge each record using the tools provided.
    > - Do NOT ask the user if they want to continue midway. Process ALL records until completion.
    > - **No progress display needed**: The user may be away during this process. Just proceed silently.
    > - **Take your time**: Speed is NOT the priority. Accuracy and thorough manual checks are required.
    > - **Self-check every 5 records**: After every 5 records, ask yourself: "I MUST process one by one. I MUST NOT use batch or parallel processing. Am I following this?"

    1. **Extract Patent ID**:
       ```bash
       head -n <LINE_NUM> 2-screening/target.jsonl | tail -n 1 | jq -r '.id'
       ```

    2. **Fetch Data**:
       ```bash
       ./.patent-kit/bin/google-patent-cli fetch "<PATENT_ID>" > 2-screening/json/<PATENT_ID>.json 2>&1
       ```

    3. **Read & Judgement**:
       - **Action**: Use `read_file` tool to read `2-screening/json/<PATENT_ID>.json`.
       - **Check**: Read `abstract_text` and `legal_status` (if available).
       - **Auto-Reject**: If status is Expired/Withdrawn -> `expired` (Reason: "Status is [actual status]").
       - **Relevance**: Check Theme/Domain vs Product.
         - **Criteria**:
           - **Level**: Check at the **Theme/Domain level only**. DO NOT compare constituent elements.
           - **Exception**: Even if the domain differs, **KEEP** if the technology could serve as **infrastructure** or a platform for the product defined in `0-specifications/specification.md`.
         - **Examples within context**:
           - **relevant**: Sales Support/SFA/CRM/AI Prediction.
           - **irrelevant**: Manufacturing, Medical, Advertising, etc.

       > [!IMPORTANT]
       > **Judgment Values**: Use ONLY one of: `expired`, `relevant`, `irrelevant` (lowercase).
       > **No Shell Variables**: Do NOT use shell variables. Write out literal values directly in the command.

    4. **Record Result**:
       - Append the result securely to the output file.
       ```bash
       echo '{"id":"<ID>","title":"<TITLE>","legal_status":"<LEGAL_STATUS>","judgment":"<JUDGMENT>","reason":"<REASON>","abstract_text":"<ABSTRACT>"}' | tee -a 2-screening/screened.jsonl > /dev/null
       ```

       > [!NOTE]
       > Ensure to escape double quotes in title/abstract_text/reason when constructing the JSON string for `echo`.

### Step 3 (Windows - PowerShell)

If using Windows PowerShell, use the following equivalents:

1. **Extract Patent ID**:
    ```powershell
    Get-Content 2-screening/target.jsonl | Select-Object -Index <LINE_NUM_MINUS_1> | ConvertFrom-Json | Select-Object -ExpandProperty id
    ```

2. **Fetch Data**:
    ```powershell
    ./.patent-kit/bin/google-patent-cli.exe fetch "<PATENT_ID>" > 2-screening/json/<PATENT_ID>.json 2>&1
    ```

3. **Record Result**:
    ```powershell
    $json = '{"id":"<ID>","title":"<TITLE>","legal_status":"<LEGAL_STATUS>","judgment":"<JUDGMENT>","reason":"<REASON>","abstract_text":"<ABSTRACT>"}'
    Add-Content -Path "2-screening/screened.jsonl" -Value $json -Encoding UTF8
    ```

## Output

- `2-screening/screened.jsonl`: The list of screened patents with legal_status, judgments, reasons, and abstract_texts.

{{ NEXT_STEP_INSTRUCTION }}
