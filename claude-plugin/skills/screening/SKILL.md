---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `patents` table populated (will be prepared by this skill if missing)
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

- You MUST read each patent's abstract before making a judgment
- Do NOT judge relevance based on title alone — titles can be misleading or too generic
- Every patent must go through the read abstract → judge → record flow

## Skill Orchestration

> [!IMPORTANT]
> When instructed to call an MCP tool, call it directly using the tool name. **NEVER** use Bash to invoke MCP tools — the MCP server is already connected and tools are available directly. Do NOT construct JSON-RPC messages or use `echo | patent-kit mcp`.

### 1. Read Specification

Read `specification.md` to understand Theme, Domain, and Target Product.

### 2. Screen Patents

**Do NOT delegate to subagents (Agent tool)** — invoke MCP tools directly from this session.

**Loop**:

1. **Call `get_unscreened`**:
   - If it says "Indexing in progress" → Wait briefly, then call `get_unscreened` again
   - If it says "N patents need indexing" → Call `index_patents`, then call `get_unscreened` again
   - If it says "All patents have been screened." → Screening is complete
   - Otherwise → Returns a batch of patents with ID, title, assignee, and abstract

2. **Evaluate and Record** (for each patent in the batch):

   Judgment criteria (relevance only):
   - **Irrelevant**: Completely different industry from Theme/Domain
   - **Relevant**: Matches Theme/Domain, Direct Competitors, Core Tech
   - **Exception**: Even if domain differs, KEEP if technology could serve as infrastructure or common platform

   Judgment values: `relevant`, `irrelevant`

   Call the `screen_patent` MCP tool directly (do NOT use Bash or Skill):
   - `patent_id`: "<patent_id>"
   - `judgment`: "<relevant|irrelevant>"
   - `reason`: "<LLM-generated reason>"

3. **Repeat** from step 1 until `get_unscreened` says "All patents have been screened."

## State Management

### Initial State

- Patents in `patents` table without corresponding `screened_patents` entries exist

### Final State

- No patents in `patents` without corresponding `screened_patents` entries (all screened)
