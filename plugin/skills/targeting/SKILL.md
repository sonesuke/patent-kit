---
name: targeting
description: |
  Searches patent databases to create a target population based on specifications.

  Triggered when:
  - The user asks to:
    * "create a target population"
    * "determine the target population"
    * "run the patent search"
metadata:
  author: sonesuke
  version: 1.0.0
---

# Targeting

## Purpose

Generate high-precision search queries and create a consolidated patent population for screening.

## Prerequisites

- `specification.md` must exist (generated in concept-interviewing skill)

## Constitution

### Core Principles

**Search Query Optimization**:

- Start with broad, essential keywords (2-4 terms maximum)
- If zero results, progressively simplify:
  1. Remove technical modifiers and adjectives
  2. Break compound concepts into separate searches
  3. Try synonyms or broader terms
- Document query evolution in reports

## Skill Orchestration

### 1. Check Specification

Use the Glob tool to check if `specification.md` exists:

- **If exists**: Proceed to targeting execution
- **If NOT exists**:
  1. Use the Skill tool to load the `concept-interviewing` skill to create the specification
  2. Wait for the concept-interviewing to complete
  3. Verify that `specification.md` has been created
  4. Only proceed after the specification file exists

### 2. Execute Targeting

**CRITICAL: Always use the Skill tool to load google-patent-cli skills for patent searches.**

1. **Execute Competitor Patent Research**:
   - Use `google-patent-cli:patent-search` skill with assignee search
   - Analyze results and extract "Golden Keywords"
   - Save keywords to `keywords.md`
2. **Execute Market Patent Research**:
   - Use `google-patent-cli:patent-search` skill with keyword queries
   - Refine queries based on noise analysis
3. **Create Output Files**:
   - Fill `targeting.md` using the template
   - Update `keywords.md` with golden keywords registry

### 3. Transition to Screening

Upon successful completion:

- Deliverables: `targeting.md`, `keywords.md`
- Next skill: `/patent-kit:screening`

## State Management

### Initial State

- `specification.md` exists
- No `targeting.md` or `keywords.md`

### Final State

- `targeting.md` created with validated search commands
- `keywords.md` created with golden keywords registry
- Ready to proceed to screening skill

## References

- `references/instructions.md` - Detailed targeting process instructions
- `assets/targeting-template.md` - Output template for targeting results
- `assets/keywords-template.md` - Output template for keywords registry
