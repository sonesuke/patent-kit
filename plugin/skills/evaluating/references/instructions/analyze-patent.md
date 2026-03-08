# Step 1: Patent Analysis

Analyze patents to extract key information for evaluation.

## Process Overview

### Database Integration

Use the Skill tool to load the `investigating-database` skill for:

- Getting next relevant patent IDs for evaluation
- Recording claims and elements
- Getting progress statistics

### Automated Patent Analysis

Process all relevant patents from the `screened_patents` table using **parallel agents**:

> [!NOTE]
> **Parallel Processing with Team**:
>
> - Create a team of multiple agents to process patents in parallel
> - Each agent works independently on assigned patents
> - Results are aggregated after all agents complete

**Process Steps**:

1. **Get Patents to Analyze**:
   - **Action**: Use the `investigating-database` skill
   - **Request**: "Get list of relevant patents without evaluation"
   - **Divide** the list into batches for parallel processing

2. **Create Analysis Team**:
   - Use the Agent tool to create a team with multiple teammates
   - Recommended team size: 3-5 agents depending on patent volume
   - Each teammate will process a subset of patents

3. **Assign Patents to Agents**:
   - Divide patents evenly among teammates
   - For each agent, send message with assigned patent IDs
   - Request: "Analyze these patents: [ID1, ID2, ID3, ...]"

4. **Agent Analysis Task** (each teammate executes independently):

   For each assigned patent:
   - **Fetch Data**: Use the Skill tool to load `google-patent-cli:patent-fetch` skill
     - This will call `fetch_patent` with your patent_id
     - The skill will automatically retrieve patent details including claims
     - **DO NOT** manually read JSON files or use Read tool on patent data files
   - **Analyze Claims**:
     - **Independent Claims**: Decompose Claim 1 into constituent elements (A, B, C...)
       - Identify each element's technical scope
       - Document relationships between elements
     - **Dependent Claims**: Identify key dependent claims that meaningfully narrow the scope
       - Note dependent claims that add critical features
       - Summarize how dependent claims modify the independent claim
   - **Divisional Application Check**:
     - Verify if this is a divisional application
     - **If yes**: Use the parent application's filing date (or priority date) as the effective reference date for prior art
     - Document divisional relationship
   - **Legal Status Verification**:
     - **3-Year Rule** (Japan): Examination must be requested within 3 years of filing
     - **Zombie Pending**: If Filing Date > 3 years ago AND Status is "Pending", mark as "Pending (Likely Withdrawn - Examination Deadline Exceeded)"
   - **Record Claims**: Use `investigating-database` skill
     - Request: "Record claims for patent <patent-id>"
     - Extract claim data (claim_number, claim_type, claim_text)
     - Store all claims in database
   - **Record Elements**: Use `investigating-database` skill
     - Request: "Record elements for claim <claim_number>"
     - For each analyzed claim, record constituent elements
     - Store element_label (A, B, C...) and element_description

5. **Wait for Completion**:
   - Wait for all teammates to complete their tasks
   - All claims and elements are now in the database

## Output

- `patents.db` (claims table): Patent claims with types and text
- `patents.db` (elements table): Constituent elements of claims with labels and descriptions

## Quality Gates

- [ ] **Patents Retrieved**: All assigned patents fetched using `google-patent-cli:patent-fetch` skill
- [ ] **Independent Claims Analyzed**: Claim 1 decomposed into elements (A, B, C...)
- [ ] **Dependent Claims Identified**: Key dependent claims summarized
- [ ] **Divisional Check Completed**: Divisional application status verified (if applicable)
- [ ] **Status Verification Completed**: Legal status and 3-year rule checked
- [ ] **Claims Recorded**: Claims stored in database using `investigating-database` skill
- [ ] **Elements Recorded**: Constituent elements stored in database using `investigating-database` skill

## Next Step

Proceed to Step 2: `generate-report.md` for report generation.
