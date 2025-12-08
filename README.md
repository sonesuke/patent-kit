# Patent Kit

A spec-driven development kit for patent analysis, designed for AI agents (GitHub Copilot, Claude Code).

## Overview

This kit provides structured commands to automate:

- Patent Evaluation (Novelty/Inventive Step)
- Infringement Analysis (Clearance/FTO)
- Prior Art Search

## Prerequisites

This kit requires `google-patent-cli` and `arxiv-cli` to be installed and available in your PATH.

### Installation

1. **Install `ftoc` (Project Manager)**

   ```bash
   cargo install --path .
   ```

2. **Install Dependencies**

   Please install the required CLI tools following their official documentation:

- **google-patent-cli**: [Installation Guide](https://github.com/sonesuke/google-patent-cli#installation) (Pre-built binaries recommended)
- **arxiv-cli**: [Installation Guide](https://github.com/sonesuke/arxiv-cli#installation)

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
- **.claude** (if `--ai claude`): Claude-specific slash commands.
- **.copilot** (if `--ai copilot`): GitHub Copilot prompts.

### 2. Workflow (Spec-Driven Development)

1. **Phase 1: Evaluation (Spec)**: Analyze the patent.

    ```bash
    /patent-kit.evaluation JP2023-123456
    # Output: investigations/JP2023-123456/evaluation.md
    ```

2. **Phase 2: Infringement (Plan)**: Define search strategy.

    ```bash
    /patent-kit.infringement investigations/JP2023-123456/evaluation.md
    # Output: investigations/JP2023-123456/hearing.md -> infringement.md
    ```

3. **Phase 3: Prior (Execute)**: Run search and report.

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
