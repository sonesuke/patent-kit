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

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

### 1. Ensure Database is Ready

**CRITICAL**: Before attempting any screening, ensure the database exists and is populated.

1. **Use the Glob tool to check if `csv/*.csv` files exist**
2. **If CSV files exist**: Call the `import_csv` MCP tool directly (do NOT use Bash or Skill):
   - `file_path`: "csv/<filename>.csv"
3. **Verify**: Call the `get_unscreened` MCP tool to confirm patents are available

### 2. Execute Screening

**Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session.

**Process**:

1. **Get Patents to Screen**:
   - Call the `get_unscreened` MCP tool directly (do NOT use Bash or Skill):
     - `limit`: 10

2. **Read Specification** (once):
   - Read `specification.md` to understand Theme, Domain, and Target Product

3. **Batch Fetch Patent Data** (up to 10 patents in parallel):
   - Split unscreened patents into batches of 10
   - For each batch, call the `search_patents` MCP tool with `patent_number` to fetch details (do NOT use Bash or Skill)

4. **Evaluate and Record** (for each patent):

   Judgment criteria (relevance only):
   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Judgment values: `relevant`, `irrelevant`

   Call the `screen_patent` MCP tool directly (do NOT use Bash or Skill):
   - `patent_id`: "<patent_id>"
   - `judgment`: "<relevant|irrelevant>"
   - `reason`: "<LLM-generated reason>"
   - `abstract_text`: "<abstract from fetch result>"

5. **Verify Results**: Call the `get_progress` MCP tool to confirm all patents have been screened

## State Management

### Initial State

- Patents in `target_patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `target_patents` without corresponding `screened_patents` entries (all screened)
