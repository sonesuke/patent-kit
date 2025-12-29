---
description: "Generate Query"
---

# Generate Query

Your task is to generate composite search queries based on the selections made in `prescreening.md`. You will create two patterns of commands: one with competitor filters and one without (general), both including time and country constraints.

## Input

- `screening/prescreening.md`: Read this file to get the selected Scope and Context.

## Process

1. **Extract Context Data**:

- Read `Target Country`.
- Read `Target Release Date` (Use this as the **Before** date).
- Read `Priority Date Cutoff` (Use this as the **After** date).
- Read `Verified Assignee Names`.

1. **Extract Selected Queries**:

- Look at the "Search Strategy & Pre-Search Log" table in `prescreening.md`.
- Identify rows where the Status is **"Selected"**.
- For each selected row, extract the `--query` value (the keywords).

1. **Generate Composite Commands**:

- **Analyze Query Intent**: Review selected queries to identify:
- Core concepts (e.g., CRM, SFA)
- Modifiers (e.g., AI, 人工知能)
- Logical relationships between terms
- **Optimize Logical Structure**:  
- Group related terms with OR
- Combine concept groups with AND when appropriate
- Ensure the query reflects the product's core functionality
- **Example**: Instead of `(CRM) OR (AI CRM) OR (SFA AI)`, use `((CRM OR SFA) AND AI)` to find patents that combine both concepts.
- **Combine Assignees**:  
- Collect all Verified Assignee Names.
- **Sanitize**: Remove commas within individual names (e.g., "Google, LLC" -> "Google LLC").
- Join sanitized names with `,` (comma).

### Pattern 1: Competitor Filtered

- **Goal**: Find specific prior art from known competitors within the relevant timeframe.
- **Construction**:
- Base: The **Combined Keywords**.
- Filter: Add `--assignee` (The **Combined Assignees**).
- Filter: Add `--country` (Target Country).
- Filter: Add `--before` (Target Release Date).
- Filter: Add `--after` (Priority Date Cutoff).
- **Format**: `google-patent-cli search --query "<Combined Keywords>" --assignee "<Combined Assignees>" --country "<Target Country>" --before "<Target Release Date>" --after "<Priority Date Cutoff>"`

### Pattern 2: General Filtered (No Competitor Filter)

- **Goal**: Find general prior art / infringement risks from the wider industry.
- **Construction**:
- Base: The **Combined Keywords**.
- **Exclude**: Do NOT use `--assignee`.
- Filter: Add `--country` (Target Country).
- Filter: Add `--before` (Target Release Date).
- Filter: Add `--after` (Priority Date Cutoff).
- **Format**: `google-patent-cli search --query "<Combined Keywords>" --country "<Target Country>" --before "<Target Release Date>" --after "<Priority Date Cutoff>"`

1. **Validate & Adjust**:

- **Execute**: Run the generated commands with `--limit 20` to inspect actual results.
- **Analyze Noise**: Check the top 20 results.
- Are there irrelevant patents?
- **Why** did they hit? (e.g., specific keyword used in a different context).
- **Abbreviation Check**: Does an abbreviation match a completely different term in another field? (Common source of noise).
- **Adjust**:
- **Action**:  
- If **Abbreviation** is the cause: Replace with **Full Term** or add a domain constraint.
- If other noise: Add constraints to exclude that context (e.g., `NOT` or refine `AND`).
- **Check Volume**: Is the total count > 1000?
- **Goal**: Tune until the count is **under 1000** (ideal: 100-500) to ensure high relevance and manageable volume.
- **Action (Iterative Tuning)**:
- If > 1000: **Narrow the scope**.
- Add specific feature keywords (AND).
- Use date ranges more strictly if applicable.
- Exclude broad terms if they are causing noise.
- **Repeat**: Re-run with `--limit 1` to check the count. Repeat until < 1000.
- **Analyze Noise (Top 20)**: Once count is reasonable, check the top 20 results (as above).
  - **Re-run**: Verify the relevance improves.
- **Log**: Record the initial count/relevance, noise analysis, adjustments, and final status.

## Output

- Create a file `screening/query.md` using the template `.patent-kit/templates/query-template.md`.
- Fill in the generated commands.
- Fill in the **Validation & Adjustment Log** with the details of your checks.

Example Output `screening/query.md`:

```markdown
# Generated Search Commands

## Pattern 1: Competitor Filtered
`google-patent-cli search --query "((Antigravity OR Levitation) AND Magnet)" --assignee "Google LLC, Tesla Inc" --country "US" --before "2025-01-01" --after "2005-01-01"`

## Pattern 2: General Filtered
`google-patent-cli search --query "((Antigravity OR Levitation) AND Magnet)" --country "US" --before "2025-01-01" --after "2005-01-01"`
```
