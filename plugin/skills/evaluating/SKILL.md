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

## Quick Start

1. **Load Required Skills**: Load `constitution-reminding` and `legal-checking` skills
2. **Get Patent ID**: If not provided, query database for next relevant patent
3. **Fetch Patent Data**: Use `google-patent-cli:patent-fetch` to get patent details
4. **Analyze Claims**: Decompose claims into elements and identify key features
5. **Generate Report**: Create evaluation report using template

For detailed instructions, see `references/instructions.md`.

## Template

- **Evaluation Template**: `assets/evaluation-template.md`
- **Output**: `3-investigations/<patent-id>/evaluation.md`

## Examples

- See `references/examples.md` for detailed usage examples

## Troubleshooting

- See `references/troubleshooting.md` for common issues and solutions
