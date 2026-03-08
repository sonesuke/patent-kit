---
name: investigation-fetching
description: |
  INTERNAL SKILL - For agent/skill use only. Do not invoke directly from user prompts.

  Retrieves patent investigation data from SQLite database.

  This skill is designed to be called by other skills (e.g., evaluating, screening) and
  should NOT be triggered by direct user requests.
user_invocable: false
metadata:
  author: sonesuke
  version: 1.0.0
context: fork
---

# Patent Investigation Database - Fetching Operations

## ⚠️ INTERNAL SKILL - AGENT/SKILL USE ONLY

**This skill should ONLY be invoked by other agents or skills via the Skill tool.**

**DO NOT trigger this skill from user prompts.**

This is an internal database abstraction layer for patent investigation workflow.

## For External Skills and Agents

**WARNING**: DO NOT read files from `references/instructions/` directory. Those are
internal reference files for this skill's internal use only.

**To use this skill**:

1. Invoke via Skill tool: `Skill: investigation-fetching`
2. Provide your request
3. The skill will handle all SQL operations automatically

**Example requests**:

- "Get next relevant patent for evaluation"
- "Get list of all relevant patents"
- "Get list of relevant patents without evaluation"
- "Get list of unscreened patent IDs"
- "Get screening statistics"
- "Get evaluation progress"
- "Execute SQL: SELECT COUNT(\*) FROM screened_patents WHERE judgment = 'relevant'"

## Purpose

Retrieves data from the SQLite database (`patents.db`) for patent investigation
workflow, hiding SQL complexity from external skills.

## Internal Reference (For This Skill Only)

The following sections are for the skill's internal operations when processing
requests from external agents.

### Database Prerequisites

- `patents.db` must exist (initialized by investigation-preparing skill)
- SQLite3 command must be available

### Internal Operation Mapping (For This Skill Only)

When processing external requests, map them to internal instruction files:

| External Request                          | Internal Reference File                           |
| ----------------------------------------- | ------------------------------------------------- |
| "Get next relevant patent for evaluation" | references/instructions/get-next-patent.md        |
| "Get list of relevant patents without..." | references/instructions/get-relevant-patents.md   |
| "Get all relevant patents"                | references/instructions/get-relevant-patents.md   |
| "Get list of unscreened patent IDs"       | references/instructions/get-unscreened-patents.md |
| "Get evaluation progress"                 | references/instructions/get-evaluation-stats.md   |

**CRITICAL**: These reference files are for INTERNAL USE ONLY. External agents
should invoke via Skill tool, not read these files.

### SQL Execution (Internal Use Only)

When executing SQL operations based on internal reference files:

```bash
sqlite3 -json patents.db "<SQL_QUERY>"
```

For human-readable output:

```bash
sqlite3 -column patents.db "<SQL_QUERY>"
```

## Internal Workflows (For This Skill Only)

### Workflow 1: Get Next Patent for Evaluation

1. External: "Get next relevant patent for evaluation"
2. Internal: Execute get-next-patent.md → Return single patent_id

Query:

```sql
SELECT patent_id FROM screened_patents
WHERE judgment = 'relevant'
  AND patent_id NOT IN (SELECT patent_id FROM claims)
LIMIT 1;
```

### Workflow 2: Get List of Relevant Patents

1. External: "Get list of relevant patents without evaluation"
2. Internal: Execute get-relevant-patents.md → Return array of patent_ids

Query:

```sql
SELECT patent_id FROM screened_patents
WHERE judgment = 'relevant'
  AND patent_id NOT IN (SELECT patent_id FROM claims);
```

### Workflow 3: Get Statistics

1. External: "Get evaluation progress"
2. Internal: Execute get-evaluation-stats.md → Return JSON stats

## State Management

### Initial State

- `patents.db` exists with data

### Final State

- Data retrieved and returned to caller

## Internal References (For This Skill Only)

These files are for the skill's internal use when processing requests. External
agents should NOT read these:

- **references/instructions/**: Query-based documentation
  - `get-next-patent.md`: Get next patent for evaluation
  - `get-relevant-patents.md`: Get list of relevant patents
  - `get-unscreened-patents.md`: Get list of unscreened patents
  - `get-evaluation-stats.md`: Evaluation progress statistics
- \*\*references/schema.md`: Database schema documentation

**IMPORTANT**: External agents should invoke this skill via the Skill tool, not
access these internal files directly.
