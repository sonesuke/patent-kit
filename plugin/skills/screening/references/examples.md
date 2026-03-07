# Screening Examples

## Example 1: Starting Parallel Screening

**User Request**: "Screen the patents"

**Actions**:

1. Load constitution-reminding and legal-checking skills
2. Use investigating-database skill to get list of unscreened patent IDs
3. Create a team of 3-5 agents using Agent tool
4. Divide patent IDs evenly among teammates
5. Send message to each agent: "Screen these patents: [ID1, ID2, ID3, ...]"
6. Wait for all teammates to complete
7. Verify completion with investigating-database skill

**Result**:

- `patents.db` updated with screening results
- All patents processed in parallel

## Example 2: Resuming Interrupted Screening

**Context**: Screening was interrupted at patent 50/150

**Actions**:

1. Use investigating-database skill to get unscreened patent IDs
2. Create team and assign remaining patents (51-150) to agents
3. Agents process only unassigned patents
4. Continue until all 150 patents are processed

**Result**: Complete screening without duplicates

## Example 3: Judgment Guidelines

**Patent 1**: US1234567A - "Multi-turn Conversation System for Customer Service"

- **Abstract**: Describes LLM-based chatbot with context management
- **Legal Status**: Active
- **Judgment**: `relevant`
- **Reason**: Core technology for multi-turn LLM systems

**Patent 2**: US9876543A - "Surgical Robot Control System"

- **Abstract**: Medical robotics for automated surgery
- **Legal Status**: Active
- **Judgment**: `irrelevant`
- **Reason**: Different industry (Medical vs Web/Communication)

**Patent 3**: US1111111A - "Communication System"

- **Abstract**: Legacy packet switching (expired before priority date cutoff)
- **Legal Status**: Expired
- **Judgment**: `expired`
- **Reason**: Status is Expired

**Patent 4**: US2222222A - "Distributed Database System"

- **Abstract**: Generic database architecture
- **Domain**: Database technology (different from LLM)
- **Judgment**: `relevant`
- **Reason**: Infrastructure technology that could support the product platform

## Example 4: Handling Rate Limits

**Context**: Patent fetch operations failing with timeout errors

**Actions**:

1. Reduce team size from 5 to 3 agents
2. Add brief delays between batch processing
3. Resume processing - investigating-database skill skips completed patents
4. Continue until all patents processed

**Result**: Screening completes with reduced parallelism

## Example 5: Legal Compliance

**❌ Incorrect Judgment**:

- "This patent does not infringe our core technology"
- "The method satisfies our claim requirements"

**✅ Correct Judgment**:

- "Relevant: Covers multi-turn conversation management"
- "Irrelevant: Surgical robotics for medical applications"
- "Expired: Legal status is Expired/Withdrawn"
