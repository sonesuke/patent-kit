---
name: concept-interviewing
description: |
  Conducts an interview to define the product concept and identify competitors.

  Triggered when:
  - The user wants to start a patent investigation for a new product, idea, or concept
    (e.g., "start a patent search for a new product", "patent investigation for a new idea")
  - The user explicitly requests:
    * "conduct concept interview"
    * "define product concept"
    * "define search requirements"
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

### 2. Load Required Skills

Use the Skill tool to verify that the following skills are available:

- `google-patent-cli:patent-assignee-check` - For discovering assignee name variations

### 3. Check Existing Specification

Use the Glob tool to check if `0-specifications/specification.md` exists:

- **If exists**:
  - Read the existing specification
  - Check if "Verified Assignee Names" table contains proper assignee name variations
  - **If assignee names are listed** with variations: Verification already complete - skip assignee checks
  - **If assignee names are missing** or incomplete: Perform assignee verification using `google-patent-cli:patent-assignee-check`

- **If NOT exists**: Proceed with concept interview

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
