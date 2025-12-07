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

Please install the required CLI tools following their official documentation:

- **google-patent-cli**: [Installation Guide](https://github.com/sonesuke/google-patent-cli#installation) (Pre-built binaries recommended)
- **arxiv-cli**: [Installation Guide](https://github.com/sonesuke/arxiv-cli#installation)

## Usage

### Workflow (Spec-Driven Development)

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

## Commands

### 1. Patent Evaluation

Evaluate the strength of a patent (Novelty & Inventive Step).

- Claude: `/eval <patent-id>`
**Output**: `<patent-id-dir>/evaluation.md`

### 2. Infringement Check

Check if your product infringes on a specific patent.

- Claude: `/infringement <patent-id>`
# Note: The agent will ask you for details about your product before generating
the report

**Output**: `<patent-id-dir>/infringement.md`

### 3. Prior Art Search

Find prior art relevant to a specific patent.

- Claude: `/prior <patent-id>`
**Output**: `<patent-id-dir>/prior.md`

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
rumdl README.md .patent-kit .claude
```

To automatically fix issues:

```bash
rumdl --fix README.md .patent-kit .claude
```
