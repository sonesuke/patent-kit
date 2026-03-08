---
name: evaluating
description: "Generates a detailed evaluation report for a screened patent. Triggered when the user asks to 'evaluate the patent' or 'analyze claim elements (Step 3)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 3: Evaluation

Your task is to Analyze the Patent and create the Specification.

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
