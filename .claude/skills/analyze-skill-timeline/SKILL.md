---
name: analyze-skill-timeline
description: Analyze a skill-bench JSONL log file and output a structured timeline table showing tool calls, arguments, and durations. Use this skill whenever the user wants to review, inspect, or understand what happened during a skill-bench test run — including phrases like "ログを確認", "timelineを見て", "テストの内容を確認", "what happened in this test", or when they provide a path to a .log file from the logs/ directory. Also use when the user asks about execution time breakdown or MCP tool call patterns.
---

# Analyze Skill Timeline

Analyze a skill-bench log file and produce a structured timeline table. This helps quickly understand what a test did, how long each step took, and where time was spent.

## Input

The user provides a log file path as ARGUMENTS. The file is JSONL format produced by `skill-bench run --log`.

## Process

### 1. Get the overview with `skill-bench timeline`

Run `skill-bench timeline <log-file>` via Bash. This is the backbone of the analysis — it provides timestamps, event types, tool call summaries, and total duration.

### 2. Extract metadata

Read line 1 of the JSONL (the `type: "system"` init line). Extract:

- `model` — which model was used
- `cwd` — contains the test name
- `mcp_servers[].name` — connected MCP servers
- `skills` — loaded skills (filter out built-ins like `update-config`, `debug`, etc.)

### 3. Extract tool call details

Use jq to extract tool calls from the JSONL. jq parses JSON properly and can extract specific fields even from very long lines (unlike Grep which truncates them).

Two jq passes:

```bash
# Tool calls: timestamp, id, name, key input fields
cat <log-file> | jq -c 'select(.type == "assistant") | .timestamp as $ts | .message.content[]? | select(.type == "tool_use") | {ts: $ts, id: .id, name: .name, input: .input}'

# Tool results: timestamp, tool_use_id
cat <log-file> | jq -c 'select(.type == "user") | .timestamp as $ts | .message.content[]? | select(.type == "tool_result") | {ts: $ts, id: .tool_use_id}'
```

From the jq output, extract:

| Category | Pattern                          | What to extract                                                                         |
| -------- | -------------------------------- | --------------------------------------------------------------------------------------- |
| MCP tool | name contains `mcp__`            | Short name (last segment after `__`), key args: `query`, `assignee`, `country`, `limit` |
| Skill    | name is `"Skill"`                | `input.skill` value                                                                     |
| File I/O | Read, Write, Glob, Grep          | `input.file_path` or `input.pattern`                                                    |
| Other    | Bash, TodoWrite, AskUserQuestion | Name only                                                                               |

### 4. Calculate durations

For each tool call, match its `id` to a `tool_result`'s `tool_use_id`. Duration = result timestamp - call timestamp.

Detect simultaneous calls: if multiple tool calls share the same timestamp (within 0.01s tolerance), mark the 2nd and subsequent as "simultaneous" instead of showing a duration.

**Reasoning time**: For each gap between a tool_result and the next tool_use, calculate `next_tool_use.ts - last_tool_result.ts`. This is pure Claude reasoning time (no tool execution). If the gap is > 1s, insert a row in the timeline.

### 5. Output

Produce a markdown timeline combining `skill-bench timeline` overview with enriched details.

```
### Timeline: `<test-name>`

**Duration**: X.XXs | **Model**: `model-name` | **Skills**: `skill1, skill2`

| Time | Action | Duration |
|------|--------|----------|
| **0-1.5s** | Init | 1.5s |
| **6.3s** | `search_patents` #1: assignee=[Salesforce, HubSpot] query="chatbot" | **11.1s** |
| **27.1s** | `search_patents` #2: query=`"chatbot" "sentiment"` | — |
| **27.1s** | `search_patents` #3: query=`"chatbot" "CRM"` | simultaneous |
| **38.0s** | 🧠 Reasoning | 13.6s |
| **59.0s** | `search_patents` #5: query=`"chatbot" "sentiment analysis"` | 3.5s |
| **132.3s** | Write: targeting.md | 0.1s |

### Summary

- MCP calls: `search_patents` ×7 (19.3s), `check_assignee` ×2 (17.4s)
- Claude reasoning: 112.5s / 178.8s (63%)
```

### Formatting rules

- **Time column**: Use `**Xs**` for individual events. Group rapid sequential events if useful.
- **Bold durations** for operations > 5s — these are the bottlenecks worth investigating.
- **MCP tool names**: Use backticks with a `#N` counter per tool type (e.g., `` `search_patents` #1 ``).
- **Parameters**: Show key args concisely. Truncate `assignee` arrays to first 2 items + `...`. Truncate file paths to the last 2 segments.
- **Simultaneous calls**: If N > 1 calls share the same timestamp, mark 2nd+ as "simultaneous". Note that the MCP server processes requests sequentially (rmcp JSON-RPC is one-at-a-time), so even "simultaneous" calls complete one after another. The duration column for the first call in the group reflects this.
- **Summary**: Show both MCP time and Claude reasoning time with their percentages of total duration.
- **Reasoning rows**: Use 🧠 icon. Show for gaps > 1s between tool_result and next tool_use. Calculate from the last tool_result in a group (even for simultaneous calls, use the final result).
- Keep the table focused on MCP calls and file operations. Skip noise like TodoWrite unless the user seems interested.
