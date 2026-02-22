# E2E Test Case: Targeting Functional Execution

**Description**: This test validates that the `targeting` skill can properly read an existing specification document, extract technical keywords, expand on synonyms, and formulate an appropriate patent search query payload.

**Prerequisites (Runner Setup)**:
Before executing the trigger, the test runner must:
`mkdir -p 0-specifications && cp e2e/fixtures/0-specifications/specification.md 0-specifications/specification.md`

**Persona**: You are a Patent Engineer who has just received a draft invention specification.

**Input / Trigger Phrase**:
"I have placed an invention specification in `0-specifications/specification.md`. Please read it and perform the Phase 1 targeting step (search query generation) for a 2025 product release."

**Simulated User Responses**:

- If asked about modifying keywords or synonyms: "Looks good, proceed to search."
- If asked whether the query hit counts are acceptable (~1000 hits): "The count is acceptable, proceed to merge."

**Evaluation Command**:

```bash
[ -f 1-targeting/targeting.md ] && [ -f 1-targeting/target.jsonl ] && [ $(wc -l < 1-targeting/target.jsonl) -gt 0 ]
```

**Expected Outcome**:
The `targeting` skill reads the generated specification file. It identifies "solar-powered", "auto-cleaning", "IoT module", "cat litter box". It writes formulated queries into `1-targeting/targeting.md` and successfully creates `1-targeting/target.jsonl`. The evaluation command checks for the existence of both files and ensures the JSONL is not empty (exit code 0).
