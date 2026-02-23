# Targeting - Troubleshooting

## MCP Server Errors

### Error: MCP tool returns `isError: true`

**Symptoms**: Patent search tools (google-patent-cli, arxiv-cli) fail with errors.

**Cause**: MCP server may be unavailable or misconfigured.

**Solution**:

1. Verify MCP servers are connected: Check system initialization logs for connection status
2. Restart the dev container if needed
3. Check MCP server configuration in `.claude-settings.json` or `plugin/.claude-plugin/plugin.json`
4. Refer to MCP server documentation (google-patent-cli, arxiv-cli) for setup instructions

**Important**: Do NOT proceed with fabricated search results. Wait for the MCP tools to function correctly.

## Error: "Permission denied" when running merge.sh

**Cause**: The script lacks execution permissions.

**Solution**: Run `chmod +x plugin/skills/targeting/scripts/shell/merge.sh`.
