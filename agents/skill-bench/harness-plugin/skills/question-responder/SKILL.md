---
name: question-responder
description: "Find answers to common questions from project context before asking the user. Always use this skill when you need information like competitors, target country, or release date."
metadata:
  author: sonesuke
  version: 0.1.0
---

# Question Responder

## Purpose

Before asking the user questions, check if answers can be found in project context.

## When to Use

Use this skill whenever you need to ask the user a question. First check if the answer exists in:

- Project documentation
- Test data files
- Configuration files

## Process

1. **Get Test Case Path**: Read the `SKILL_BENCH_TEST_CASE` environment variable to get the current test case file path

2. **Read Test Case**: Use the Read tool to read the test case TOML file from the path

3. **Find Answers**: Look for `[answers]` section in the test case file
   - This section contains keyword-answer pairs

4. **Match Question**: Check if the input question contains keywords from the `[answers]` keys
   - For example, if the question is "Who are the competitors?", look for keys like "competitors"
   - Use substring or keyword matching

5. **Return Result**:
   - **If answer found**: Return the answer value from the matched key
   - **If not found**: Return "ANSWER_NOT_FOUND" to indicate user input is needed

## Implementation Notes

- The test case path is provided via `SKILL_BENCH_TEST_CASE` environment variable
- Access environment variables using the Bash tool: `echo $SKILL_BENCH_TEST_CASE`
- Match questions using flexible keyword matching (e.g., "competitors" matches "Who are the competitors?")
- Since this skill runs in `context: fork`, the main agent won't see the test case answers directly

## Test Case Format

Answers are embedded directly in the test case TOML file using the `[answers]` section:

```toml
# Test Case: Concept Interview - Uses Question Responder
name = "uses-question-responder"
description = "Verify concept-interview uses question-responder when information is missing"
timeout = 180

test_prompt = """
I want to start a patent search for a new voice recognition system...
"""

[answers]
"competitors" = ["Google", "Amazon"]
"target country" = "US"
"release date" = "2025-06-01"
"country" = "US"
"date" = "2025-06-01"
```

The `[answers]` section contains keyword-value pairs that match common questions.

## Context Isolation

This skill uses `context: fork` to run in an isolated sub-agent context. This ensures:

- The main AI agent doesn't see the answer files
- Test integrity is maintained
- Answers are only revealed when explicitly requested

## Usage Example

```yaml
# Instead of:
AskUserQuestion:
  questions:
    - question: "What is the target country?"

# Use:
Skill:
  skill: question-responder
  args: "What is the target country for patent search?"
```
