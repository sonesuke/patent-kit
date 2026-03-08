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

# Screening

## Purpose

Filter collected patents by legal status and relevance to prepare for evaluation skill.

## Prerequisites

- `patents.db` must exist (generated in targeting skill, `target_patents` table)
- `specification.md` must exist (Product/Theme definition)
- Legal-checking skill must be loaded

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target invention against the reference patent element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**Risk-Averse Screening**:

- When in doubt, err on the side of inclusion
- If a reference is "borderline", grade it as 'B' (Relevant) rather than 'D' (Noise)
- Missing a risk is worse than reviewing an extra document

**Breadth of Published Applications**:

- For published applications (not yet granted), consider "Detailed Description" and embodiments
- Don't judge solely based on current claims

## Skill Orchestration

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
- `assets/screening-template.md` - Output template for screening results
