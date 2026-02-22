# Patent Kit

AI-Native Patent Analysis Kit, designed for Claude Code.

> [!IMPORTANT]
> **Disclaimer**: This tool is provided for informational purposes only. The outputs do not constitute legal advice or professional patent opinions.

## Overview

A complete toolkit that empowers AI agents to autonomously search, analyze, and evaluate patents with human-level precision.

This kit provides structured commands to automate:

- **Targeting & Screening**: Identify critical patents from the noise.
- **Patent Evaluation**: Validate novelty and inventive step logic.
- **Claim Analysis**: Detailed clearance and infringement reporting.

1. **Install the Plugin**

Add this repository as a marketplace and install the plugin to your Claude Code environment:

```bash
# 1. Add this repository as a marketplace
claude plugin marketplace add sonesuke/patent-kit

# 2. Install the plugin (automatically loads required MCPs)
claude plugin add patent-kit@patent-kit-marketplace
```

2. **Initialize Workspace**

Navigate to your working directory and start Claude:

```bash
mkdir my-patent-project && cd my-patent-project
claude
```

Run the setup skill to generate the required directory structure:

```bash
/patent-kit:setup
```

### Prerequisites (Install the CLIs)

You must have the following CLI tools installed and accessible in your system PATH to execute patent and paper searches.
**When this plugin is loaded, it will automatically connect to these tools as built-in MCP servers.**

- [Google Patent CLI (google-patent-cli)](https://github.com/sonesuke/google-patent-cli)
- [arXiv CLI (arxiv-cli)](https://github.com/sonesuke/arxiv-cli)

### Workflow

1. **Phase 0: Concept Interview**: Define product concept.

   ```bash
   /patent-kit.concept-interview
   # Output: 0-specifications/specification.md
   ```

2. **Phase 1: Targeting**: Generate search queries and targets.

   ```bash
   /patent-kit:targeting
   # Output: 1-targeting/targeting.md
   ```

3. **Phase 2: Screening**: Screen patents for relevance.

   ```bash
   /patent-kit.screening
   # Output: 2-screening/screening.md
   ```

4. **Phase 3: Evaluation**: Analyze the patent.

   ```bash
   /patent-kit:evaluation JP2023-123456
   # Output: 3-investigations/JP2023-123456/evaluation.md
   ```

5. **Phase 4: Claim Analysis**: Define search strategy.

   ```bash
   /patent-kit:claim-analysis JP2023-123456
   # Output: 3-investigations/JP2023-123456/claim-analysis.md
   ```

6. **Phase 5: Prior Art**: Run search and report.

   ```bash
   /patent-kit:prior-art JP2023-123456
   # Output: 3-investigations/JP2023-123456/prior-art.md
   ```

7. **Track Progress**: Summarize the current status of all investigations.

   ```bash
   /patent-kit:progress
   # Output: PROGRESS.md
   ```

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
