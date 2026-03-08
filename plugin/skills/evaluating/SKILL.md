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
- `patent-kit:investigating-database` skill available for querying next patent
- `constitution-reminding` skill must be loaded
- `legal-checking` skill must be loaded
- `google-patent-cli:patent-fetch` skill available for retrieving patent data

## Process

The evaluation process consists of the following steps:

| Step | Description       | Instruction File                             |
| ---- | ----------------- | -------------------------------------------- |
| 0    | Select Patent ID  | Use `investigating-database` skill           |
| 1    | Patent Analysis   | `references/instructions/analyze-patent.md`  |
| 2    | Report Generation | `references/instructions/generate-report.md` |

## Quick Start

1. **Select Patent ID**: Use `investigating-database` skill to get next relevant patent without evaluation
2. **Load Required Skills**: Load `constitution-reminding` and `legal-checking` skills
3. **Analyze Patent**:
   - Fetch patent details using `google-patent-cli:patent-fetch`
   - Decompose claims into elements and identify key features
4. **Generate Report**: Create evaluation report using template

For detailed instructions, see `references/instructions.md`.

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
