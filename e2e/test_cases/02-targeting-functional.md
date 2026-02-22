# E2E Test Case: Targeting Functional Execution

**Description**: This test validates that the `targeting` skill can properly read an existing specification document, extract technical keywords, expand on synonyms, and formulate an appropriate patent search query payload.

**Prerequisites (Runner Setup)**:
Before executing the trigger, the test runner must:
`mkdir -p 0-specifications && cp e2e/fixtures/0-specifications/specification.md 0-specifications/specification.md`

**Persona**: You are a Patent Engineer who has just received a draft invention specification.

**Input / Trigger Phrase**:
"I have placed an invention specification in `0-specifications/specification.md`. Please read it and perform the Phase 1 targeting step (search query generation) for a 2025 product release."

**Expected Outcome**:

1. [PASS] The `targeting` skill reads the generated specification file.
2. [PASS] The skill identifies "solar-powered", "auto-cleaning", "IoT module", "cat litter box".
3. [PASS] The skill successfully writes the formulated queries and synonyms into `1-targeting/targeting.md`.
4. [PASS] The skill utilizes the `search_patents` tool with the formulated queries and writes the outcome to `1-targeting/target.jsonl`.
