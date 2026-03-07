---
name: performance-analyzer
description: |
  Analyzes skill-bench test logs to extract performance timelines and identify bottlenecks.

  Use when:
  - User asks to "analyze performance", "check timing", "extract timeline"
  - User wants to understand where time is spent in skill-bench tests
  - User provides a skill-bench log file path

  Context: Development tool for patent-kit skill optimization
metadata:
  author: sonesuke
  version: 1.0.0
---

# Performance Analyzer

Analyzes skill-bench test logs to extract performance timelines and identify bottlenecks.

## Purpose

Extract detailed timeline information from skill-bench log files to understand:
- When each operation occurred
- How long each phase took
- Where time is being spent
- What operations are potential bottlenecks

## Usage

Provide the log file path:

```
Analyze the performance of /workspaces/patent-kit/agents/skill-bench/logs/screening/20260307_221408_functional-parallel-screening.log
```

## Output Format

The analyzer produces a timeline showing:

```
T+   2.50s | assistant | I'll help you import all CSV files...
T+   4.84s | TOOL      | Read
T+   8.23s | assistant | I found two CSV files...
T+  11.91s | TOOL      | Bash (head ...)
```

Each entry shows:
- **Elapsed time** (T+X.XXs): Time since test start
- **Actor**: (assistant, user, TOOL)
- **Content**: Brief description of the operation

## Analysis Phases

The analyzer identifies these phases:

1. **Initialization Phase** (T+0s to ~10s)
   - Skill loading
   - File system exploration
   - Initial planning

2. **Data Processing Phase** (~10s to ~50s)
   - CSV file reading
   - Database operations
   - ETL processing

3. **Completion Phase** (~50s to end)
   - Result verification
   - Final reporting

## Bottleneck Identification

The analyzer highlights:
- **File operations** taking > 1 second
- **Glob/find** operations (file searching)
- **Large file reads** (> 10000 tokens)
- **SQL operations** with duration
- **Periods of inactivity** > 5 seconds

## Example

```
Analyze /workspaces/patent-kit/agents/skill-bench/logs/investigating-database/20260307_222447_functional-import-multiple-csvs.log
```

Output:
- Timeline of all operations
- Total execution time
- Identified bottlenecks
- Optimization suggestions
