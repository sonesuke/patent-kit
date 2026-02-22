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

### Installation & Usage

1. **Clone this repository** to serve as your project base:

   ```bash
   git clone https://github.com/sonesuke/patent-kit.git my-project
   cd my-project
   ```

   _(Alternatively, you can click "Use this template" if configured on GitHub)._

2. **Configure AI Agent**

#### Claude Code

Load the plugin directory by adding it to your Claude Code command:

```bash
claude --plugin-dir .claude-plugin
```

**(Optional) Copilot Skills**: GitHub Copilot skills are already available in the `.github/copilot-skills/` directory.

### Prerequisites (Install the CLIs)

You must have the following CLI tools installed and accessible in your system PATH to execute patent and paper searches. 
**When this plugin is loaded, it will automatically connect to these tools as built-in MCP servers.**

- [Google Patent CLI (google-patent-cli)](https://github.com/sonesuke/google-patent-cli)
- [arXiv CLI (arxiv-cli)](https://github.com/sonesuke/arxiv-cli)

#### Installation (with Rust toolchain)

```sh
cargo install --git https://github.com/sonesuke/google-patent-cli.git
cargo install --git https://github.com/sonesuke/arxiv-cli.git
```

### Workflow

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
