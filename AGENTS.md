# Patent Kit - Agent Guidelines

## Project Overview

This repository (`patent-kit`) is a **Claude Plugin Marketplace** containing advanced patent analysis skills. It does not contain compiled binaries, but rather static `SKILL.md` files, Markdown templates, and helper scripts designed to be loaded dynamically into Claude Code.

## Architecture

- `.claude-plugin/marketplace.json`: The entry point defining the marketplace metadata.
- `claude-plugin/plugin.json`: The plugin manifest declaring the `patent-kit` MCP server.
- `claude-plugin/skills/`: Contains all analysis skills in flat directories. Each has a `SKILL.md` conforming to Claude's Official Skill Guidelines.

## Mandatory AI Agent Rules

1. **Language (User Communication)**: Always respond to the user in Japanese.
2. **Language (Code & Docs)**: All Pull Requests (PRs), code comments, and Markdown (`.md`) files MUST be written entirely in English.
3. **Commit Messages**: Always use Conventional Commits in English.
4. **Skill Instructions**: Do not instruct the execution of bash CLI commands like `google-patent-cli` in `SKILL.md`. Always instruct the use of the loaded MCP tools (`search_patents`, `fetch_patent`, `search_papers`, `fetch_paper`).

## Rust Binary (`patent-kit`)

The project includes a Rust MCP server and CLI installed via `cargo install --path .`.

### Build & Install

```bash
cargo install --path .       # Build release and install to ~/.cargo/bin
cargo build --release        # Build only (binary at target/release/patent-kit)
```

### CLI Commands

All commands support a `--verbose` flag for debugging (outputs search URLs and API status to stderr).

```bash
patent-kit mcp               # Start MCP server over stdio
patent-kit check-assignee "Apple" --verbose
patent-kit search-patents "query" --assignee "Apple" --limit 5 --verbose
patent-kit import-csv <file>
patent-kit index-patents
patent-kit get-unscreened --limit 5
patent-kit screen-patent <id> --judgment relevant --reason "..."
patent-kit get-unevaluated --limit 5
patent-kit record-claims <id> <json>
patent-kit get-claims <id>
patent-kit record-elements <json>
patent-kit get-elements <id>
patent-kit get-unanalyzed --limit 5
patent-kit record-similarities <json>
patent-kit get-product-features
patent-kit record-product-feature --name "..." --description "..."
patent-kit get-unresearched --limit 5
patent-kit record-prior-arts <json>
patent-kit get-patent-detail <id>
patent-kit progress
```

### MCP Server

Defined in `claude-plugin/.mcp.json`. The server uses newline-delimited JSON-RPC over stdio (rmcp 0.16 transport). Tools are registered in `src/mcp/mod.rs`.

### Key Source Files

- `src/main.rs` — Entry point
- `src/cli/mod.rs` — CLI command definitions and dispatch
- `src/mcp/mod.rs` — MCP server: tool registration, handler, formatters
- `src/core/db.rs` — SQLite database operations
- `src/core/config.rs` — Configuration loading
- `src/core/models.rs` — Request/response types for MCP tools

### Dependencies (git)

- `google-patent-cli` — Google Patents search via headless Chromium (`~/.cargo/git/checkouts/google-patent-cli-*/`)
- `arxiv-cli` — arXiv paper search via headless Chromium (`~/.cargo/git/checkouts/arxiv-cli-*/`)

### Debugging Notes

- Google Patents may return generic/unfiltered results (same patents regardless of query) when the environment IP is rate-limited. Check `--verbose` output — if `total_results` is identical across different queries, this is likely the cause.
- The MCP server spawns Chromium on startup. Orphan Chromium processes are killed on shutdown.

## Testing

### Rust Unit Tests

```bash
cargo test            # Run unit tests
mise run test         # Same as above
mise run clippy       # Lint with clippy
```

### Skill-Bench (E2E Tests)

```bash
mise run skill-bench  # Run all E2E tests (auto-installs patent-kit, uses --plugin-dir)
skill-bench run tests/concept-interviewing/triggering.toml --plugin-dir ./claude-plugin --threads 4 --log ./logs
skill-bench run tests --plugin-dir ./claude-plugin --filter "triggering" --threads 4 --log ./logs
skill-bench list      # List discovered tests (from `cases/` dir)
```

Key points:

- `--plugin-dir ./claude-plugin` is required for MCP server and skill loading
- Test cases are in `tests/<skill>/<test>.toml`
- Session logs are written to `./logs/` when `--log` is provided

## Development & Formatting

- Format all files (`.md`, `.json`) using Prettier: `npx prettier --write .` (or via `mise run fmt`).
- Before committing structural changes to the plugin, validate the integrity by running `claude plugin validate .` in the project root.

## Development Container

The dev environment uses a Nix flake-based Docker image managed via mise tasks.

- **Build**: `mise run build` — Build the Docker image with Nix
- **Start**: `mise run up` — Start the dev container
- **Setup**: `mise run setup` — Configure git, Claude CLI, MCP tools, and skills inside the container
- **Attach**: `mise run attach` — Open a shell inside the running container
- **Stop**: `mise run down` — Stop and remove the container

## Autonomous Agents (Host Loop)

This repository includes autonomous agent scripts under `agents/` that can be run on the host machine to perform background tasks.

### PR-Healer (`agents/pr-healer/auto-heal.sh`)

An autonomous daemon that runs inside the container and checks for failing GitHub Actions CI checks on open Pull Requests.

- **Workflow**: Finds failing PRs → Runs `claude` with `--worktree` → Analyzes the failure (typically using `npm run lint`) → Commits the fix and replies to the PR.
- **Requirements**: Requires GitHub CLI (`gh`) authenticated inside the container.

### Skill-Bench (`skill-bench`)

A TOML-based E2E test runner for `patent-kit` skills, installed via `mise`.

- **Architecture**: All execution happens inside the container. Test cases are defined in TOML format under `tests/<skill>/<test>.toml`.
- **Workflow**: Reads test cases → Sets up isolated workspaces → Runs `claude -p` with test prompts → Evaluates results using built-in check types → Generates summary in `logs/`.
- **Usage**: `mise run test` (runs all tests under `tests/`).
- **Test Case Format**: TOML files with `test_prompt`, `timeout`, `[[setup]]`, and `[[checks]]` sections. See `skill-bench help` for available check types.
- **Check Types**: `skill-loaded`, `skill-invoked`, `mcp-loaded`, `mcp-tool-invoked`, `mcp-success`, `tool-use`, `tool-param`, `workspace-file`, `workspace-dir`, `file-contains`, `log-contains`, `message-contains`, `db-query`.
