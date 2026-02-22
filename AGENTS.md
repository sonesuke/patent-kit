# Patent Kit - Agent Guidelines

## Project Overview

This repository (`patent-kit`) is a **Claude Plugin Marketplace** containing advanced patent analysis skills. It does not contain compiled binaries, but rather static `SKILL.md` files, Markdown templates, and helper scripts designed to be loaded dynamically into Claude Code.

## Architecture

- `.claude-plugin/marketplace.json`: The entry point defining the marketplace metadata.
- `plugin/`: The root directory of the `patent-kit` plugin containing `.claude-plugin/plugin.json`.
- `plugin/skills/`: Contains all analysis skills in flat directories. Each has a `SKILL.md` conforming to Claude's Official Skill Guidelines.

## Mandatory AI Agent Rules

1. **Language (User Communication)**: Always respond to the user in Japanese.
2. **Language (Code & Docs)**: All Pull Requests (PRs), code comments, and Markdown (`.md`) files MUST be written entirely in English.
3. **Commit Messages**: Always use Conventional Commits in English.
4. **Skill Instructions**: Do not instruct the execution of bash CLI commands like `google-patent-cli` in `SKILL.md`. Always instruct the use of the loaded MCP tools (`search_patents`, `fetch_patent`, `search_papers`, `fetch_paper`).

## Development & Formatting

- Format all files (`.md`, `.json`) using Prettier: `npx prettier --write .` (or via `mise run fmt`).
- Before committing structural changes to the plugin, validate the integrity by running `claude plugin validate .` in the project root.
