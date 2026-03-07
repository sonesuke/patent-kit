---
name: screening
description: |
  Screens collected patents by legal status and relevance.

  Triggered when:
  - The user asks to:
    * "screen the patents"
    * "remove noise"
  - `patents.db` exists with `target_patents` table populated
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 2: Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for Evaluation phase.

## Prerequisites

- `patents.db` must exist (generated in Phase 1 Targeting, `target_patents` table)
- `0-specifications/specification.md` must exist (Product/Theme definition)
- Constitution-reminding skill must be loaded
- Legal-checking skill must be loaded

## Skill Orchestration

### 1. Load Required Skills (MANDATORY)

Use the Skill tool to load skills BEFORE starting any work:

1. **Constitution**: `constitution-reminding` - Understand core principles
2. **Legal Checker**: `legal-checking` - Legal compliance guidelines

### 2. Execute Screening

Follow the detailed screening process in `references/instructions.md`.

## State Management

### Initial State

- `patents.db` exists with `target_patents` table populated
- No `screened_patents` entries (or partial screening in progress)

### Final State

- All patents in `target_patents` have corresponding entries in `screened_patents`

## References

- `references/instructions.md` - Detailed screening process instructions
- `references/examples.md` - Usage examples and judgment examples
- `references/troubleshooting.md` - Common issues and solutions
- `assets/templates/screening-template.md` - Output template for screening results
