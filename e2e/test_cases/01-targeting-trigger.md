# E2E Test Case: Targeting Trigger & Scope

**Description**: This test validates that the `targeting` skill loads properly when explicitly requested and correctly identifies its boundary, extracting initial golden keywords without hallucinating the entire patent screening process.

**Persona**: You are a Patent Engineer beginning a new project to identify prior art for a "Folding dual-screen smartphone".

**Input / Trigger Phrase**:
"Create a target population for a folding dual-screen smartphone. The target release date is 2025-01-01 and the cutoff date is 2020-01-01."

**Simulated User Responses**:

- If asked about search count or to proceed with creating `target.jsonl`: "Yes, please proceed with formatting the query and fetching the CSV."

**Evaluation Command**:

```bash
[ -f 1-targeting/keywords.md ] && grep -q -i "smartphone" 1-targeting/keywords.md
```

**Expected Outcome**:
The `targeting` skill is correctly identified. Golden keywords are extracted and written to `1-targeting/keywords.md`. The evaluation command exits with 0.
There should be NO leakage into screening or evaluation phases.
