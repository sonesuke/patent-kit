# Patent Kit Setup - Detailed Instructions

## Overview

Prepare the working directory for a new patent analysis project by creating the required directory structure.

## Process

### Step 1: Create Directories

Execute the appropriate command based on the user's Operating System:

**For Linux / Mac (Bash/Zsh)**:

```bash
mkdir -p 0-specifications \
         1-targeting/csv \
         1-targeting/json \
         2-screening/json \
         3-investigations
```

**For Windows (PowerShell)**:

```powershell
New-Item -ItemType Directory -Force -Path "0-specifications", "1-targeting\csv", "1-targeting\json", "2-screening\json", "3-investigations"
```

### Step 2: Confirmation

Verify that the directories have been created successfully.

Once created, inform the user that the workspace is ready and they can proceed to Phase 0 (Concept Interview) or Phase 1 (Targeting).

## Directory Structure

- `0-specifications/` - Product specifications and requirements
- `1-targeting/csv/` - Downloaded patent search results (CSV)
- `1-targeting/json/` - Patent search results (JSON)
- `2-screening/json/` - Screened patent data (JSON)
- `3-investigations/` - Prior art investigation results
