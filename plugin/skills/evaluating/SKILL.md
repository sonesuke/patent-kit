---
name: evaluating
description: "Generates a detailed evaluation report for a screened patent. Triggered when the user asks to 'evaluate the patent' or 'analyze claim elements (Step 3)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 3: Evaluation

## Purpose

Generate a detailed evaluation report for a screened patent by analyzing claim elements, legal status, and creating investigation specifications for prior art search.

## Prerequisites

- `patents.db` must exist with `screened_patents` table populated (from Phase 2 Screening)
- `0-specifications/specification.md` must exist (Product/Theme definition from Phase 0)
- Load `constitution-reminding` skill before starting analysis
- Load `investigating-database` skill for database operations
- `google-patent-cli:patent-fetch` skill available for retrieving patent data

## Process

The evaluation process consists of the following steps:

| Step | Description       | Instruction File                             |
| ---- | ----------------- | -------------------------------------------- |
| 0    | Select Patent ID  | Use `investigating-database` skill           |
| 1    | Patent Analysis   | `references/instructions/analyze-patent.md`  |
| 2    | Report Generation | `references/instructions/generate-report.md` |

## Skill Orchestration

### 1. Load Required Skills (MANDATORY)

Use the Skill tool to load skills BEFORE starting any work:

1. **Constitution**: `constitution-reminding` - Understand core principles
2. **Read Specification**: Read `0-specifications/specification.md` to understand Theme, Domain, and Target Product

### 2. Execute Evaluation

Follow the detailed evaluation process:

- **Step 1**: See `references/instructions/analyze-patent.md` for patent analysis
- **Step 2**: See `references/instructions/generate-report.md` for report generation

## State Management

### Initial State

- `patents.db` exists with `screened_patents` table populated (from Phase 2 Screening)
- `0-specifications/specification.md` exists (Product/Theme definition)
- No evaluation reports in `3-investigations/` directory (or partial evaluation in progress)

### Final State

- Evaluation reports generated for relevant patents in `3-investigations/<patent-id>/evaluation.md`
- Claims and elements stored in database (`claims` and `elements` tables)

## Template

- **Evaluation Template**: `assets/evaluation-template.md`
- **Output**: `3-investigations/<patent-id>/evaluation.md`

## Examples

- See `references/examples.md` for detailed usage examples

## References

See `references/` directory for:

- **instructions/**: Step-based documentation
  - `analyze-patent.md`: Patent analysis and claim decomposition (includes skill loading)
  - `generate-report.md`: Report generation and output
- **examples.md**: Usage examples and detailed workflows
- **troubleshooting.md**: Common issues and solutions
- **assets/**: Templates and output formats
  - `evaluation-template.md`: Template for evaluation reports
