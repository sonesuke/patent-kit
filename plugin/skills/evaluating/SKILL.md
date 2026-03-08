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

## Quick Start

1. **Load Required Skills**: Load `constitution-reminding` skill
2. **Read Specification**: Read `0-specifications/specification.md` to understand Theme, Domain, and Target Product
3. **Select Patent ID**: Use `investigating-database` skill to get next relevant patent without evaluation
4. **Analyze Patent**:
   - Fetch patent details using `google-patent-cli:patent-fetch`
   - Decompose claims into elements and identify key features
   - See `references/instructions/analyze-patent.md` for detailed instructions
5. **Generate Report**: Create evaluation report using template
   - See `references/instructions/generate-report.md` for detailed instructions

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
