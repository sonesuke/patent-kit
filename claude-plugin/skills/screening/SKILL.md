---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `target_patents` table populated (will be prepared by this skill if missing)
---

# Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for evaluation skill.

## Prerequisites

- `patents.db` will be initialized automatically by patent-kit MCP tools
- `specification.md` must exist (Product/Theme definition)

## Constitution

### Core Principles

**Risk-Averse Screening**:

- When in doubt, err on the side of inclusion
- If a reference is "borderline", mark it as 'relevant' rather than 'irrelevant'
- Missing a risk is worse than reviewing an extra document

**No Shortcut Judgment**:

- You MUST fetch each patent and read the abstract before making a judgment
- Do NOT judge relevance based on title alone — titles can be misleading or too generic
- Do NOT skip fetching patents to speed up processing
- Every patent must go through the full fetch → read abstract → judge → record flow

## Skill Orchestration

### 1. Ensure Database is Ready

**CRITICAL**: Before attempting any screening, ensure the database exists and is populated.

1. **Use the Glob tool to check if `csv/*.csv` files exist**
2. **If CSV files exist**: Use the `import_csv` MCP tool to import them:
   ```
   import_csv({ file_path: "csv/<filename>.csv" })
   ```
3. **Verify**: Use the `get_unscreened` MCP tool to confirm patents are available

### 2. Execute Screening

**Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session.

**Process**:

1. **Get Patents to Screen**:
   - Use the `get_unscreened` MCP tool:
     ```
     get_unscreened({ limit: 10 })
     ```

2. **Read Specification** (once):
   - Read `specification.md` to understand Theme, Domain, and Target Product

3. **Batch Fetch Patent Data** (up to 10 patents in parallel):
   - Split unscreened patents into batches of 10
   - For each batch, use the `search_patents` MCP tool with `patent_number` to fetch details

4. **Evaluate and Record** (for each patent):

   Judgment criteria (relevance only):
   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Judgment values: `relevant`, `irrelevant`

   Use the `screen_patent` MCP tool to record the result:

   ```
   screen_patent({
     patent_id: "<patent_id>",
     judgment: "<relevant|irrelevant>",
     reason: "<LLM-generated reason>",
     abstract_text: "<abstract from fetch result>"
   })
   ```

5. **Verify Results**: Use `get_progress` MCP tool to confirm all patents have been screened

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
