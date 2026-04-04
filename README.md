# Patent Kit

AI-Native Patent Analysis Kit, designed for Claude Code.

> [!IMPORTANT]
> **Disclaimer**: This tool is provided for informational purposes only. The outputs do not constitute legal advice or professional patent opinions.

## Overview

A complete toolkit that empowers AI agents to autonomously search, analyze, and evaluate patents with human-level precision.

This kit provides structured commands to automate:

- **Concept Interview**: Define product concept and identify competitors.
- **Targeting**: Create a target population from patent databases.
- **Screening & Evaluation**: Filter and analyze patents for relevance.
- **Claim Analysis**: Compare product features against patent elements.
- **Prior Art Research**: Search for prior art references for high-risk patents.
- **Investigation Reporting**: Track progress across all phases.

## Install

Add this repository as a marketplace and install the plugin to your Claude Code environment:

```bash
# 1. Add this repository as a marketplace
claude plugin marketplace add sonesuke/patent-kit

# 2. Install the plugin (automatically loads required MCPs)
claude plugin install patent-kit@patent-kit-marketplace
```

### Prerequisites

You must have the following CLI tools installed and accessible in your system PATH to execute patent and paper searches. **When this plugin is loaded, it will automatically connect to these tools as built-in MCP servers.**

- [Google Patent CLI (google-patent-cli)](https://github.com/sonesuke/google-patent-cli)
- [arXiv CLI (arxiv-cli)](https://github.com/sonesuke/arxiv-cli)

## Quick Start

Navigate to your working directory and start Claude:

```bash
mkdir my-patent-project && cd my-patent-project
claude
```

Then run the skills in order:

```bash
/patent-kit:concept-interview
# Output: specification.md
```

## Workflow

### Phase 0: Concept Interview

Define product concept and identify competitors.

```bash
/patent-kit:concept-interview
# Output: specification.md
```

### Phase 1: Targeting

Generate search queries and create a target population.

```bash
/patent-kit:targeting
# Output: targeting.md, keywords.md, csv/
```

### Phase 2: Screening & Evaluation

Screen patents for relevance and evaluate claims.

```bash
/patent-kit:screening
# Output: patents.db (screening results)

/patent-kit:evaluating
# Output: patents.db (claims and elements)
```

### Phase 3: Claim Analysis

Compare product features against patent elements.

```bash
/patent-kit:claim-analyzing
# Output: patents.db (similarity results)
```

### Phase 4: Prior Art Research

Search for prior art references for patents with Moderate/Significant similarities.

```bash
/patent-kit:prior-art-researching
# Output: patents.db (prior art references)
```

### Progress Report

Track progress across all phases at any time.

```bash
/patent-kit:investigation-reporting
# Output: PROGRESS.md (overall progress)
# Output: <patent_id>.md (specific patent report)
```

## Output Structure

```text
.
├── specification.md          # Phase 0: Product definition
├── targeting.md               # Phase 1: Search strategy
├── keywords.md                # Phase 1: Search keywords
├── csv/                       # Phase 1: Target patent data
│   └── *.csv
└── patents.db                 # SQLite database for all investigation data
```

## Skills

### User-Invocable Skills

| Skill                     | Purpose                                            |
| ------------------------- | -------------------------------------------------- |
| `concept-interviewing`    | Define product concept and identify competitors    |
| `targeting`               | Create target population from patent databases     |
| `screening`               | Filter patents by legal status and relevance       |
| `evaluating`              | Decompose claims and elements for relevant patents |
| `claim-analyzing`         | Compare product features against patent elements   |
| `prior-art-researching`   | Search for prior art references                    |
| `investigation-reporting` | Generate progress reports                          |

### Internal Skills

These skills are automatically invoked by other skills and should not be used directly.

| Skill                     | Purpose                                          |
| ------------------------- | ------------------------------------------------ |
| `investigation-preparing` | Initialize SQLite database and import CSV files  |
| `investigation-fetching`  | Retrieve data from SQLite database               |
| `investigation-recording` | Record data to SQLite database                   |
| `legal-checking`          | Review documents for legal compliance violations |

## License

MIT
