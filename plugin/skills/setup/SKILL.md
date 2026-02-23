---
name: setup
description: "Initializes the required directory structure for patent analysis. Triggered when the user asks to 'initialize the project' or 'create directories'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Patent Kit Setup

## Purpose

Prepare the working directory for a new patent analysis project by creating the required directory structure.

## Skill Orchestration

### 1. Detect Operating System

Identify whether the user is on:
- Linux/Mac (Bash/Zsh)
- Windows (PowerShell)

### 2. Create Directories

Execute the appropriate command (see `references/instructions.md` for detailed commands).

### 3. Verify and Inform

Confirm directories are created and inform the user of next steps.

## State Management

### Initial State

- Working directory may not have required patent analysis folders

### Final State

- `0-specifications/` directory created
- `1-targeting/csv/` directory created
- `1-targeting/json/` directory created
- `2-screening/json/` directory created
- `3-investigations/` directory created
- Workspace ready for patent analysis

## Next Steps

Upon completion, user can proceed to:
- `/patent-kit:concept-interview` - Define product concept and identify competitors
- `/patent-kit:targeting` - Start patent search (if specification already exists)

## References

- `references/instructions.md` - Detailed directory creation commands
- `references/examples.md` - Usage examples
- `references/troubleshooting.md` - Common issues and solutions
