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

Process all patents from the `target_patents` table.

> [!NOTE]
> **Parallel Processing**:
>
> - **For multiple patents (3+)**: MUST use the Agent tool with subagents for parallel processing
> - **For 1-2 patents**: Process directly
> - Subagents work independently on assigned patents
> - Results are reported back to the main agent for aggregation
> - **CRITICAL**: Use retry logic when recording to database (see `execute-sql-with-retry.md`)

**Process Steps**:

1. **Get Unscreened Patents**:
   - **Action**: Use the `investigating-database` skill
   - **Request**: "Get list of unscreened patent IDs"

2. **Screen Patents**:

   - **If 1-2 patents**: Process directly following the steps below
   - **If multiple patents (3+)**: MUST use the Agent tool to launch subagents in parallel
     - Each subagent processes one patent
     - All subagents work in parallel
     - Each subagent follows the same screening steps independently

   For each patent (or for each subagent):
   - **Fetch Data**: Use the Skill tool to load `google-patent-cli:patent-fetch` skill
     - This will call `fetch_patent` with your patent_id
     - The skill will automatically use `execute_cypher` to retrieve:
       - title, abstract_text, assignee, legal_status
     - **DO NOT** manually read JSON files or use Read tool on patent data files
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
     - Request: "Record screening result for patent <patent-id>"
     - Provide judgment data (judgment, reason, abstract_text)
     - Use retry logic when recording to database

## Output

- `patents.db` (screened_patents table): Database of screened patents with judgments and reasons
