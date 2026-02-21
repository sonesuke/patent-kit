# Patent Kit

AI-Native Patent Analysis Kit, designed for AI agents (GitHub Copilot, Claude Code).

> [!IMPORTANT]
> **Disclaimer**: This tool is provided for informational purposes only. The outputs do not constitute legal advice or professional patent opinions.

## Overview

A complete toolkit that empowers AI agents to autonomously search, analyze, and evaluate patents with human-level precision.

This kit provides structured commands to automate:

- **Targeting & Screening**: Identify critical patents from the noise.
- **Patent Evaluation**: Validate novelty and inventive step logic.
- **Claim Analysis**: Detailed clearance and infringement reporting.

### Installation

Download the latest binary for your platform from the [Releases](https://github.com/sonesuke/patent-kit/releases) page.

1. Extract the archive.
2. Add the `patent-kit` binary to your system PATH.

## Usage

### 1. Initialize Project

 Create a new project or initialize an existing one with the necessary configuration files.

  ```bash
  # Create a new project for Claude
  patent-kit init my-project --ai claude

  # Initialize existing project for Copilot
  patent-kit init . --ai copilot
  ```

  This command sets up:

  - **.patent-kit**: Common templates and memory bank.
    - **bin/**: Contains automatically downloaded `google-patent-cli` and `arxiv-cli`.
  - **.patent-kit-plugin** (if `--ai claude`): Claude Code plugin directory containing skills.
  - **.github/copilot-skills** (if `--ai copilot`): GitHub Copilot skills.

  **Note**: If you are behind a corporate proxy or have SSL certificate issues, use the `--insecure` flag to skip SSL verification during download:

  ```bash
  patent-kit init . --ai claude --insecure
  ```

### 2. Configure AI Agent

#### Claude Code

Load the generated plugin directory by adding it to your Claude Code command:

```bash
claude --plugin-dir .patent-kit-plugin
```

### 3. Workflow

1. **Phase 1: Targeting**: Define product concept and generate queries.

   **Claude**:
     ```bash
     /patent-kit:targeting
     # Output: targeting/targeting.md
     ```

   **Copilot**: Look for `targeting` in your skills panel.

2. **Phase 2: Evaluation**: Analyze the patent.

    **Claude**:
    ```bash
    /patent-kit:evaluation JP2023-123456
    # Output: investigations/JP2023-123456/evaluation.md
    ```

    **Copilot**: Look for `evaluation` in your skills panel.

3. **Phase 4: Claim Analysis**: Define search strategy.

    **Claude**:
    ```bash
    /patent-kit:claim-analysis JP2023-123456
    # Output: investigations/JP2023-123456/claim-analysis.md
    ```

    **Copilot**: Look for `claim-analysis` in your skills panel.

4. **Phase 5: Prior Art**: Run search and report.

    **Claude**:
    ```bash
    /patent-kit:prior-art JP2023-123456
    # Output: investigations/JP2023-123456/prior-art.md
    ```

    **Copilot**: Look for `prior-art` in your skills panel.

5. **Track Progress**: Summarize the current status of all investigations.

    **Claude**:
    ```bash
    /patent-kit:progress
    # Output: PROGRESS.md
    ```

    **Copilot**: Look for `progress` in your skills panel.

## Output Structure

The project is organized into numbered phases:

```text
.
├── 0-specifications/         # Phase 0: Product definition
│   └── specification.md
├── 1-targeting/              # Phase 1: Search strategy & data
│   ├── targeting.md
│   ├── keywords.md
│   ├── target.jsonl
│   └── csv/
├── 2-screening/              # Phase 2: Screening results
│   └── (Screening data)
├── 3-investigations/         # Phase 3-5: Detailed analysis
│   └── JP2023-123456/
│       ├── evaluation.md
│       ├── claim-analysis.md
│       └── prior-art.md
└── PROGRESS.md               # Overall status report
```

## Development

### Workflow

Before submitting a Pull Request, please ensure your code is formatted and linted.

1. **Format & Fix** (Auto-correct/Fix):

    ```bash
    cargo lint --fix
    ```

    This command runs `clippy --fix`, `cargo fmt`, and `rumdl --fix`.

2. **Lint Check** (Check only):

    ```bash
    cargo lint
    ```

    This command runs checks for formatting, clippy, and markdown without modifying files.

 These commands utilize the custom aliases defined in `.cargo/config.toml` to run `cargo fmt`/`clippy` and `rumdl` together.
