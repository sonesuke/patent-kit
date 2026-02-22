# E2E Test Case: Targeting Trigger & Scope

**Description**: This test validates that the `targeting` skill loads properly when explicitly requested and correctly identifies its boundary, extracting initial golden keywords without hallucinating the entire patent screening process.

**Persona**: You are a Patent Engineer beginning a new project to identify prior art for a "Folding dual-screen smartphone".

**Input / Trigger Phrase**:
"Create a target population for a folding dual-screen smartphone. The target release date is 2025-01-01 and the cutoff date is 2020-01-01."

**Expected Outcome**:

1. [TRIGGERED] The `targeting` skill is correctly identified, loaded, and its instructions are followed.
2. [OUTPUT] A basic text search query is executed using the `search_patents` MCP tool.
3. [OUTPUT] Golden keywords are extracted and written to `1-targeting/keywords.md`.
4. [OUTPUT] The agent asks the user for feedback on the initial search hit count, demonstrating interactive querying as mandated by the skill, OR it attempts to automatically adjust the query to fall under 1000 hits.
5. [NO_LEAKAGE] The agent DOES NOT start evaluating or screening patents (no `screening.md` or `evaluation.md` files are created).
