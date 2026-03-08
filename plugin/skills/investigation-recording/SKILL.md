---
name: investigation-recording
description: |
  Manages patent investigation database recording operations using SQLite.

  IMPORTANT: This skill should be invoked via the Skill tool for database operations.
  DO NOT read internal instruction files (references/instructions/*.md) directly.

  Supported operations:
  - "Record screening result for <patent-id>: <data>"
  - "Record claims for patent <patent-id>: <claims_data>"
  - "Record elements for patent <patent-id>: <elements_data>"
  - "Batch insert claims: <claims_list>"
  - "Batch insert elements: <elements_list>"

  This skill handles all database recording operations with efficient batch INSERT.
  Just provide the data and let the skill manage the database.

  NOTE: This skill assumes `patents.db` already exists in the working directory.
  Use investigation-preparing skill for database initialization.
metadata:
  author: sonesuke
  version: 1.0.0
context: fork
---

# Patent Investigation Database - Recording Operations

## For External Skills and Agents

**WARNING**: DO NOT read files from `references/instructions/` directory. Those are
internal reference files for this skill's internal use only.

**To use this skill**:

1. Invoke via Skill tool: `Skill: investigating-database-recording`
2. Provide your request with data
3. The skill will handle all SQL operations automatically using batch INSERT

**Example requests**:

- "Record screening result: id=US1234567A1, judgment=relevant, reason=..."
- "Record claims for patent US1234567A1: claim_1=..., claim_2=..."
- "Record elements for patent US1234567A1: element_a=..., element_b=..."
- "Batch insert 3 claims for patent US1234567A1: <claims_data>"

## Purpose

Manages database recording operations for the SQLite database (`patents.db`)
in the working directory, including screening results, claims, and elements.

## For External Skills and Agents

**CRITICAL RULES**:

1. **ALWAYS use this skill via the Skill tool**
   - Do NOT write raw sqlite3 INSERT commands manually
   - Do NOT read internal instruction files
   - The skill handles all SQL operations internally

2. **Provide data in structured format**
   - For claims: Provide claim_number, claim_type, claim_text
   - For elements: Provide element_label, description, claim_number
   - The skill will format and execute batch INSERT

3. **Database must exist**
   - This skill assumes `patents.db` exists in working directory
   - Use investigating-database-preparing skill for initialization

## Internal Reference (For This Skill Only)

The following sections are for the skill's internal operations when processing
requests from external agents.

### Database Prerequisites

- SQLite3 command must be available
- `patents.db` must exist in working directory (created by investigation-preparing)
- Workspace must be writable

### Internal Operation Mapping (For This Skill Only)

When processing external requests, map them to internal instruction files:

| External Request                | Internal Reference File                     |
| ------------------------------- | ------------------------------------------- |
| "Record screening result..."    | references/instructions/record-screening.md |
| "Record claims for patent..."   | references/instructions/record-claims.md    |
| "Record elements for patent..." | references/instructions/record-elements.md  |

**CRITICAL**: These reference files are for INTERNAL USE ONLY. External agents
should invoke via Skill tool, not read these files.

### SQL Execution (Internal Use Only)

When executing SQL operations based on internal reference files:

**For single record**:

```bash
sqlite3 patents.db "<SQL_QUERY>"
```

**For batch records (recommended)**:

```bash
sqlite3 patents.db -cmd ".timeout 30000" <<EOF
INSERT INTO claims (patent_id, claim_number, claim_type, claim_text) VALUES
  ('PATENT_ID', 1, 'independent', 'CLAIM_TEXT'),
  ('PATENT_ID', 2, 'dependent', 'CLAIM_TEXT');
EOF
```

**For large batches (10+ records)**:

- Use batch INSERT with multiple VALUES tuples
- Set timeout to 30000ms for concurrent access
- Verify insert with COUNT query

### Output Formats

- **Success confirmation**: "X records inserted successfully"
- **Error messages**: Clear error description with SQL error code
- **Verification**: Return COUNT of inserted records

## Internal Workflows (For This Skill Only)

### Workflow 1: Record Screening Result

1. External: "Record screening result: id=US1234567A1, judgment=relevant, reason=..."
2. Internal: Execute record-screening.md → Insert into screened_patents table
3. Verify: Return confirmation with patent_id

### Workflow 2: Record Claims

1. External: "Record claims for patent US1234567A1: claim_1=..., claim_2=..."
2. Internal: Parse claims data → Execute batch INSERT via record-claims.md
3. Verify: Return count of inserted claims

### Workflow 3: Record Elements

1. External: "Record elements for patent US1234567A1: element_a=..., element_b=..."
2. Internal: Parse elements data → Execute batch INSERT via record-elements.md
3. Verify: Return count of inserted elements

### Workflow 4: Batch Recording

1. External: "Batch insert 5 claims for patent US1234567A1: <claims_list>"
2. Internal: Parse all claims → Execute single batch INSERT statement
3. Verify: Return confirmation with count

## State Management

### Prerequisites

- `patents.db` exists in working directory
- Relevant tables (screened_patents, claims, elements) are created

### Final State

- Screening results recorded in screened_patents table
- Claims recorded in claims table
- Elements recorded in elements table
- Data available for querying via investigation-preparing skill

## Internal References (For This Skill Only)

These files are for the skill's internal use when processing requests. External
agents should NOT read these:

- **references/instructions/**: Operation-based documentation (SQL queries and operations)
  - `record-screening.md`: Screening result recording with batch INSERT
  - `record-claims.md`: Patent claims recording with batch INSERT
  - `record-elements.md`: Constituent elements recording with batch INSERT

**IMPORTANT**: External agents should invoke this skill via the Skill tool, not
access these internal files directly.

## Performance Notes

### Batch Operations

This skill uses batch INSERT for efficiency:

- **Single record**: Direct INSERT
- **2-10 records**: Batch INSERT with multiple VALUES
- **10+ records**: Large batch INSERT with 30s timeout

### Concurrency

For parallel processing (multiple subagents):

- Each subagent should use this skill independently
- SQLite handles concurrent reads efficiently
- Write operations use 30s timeout to prevent busy errors
- Consider transactions for multi-step operations

### Verification

After each recording operation, the skill verifies:

- COUNT of inserted records
- Last inserted ID (for single record)
- Error messages (for failed operations)
