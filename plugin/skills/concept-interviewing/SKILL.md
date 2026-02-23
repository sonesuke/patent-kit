---
name: concept-interviewing
description: "Conducts an interview to define the product concept and identify competitors. Triggered when the user says 'I want to start a patent search' or 'Define search requirements (Step 0)'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Phase 0: Concept Interview

## Purpose

Define the product concept and identify competitors. This phase establishes the foundation for patent targeting.

## Prerequisites

- Constitution skill must be loaded

## Skill Orchestration

### 1. Load Constitution (MANDATORY)

Use the Skill tool to load the `constitution-reminding` skill BEFORE starting any work. This is required to understand the core principles.

### 2. Check Existing Specification

Use the Glob tool to check if `0-specifications/specification.md` exists:

- **If exists**: Skip the interview and use existing specification as the source of truth.
- **If NOT exists**: Proceed with concept interview.

### 3. Execute Concept Interview

See `references/instructions.md` for detailed execution steps including:

- Information gathering (product concept, target country, release date, competitors)
- Assignee name verification

### 4. Transition to Targeting

Upon successful completion:

- Deliverable: `0-specifications/specification.md` created with verified assignee names
- Next skill: `/patent-kit:targeting`

## Output Management

- **Output File**: `0-specifications/specification.md`
- **Template**: Use `assets/templates/specification-template.md`
- **Format**: Markdown (not JSON)
- **Note**: This file is referenced by all subsequent phases (targeting, screening, evaluating, claim-analyzing)

## State Management

### Initial State

- No `0-specifications/specification.md` (proceed with interview)
- OR `0-specifications/specification.md` exists (skip to verification/confirmation)

### Final State

- `0-specifications/specification.md` created with:
  - Product concept clearly defined
  - Target country and release date specified
  - All competitors' assignee names verified
  - Complete information saved

## References

- `references/instructions.md` - Detailed concept interview process
- `references/examples.md` - Usage examples
- `references/troubleshooting.md` - Common issues and solutions
- `assets/templates/specification-template.md` - Output template for specification
