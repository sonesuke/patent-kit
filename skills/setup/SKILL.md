---
name: setup
description: "Initializes the required directory structure for patent analysis"
---

# Patent Kit Setup

Your task is to prepare the working directory for a new patent analysis project.

## Instructions

Run the following commands to create the necessary directories.
These directories are ignored by git (via `.gitignore`) or tracked via `.gitkeep`, and are required to store outputs during the analysis process.

### Step 1: Create Directories

Execute this shell command to create the folder structure:

```bash
mkdir -p 0-specifications \
         1-targeting/csv \
         1-targeting/json \
         2-screening/json \
         3-investigations
```

### Step 2: Confirmation

Verify that the directories have been created successfully.
Once created, inform the user that the workspace is ready and they can proceed to Phase 0 (Concept Interview) or Phase 1 (Targeting).
