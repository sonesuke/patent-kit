# Targeting - Troubleshooting

## Skill Errors

### Error: Patent search skill fails

**Symptoms**: Patent search skills (google-patent-cli:patent-search, google-patent-cli:patent-assignee-check) fail with errors.

**Cause**: Skills may not be properly loaded or configured in the marketplace.

**Solution**:

1. Verify skills are available: Check that google-patent-cli is installed from the marketplace
2. Retry the skill invocation with simplified parameters
3. Check skill documentation for proper usage and parameter formats
4. Refer to skill documentation (google-patent-cli) for setup instructions

**Important**: Do NOT proceed with fabricated search results. Wait for the skills to function correctly.

## Error: "Permission denied" when running merge.sh

**Cause**: The script lacks execution permissions.

**Solution**: Run `chmod +x plugin/skills/targeting/scripts/shell/merge.sh`.
