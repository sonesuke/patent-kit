---
name: investigation-fetching
description: |
  INTERNAL SKILL - For agent/skill use only. Do not invoke directly from user prompts.

  Retrieves patent investigation data from SQLite database.

  This skill is designed to be called by other skills (e.g., evaluating, screening) and
  should NOT be triggered by direct user requests.
user_invocable: false
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
- "Count relevant patents"
- "Count relevant patents without evaluation"
- "Get list of unscreened patent IDs"
- "Get next patent for claim analysis"
- "Get elements for patent <patent-id>"
- "Get list of patents with elements but no similarities"
- "Count patents without similarities"
- "Count screening progress"
- "Count claim analysis progress"
- "Count patents without prior arts"
- "Count prior art progress"
- "Search features"
- "Search feature: <feature_name>"
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

| External Request                           | Internal Reference File                                     |
| ------------------------------------------ | ----------------------------------------------------------- |
| "Get next relevant patent for evaluation"  | references/instructions/get-next-patent.md                  |
| "Get list of relevant patents without..."  | references/instructions/get-relevant-patents.md             |
| "Get all relevant patents"                 | references/instructions/get-relevant-patents.md             |
| "Count relevant patents"                   | references/instructions/get-relevant-patents.md             |
| "Count relevant patents without..."        | references/instructions/get-relevant-patents.md             |
| "Get list of unscreened patent IDs"        | references/instructions/get-unscreened-patents.md           |
| "Get next patent for claim analysis"       | references/instructions/get-next-claim-analysis-patent.md   |
| "Get elements for patent..."               | references/instructions/get-elements.md                     |
| "Get list of patents with elements but..." | references/instructions/get-patents-without-similarities.md |
| "Count patents without similarities"       | references/instructions/get-patents-without-similarities.md |
| "Count screening progress"                 | references/instructions/get-screening-statistics.md         |
| "Count claim analysis progress"            | references/instructions/get-claim-analysis-statistics.md    |
| "Count patents without prior arts"         | references/instructions/get-patents-without-prior-arts.md   |
| "Count prior art progress"                 | references/instructions/get-prior-art-statistics.md         |
| "Search features"                          | references/instructions/get-features.md                     |
| "Search feature: <feature_name>"           | references/instructions/search-feature.md                   |

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

### Workflow 3: Get Next Patent for Claim Analysis

1. External: "Get next patent for claim analysis"
2. Internal: Execute get-next-claim-analysis-patent.md → Return single patent_id

This is a file-based operation (not SQL):

```bash
find 3-investigations -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
  patent_id=$(basename "$dir")
  if [ -f "$dir/evaluation.md" ] && [ ! -f "$dir/claim-analysis.md" ]; then
    echo "$patent_id"
    exit 0
  fi
done
```

### Workflow 4: Get Elements for Patent

1. External: "Get elements for patent <patent-id>"
2. Internal: Execute get-elements.md → Return array of elements

Query:

```sql
SELECT
  claim_number,
  element_label,
  element_description
FROM elements
WHERE patent_id = '<patent_id>'
ORDER BY claim_number, element_label;
```

### Workflow 5: Get Patents Without Similarities

1. External: "Get list of patents with elements but no similarities"
2. Internal: Execute get-patents-without-similarities.md → Return array of patent_ids

Query:

```sql
SELECT DISTINCT e.patent_id
FROM elements e
LEFT JOIN similarities s ON e.patent_id = s.patent_id
  AND e.claim_number = s.claim_number
  AND e.element_label = s.element_label
WHERE s.patent_id IS NULL;
```

### Workflow 6: Search Features

1. External: "Search features"
2. Internal: Execute get-features.md → Return array of features

Query:

```sql
SELECT
  feature_name,
  description,
  category,
  presence
FROM features
ORDER BY feature_id;
```

### Workflow 7: Search Feature

1. External: "Search feature: <feature_name>"
2. Internal: Execute search-feature.md → Return single feature or empty array

Query:

```sql
SELECT
  feature_name,
  description,
  category,
  presence
FROM features
WHERE feature_name = '<feature_name>';
```

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
  - `get-next-claim-analysis-patent.md`: Get next patent for claim analysis
  - `get-elements.md`: Get elements for a specific patent
  - `get-patents-without-similarities.md`: Get list of patents with elements but no similarities
  - `get-features.md`: Get all product features
  - `get-screening-statistics.md`: Get screening progress counts
  - `get-claim-analysis-statistics.md`: Get claim analysis progress counts
  - `get-prior-art-statistics.md`: Get prior art research progress counts
  - `search-feature.md`: Search for a specific feature by name
- \*\*references/schema.md`: Database schema documentation

**IMPORTANT**: External agents should invoke this skill via the Skill tool, not
access these internal files directly.
