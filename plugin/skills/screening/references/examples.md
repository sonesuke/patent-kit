# Screening Examples

## Example 1: Starting Bulk Screening

**User Request**: "Screen the patents"

**Actions**:

1. Read specification to understand Theme and Domain
2. Initialize database connection
3. For each patent in target_patents table:
   - Get next patent ID using investigating-database skill
   - Fetch patent details using google-patent-cli:patent-fetch skill
   - Analyze relevance from fetched data
   - Record result using investigating-database skill

**Result**:

- `patents.db` updated with screening results

## Example 2: Resuming Interrupted Screening

**Context**: Screening was interrupted at patent 50/150

**Actions**:

1. Investigating-database skill automatically checks existing screened_patents
2. Resume from patent 51 (next unscreened patent)
3. Continue until all 150 patents are processed

**Result**: Complete screening without duplicates

## Example 3: Judgment Examples

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

## Example 4: Infrastructure Exception

**Patent**: US2222222A - "Distributed Database System"

- **Abstract**: Generic database architecture
- **Domain**: Database technology (different from LLM)
- **Judgment**: `relevant`
- **Reason**: Infrastructure technology that could support the product platform

## Example 5: Legal Compliance

**❌ Incorrect Judgment**:

- "This patent does not infringe our core technology"
- "The method satisfies our claim requirements"

**✅ Correct Judgment**:

- "Relevant: Covers multi-turn conversation management"
- "Irrelevant: Surgical robotics for medical applications"
- "Expired: Legal status is Expired/Withdrawn"

- "This patent does not infringe our core technology"
- "The method satisfies our claim requirements"

**✅ Correct Judgment**:

- "Relevant: Covers multi-turn conversation management"
- "Irrelevant: Surgical robotics for medical applications"
- "Expired: Legal status is Expired/Withdrawn"
