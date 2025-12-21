# Patent Kit

A spec-driven development kit for patent analysis, designed for AI agents (GitHub Copilot, Claude Code).

## Overview

This kit provides structured commands to automate:

- Patent Evaluation (Novelty/Inventive Step)
- Infringement Analysis (Clearance/FTO)
- Prior Art Search

## Prerequisites

This kit requires `google-patent-cli` and `arxiv-cli`, which are **automatically downloaded** to the project directory during initialization.

### Installation

1. **Install `ftoc` (Project Manager)**

   ```bash
   cargo install --path .
   ```

## Usage

### 1. Initialize Project

Create a new project or initialize an existing one with the necessary configuration files.

```bash
# Create a new project for Claude
ftoc init my-project --ai claude

# Initialize existing project for Copilot
ftoc init . --ai copilot
```

This command sets up:
- **.patent-kit**: Common templates and memory bank.
  - **bin/**: Contains automatically downloaded `google-patent-cli` and `arxiv-cli`.
- **.claude** (if `--ai claude`): Claude-specific slash commands.
- **.copilot** (if `--ai copilot`): GitHub Copilot prompts.

**Note**: If you are behind a corporate proxy or have SSL certificate issues, use the `--insecure` flag to skip SSL verification during download:

```bash
ftoc init . --ai claude --insecure
```

### 2. Workflow

1. **Phase 1: Screening**: Identify risk candidates.

    ```bash
    /patent-kit.screening
    # Output: screening/prescreening.md -> screening/screening.md
    ```

2. **Phase 2: Evaluation**: Analyze the patent.

    ```bash
    /patent-kit.evaluation JP2023-123456
    # Output: investigations/JP2023-123456/evaluation.md
    ```

3. **Phase 3: Infringement**: Define search strategy.

    ```bash
    /patent-kit.infringement investigations/JP2023-123456/evaluation.md
    # Output: investigations/JP2023-123456/hearing.md -> infringement.md
    ```

4. **Phase 4: Prior**: Run search and report.

    ```bash
    /patent-kit.prior investigations/JP2023-123456/infringement.md
    # Output: investigations/JP2023-123456/prior.md
    ```

## Output Structure

All reports are generated in a directory named after the patent ID (e.g., `JP2023-123456.JP7123456`).

```text
JP2023-123456/
  ├── evaluation.md
  ├── infringement.md
  └── prior.md
```

## Configuration

- **Slash Commands**: `.claude/commands/`
- **Output Templates**: `.patent-kit/templates/`

## Development

### Linting

This project uses `rumdl` for Markdown linting. To install:

```bash
cargo install rumdl
```

To check for errors:

```bash
rumdl README.md src/templates/common src/templates/claude src/templates/copilot
```

To automatically fix issues:

```bash
rumdl --fix README.md src/templates/common src/templates/claude src/templates/copilot
```
