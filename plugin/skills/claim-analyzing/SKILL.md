---
name: claim-analyzing
description: |
  Performs claim analysis by comparing product specification against patent evaluation results.

  Triggered when:
  - The user asks to:
    * "perform claim analysis"
    * "analyze claim elements"
  - `3-investigations/<patent-id>/evaluation.md` exists for patents
metadata:
  author: sonesuke
  version: 1.0.0
---

# Claim Analysis

## Purpose

Perform detailed claim analysis by comparing product specification against patent evaluation results, generating claim analysis reports for each patent.

## Prerequisites

- `specification.md` must exist with complete product information
- `3-investigations/<patent-id>/evaluation.md` must exist for patents to analyze
- Load `legal-checking` skill for legal compliance guidelines

## Constitution

### Core Principles

**Element-by-Element Analysis (The Golden Rule)**:

- Every claim analysis MUST test the target product against the patent elements element by element
- Break down inventions into Elements A, B, C
- Find references disclosing A AND B AND C for anticipation (Novelty)
- Do not rely on "general similarity"

**No Legal Assertions**:

- Use descriptive technical language only
- Avoid legal conclusions like "infringes" or "does not infringe"
- Focus on feature comparison and technical overlap

## Skill Orchestration

### Execute Claim Analysis

**CRITICAL**: Always use subagents for claim analysis. **EVEN FOR A SINGLE PATENT - always launch a subagent.**

**Process**:

1. **Get Patents to Analyze**:
   - Find patents with `evaluation.md` but no `claim-analysis.md`
   - If user provides patent ID, verify `evaluation.md` exists
   - If `evaluation.md` does not exist, notify user and wait for confirmation

2. **Analyze Patents**: Launch `claim-analyzer` subagents

   For each patent:
   - Start a `claim-analyzer` subagent
   - **Each subagent handles exactly one patent**
   - **CRITICAL: Even if there is only ONE patent, you MUST still use a subagent**

3. **Verify Results**: Confirm `claim-analysis.md` files were created

## State Management

### Initial State

- Patents with `evaluation.md` but no `claim-analysis.md` exist

### Final State

- No patents with `evaluation.md` without corresponding `claim-analysis.md` (all analyzed)
