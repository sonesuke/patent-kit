---
name: setup
description: "Initializes the required directory structure for patent analysis. Triggered when the user asks to 'initialize the project' or 'create directories'."
metadata:
  author: sonesuke
  version: 1.0.0
---

# Patent Kit Setup

Your task is to prepare the working directory for a new patent analysis project.

## Instructions

Run the following commands to create the necessary directories.
These directories are ignored by git (via `.gitignore`) or tracked via `.gitkeep`, and are required to store outputs during the analysis process.

### Step 1: Create Directories

Execute the appropriate command based on the user's Operating System:

- **For Linux / Mac (Bash/Zsh)**:

  ```bash
  mkdir -p 0-specifications \
           1-targeting/csv \
           1-targeting/json \
           2-screening/json \
           3-investigations
  ```

- **For Windows (PowerShell)**:
  ```powershell
  New-Item -ItemType Directory -Force -Path "0-specifications", "1-targeting\csv", "1-targeting\json", "2-screening\json", "3-investigations"
  ```

### Step 2: Confirmation

Verify that the directories have been created successfully.
Once created, inform the user that the workspace is ready and they can proceed to Phase 0 (Concept Interview) or Phase 1 (Targeting).

# Examples

Example 1: Initializing the Project
User says: "Set up the folders for a new investigation"
Actions:

1. Detect OS environment (Mac/Windows)
2. Use mkdir (or New-Item) to create required directories at once
   Result: Required folder structures like 0-specifications are prepared.

# Troubleshooting

Error: "Permission denied / Directory already exists"
Cause: Folder already exists or lacking permissions.
Solution: Usually succeeds due to -p or -Force. Check environment write permissions.
