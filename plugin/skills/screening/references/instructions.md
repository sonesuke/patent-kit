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

#### Screening Process

Process all patents from the `target_patents` table using **parallel agents**:

> [!NOTE]
> **Parallel Processing with Team**:
>
> - Create a team of multiple agents to process patents in parallel
> - Each agent works independently on assigned patents
> - Results are aggregated after all agents complete

**Process Steps**:

1. **Get Unscreened Patents**:
   - **Action**: Use the `investigating-database` skill
   - **Request**: "Get list of unscreened patent IDs"
   - **Divide** the list into batches for parallel processing

2. **Create Screening Team**:
   - Use the Agent tool to create a team with multiple teammates
   - Recommended team size: 3-5 agents depending on patent volume
   - Each teammate will process a subset of patents

3. **Assign Patents to Agents**:
   - Divide unscreened patents evenly among teammates
   - For each agent, send message with assigned patent IDs
   - Request: "Screen these patents: [ID1, ID2, ID3, ...]"

4. **Agent Screening Task** (each teammate executes independently):

   For each assigned patent:
   - **Fetch Data**: Use `google-patent-cli:patent-fetch` skill
   - **Judgment**: Check abstract and legal status
     - **Auto-Reject**: Expired/Withdrawn → `expired`
     - **Relevance**: Compare against Theme/Domain from specification
       - **Criteria**: Check at Theme/Domain level. Is it relevant to the business area?
       - **Exception**: Even if the domain differs, KEEP if technology could serve as infrastructure or a common platform for the product
       - **Examples**:
         - **Relevant**: Defined Theme, Direct Competitors, Core Tech
         - **Irrelevant**: Completely different industry (e.g., Medical vs Web)
     - **Judgment Values**: `relevant`, `irrelevant`, `expired` (lowercase)
   - **Record Result**: Use `investigating-database` skill to record judgment

5. **Wait for Completion**:
   - Wait for all teammates to complete their tasks
   - All screening results are now in the database

## Output

- `patents.db` (screened_patents table): Database of screened patents with judgments and reasons
