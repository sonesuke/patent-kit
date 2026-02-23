---
name: targeting
description: "Searches patent databases to create a target population based on specifications. Triggered when the user asks to 'create a target population' or 'run the search (Step 1)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 1: Targeting

## Purpose

Generate high-precision search queries and create a consolidated patent population for screening.

## Prerequisites

- `0-specifications/specification.md` must exist (generated in Phase 0)
- Constitution skill must be loaded

## Skill Orchestration

### 1. Load Constitution (MANDATORY)

Use the Skill tool to load the `constitution` skill BEFORE starting any work. This is required to understand the core principles.

### 2. Check Specification

Use the Glob tool to check if `0-specifications/specification.md` exists:

- **If exists**: Proceed to targeting execution
- **If NOT exists**:
  1. Use the Skill tool to load the `concept-interviewing` skill to create the specification
  2. Wait for the concept-interviewing to complete
  3. Verify that `0-specifications/specification.md` has been created
  4. Only proceed after the specification file exists

### 3. Execute Targeting

**First, check if CSV files already exist:**

Use the Glob tool to check if `1-targeting/csv/*.csv` files exist:

- **If CSV files exist**:
  1. Skip the patent search and keyword extraction steps (Step 1 & 2 from instructions)
  2. Immediately proceed to merge step (Step 3)
  3. Run the merge script:
     ```bash
     ./plugin/skills/targeting/scripts/shell/merge.sh 1-targeting/csv 1-targeting/target.jsonl
     ```
  4. Verify `1-targeting/target.jsonl` was created successfully
  5. Skip to completion

- **If NO CSV files**: See `references/instructions.md` for detailed execution steps.

### 4. Transition to Screening

Upon successful completion:

- Deliverables: `1-targeting/targeting.md`, `1-targeting/keywords.md`, `1-targeting/target.jsonl`
- Next skill: `/patent-kit:screening`

## State Management

### Initial State

- `0-specifications/specification.md` exists
- No `1-targeting/` directory (or empty)

### Final State

- `1-targeting/targeting.md` created with validated search commands
- `1-targeting/keywords.md` created with golden keywords registry
- `1-targeting/target.jsonl` created with merged patent list
- Ready to proceed to screening phase

## References

- `references/instructions.md` - Detailed targeting process instructions
- `references/examples.md` - Usage examples
- `references/troubleshooting.md` - Common issues and solutions
- `assets/templates/targeting-template.md` - Output template for targeting results
- `assets/templates/keywords-template.md` - Output template for keywords registry
