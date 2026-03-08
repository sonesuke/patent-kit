# Step 1: Patent Analysis

Analyze patents to extract key information for evaluation.

## Process Overview

### Database Integration

Use the Skill tool to load the appropriate database skills:

- **For data retrieval**: Use `investigation-fetching` skill
  - Getting next patent IDs (relevant but not yet evaluated)
  - Getting progress statistics

### Automated Patent Analysis

Process all relevant patents from the `screened_patents` table.

> [!NOTE]
> **Subagent-Based Evaluation**:
>
> - Always use `patent-evaluator` subagents for patent evaluation
> - Launch one subagent per patent
> - Each subagent handles exactly one patent independently
> - Subagents must use `investigation-recording` skill, never write raw SQL

**Process Steps**:

1. **Get Patents to Analyze**:
   - Use `investigation-fetching` skill
   - Request: "Get list of relevant patents without evaluation"

2. **Analyze Patents**: Launch `patent-evaluator` subagents

   For each patent:
   - Start a `patent-evaluator` subagent
   - **Each subagent handles exactly one patent**

## Output

- `patents.db` (claims table): Patent claims with types and text
- `patents.db` (elements table): Constituent elements of claims with labels and descriptions
