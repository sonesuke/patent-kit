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
  - **Error**: Notify the user that specification.md is required
  - **Action**: Ask the user to run `/patent-kit:concept-interviewing` first to create the specification
  - **Do NOT proceed** until specification.md exists

### 3. Execute Targeting

See `references/instructions.md` for detailed execution steps.

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
