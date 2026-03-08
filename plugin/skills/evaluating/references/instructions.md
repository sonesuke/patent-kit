# Step 1: Patent Analysis

Analyze patents to extract key information for evaluation.

## Process Overview

### Database Integration

Use the Skill tool to load the appropriate database skills:

- **For data retrieval**: Use `investigation-preparing` skill
  - Getting next patent IDs (relevant but not yet evaluated)
  - Getting progress statistics

- **For data recording**: Use `investigation-recording` skill
  - Recording claims and elements
  - Recording screening results

### Automated Patent Analysis

Process all relevant patents from the `screened_patents` table.

> [!NOTE]
> **Parallel Processing with patent-evaluator Subagent**:
>
> - **For multiple patents (2+)**: MUST use the Agent tool with `patent-evaluator` subagent
> - **For single patent**: Process directly or use `patent-evaluator` subagent
> - The `patent-evaluator` subagent has investigation-recording skill preloaded
> - Subagent follows strict rules: ALWAYS use investigation-recording skill, NEVER write raw SQL
> - Results are reported back to the main agent for aggregation

**Process Steps**:

1. **Get Patents to Analyze**:
   - **Action**: Use the `investigation-preparing` skill
   - **Request**: "Get list of relevant patents without evaluation"

2. **Analyze Patents**:
   - **If single patent**: Process directly following the steps below
   - **If multiple patents (2+)**: MUST use the Agent tool with patent-evaluator subagent for parallel processing

     **Example for 2 patents**:

     ```
     Use the Agent tool to launch patent-evaluator subagents in parallel:
     - Subagent 1: Analyze patent <PATENT_ID_1> by fetching details, decomposing claims, and recording to database
     - Subagent 2: Analyze patent <PATENT_ID_2> by fetching details, decomposing claims, and recording to database

     Agent tool parameters:
     - subagent_type: "patent-evaluator"
     - name: "evaluator-<patent-id>"
     - description: "Analyze patent <PATENT_ID> and record claims/elements"
     - prompt: "Fetch patent <PATENT_ID> using google-patent-cli:patent-fetch skill, decompose Claim 1 into elements, and record all claims and elements using investigation-recording skill"
     ```

     Each subagent processes one patent independently with investigation-recording skill preloaded.

## Output

- `patents.db` (claims table): Patent claims with types and text
- `patents.db` (elements table): Constituent elements of claims with labels and descriptions

## Quality Gates

- [ ] **Patents Retrieved**: All assigned patents fetched using `google-patent-cli:patent-fetch` skill
- [ ] **Independent Claims Analyzed**: Claim 1 decomposed into elements (A, B, C...)
- [ ] **Dependent Claims Identified**: Key dependent claims summarized
- [ ] **Divisional Check Completed**: Divisional application status verified (if applicable)
- [ ] **Status Verification Completed**: Legal status and 3-year rule checked
- [ ] **Claims Recorded**: Claims stored in database using `investigation-recording` skill
- [ ] **Elements Recorded**: Constituent elements stored in database using `investigation-recording` skill
