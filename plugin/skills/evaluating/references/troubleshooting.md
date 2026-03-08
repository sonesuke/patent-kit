# Evaluating - Troubleshooting

## Common Issues and Solutions

### Issue: "Failed to fetch patent data"

**Possible Causes**:

1. Invalid Patent ID format
2. Network connectivity issues
3. Patent ID does not exist in Google Patents database
4. MCP tool not properly loaded

**Solutions**:

1. **Verify Patent ID Format**:
   - Check if patent ID follows standard format (e.g., "US20240292070A1", "JP2023-123456-A")
   - Look for typos or missing characters
   - Ensure no extra spaces or special characters

2. **Check Network Connection**:
   - Verify internet connectivity is working
   - Try accessing patents.google.com directly in a browser
   - If using VPN, try temporarily disabling it

3. **Verify Patent Exists**:
   - Search for the patent manually on Google Patents
   - Check if patent number is correct
   - Some patents may be removed or restricted

4. **Check MCP Tool Status**:
   - Verify `google-patent-cli:patent-fetch` skill is loaded
   - Check MCP server is running
   - Look for error messages in the tool output

**Example Fix**:

```
Wrong: "US-2024-0292070-A1" (too many hyphens)
Correct: "US20240292070A1"
```

### Issue: "Specification file not found"

**Possible Causes**:

1. `0-specifications/specification.md` does not exist
2. Specification is incomplete or missing product details
3. Wrong file path or filename

**Solutions**:

1. **Check File Existence**:
   - Use `ls 0-specifications/` to verify directory exists
   - Check if `specification.md` file is present
   - Verify correct filename (not "spec.md" or "specification.txt")

2. **Run Concept Interviewing**:
   - If specification is missing, use `patent-kit:concept-interviewing` skill
   - Complete the product specification first
   - Ensure all required fields are filled

3. **Verify Content**:
   - Check if specification contains product definition
   - Verify "Target Product" section is complete
   - Confirm technical features are documented

**Prevention**:

- Always run Phase 0 (concept-interviewing) before Phase 3 (evaluating)
- Keep specification updated with latest product information

### Issue: "Database query failed"

**Possible Causes**:

1. `investigating-database` skill not loaded
2. Database file not initialized
3. SQL query syntax error
4. No patents marked as "relevant" in database

**Solutions**:

1. **Check Database Status**:
   - Verify `patents.db` exists in workspace
   - Check if database is initialized
   - Use `investigating-database` skill to query database status

2. **Verify Screening Complete**:
   - Check if screening phase has been completed
   - Query: "Get screening progress statistics"
   - Ensure patents are marked as "relevant"

3. **Re-run Screening**:
   - If no relevant patents found, re-run screening phase
   - Use `patent-kit:screening` skill
   - Verify patents are correctly screened

4. **Check Database Schema**:
   - Verify `screened_patents` table exists
   - Check if `judgment` column has "relevant" values
   - Use schema validation queries

**Example Query**:

```sql
SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant';
-- Should return > 0 if screening is complete
```

### Issue: "Evaluation report already exists"

**Possible Causes**:

1. User requests re-evaluation of already evaluated patent
2. Patent ID matches previous evaluation
3. File already exists in `3-investigations/` directory

**Solutions**:

1. **Ask User Confirmation**:
   - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with re-evaluating?"
   - Wait for user response
   - Only proceed if user confirms

2. **Check for Updates**:
   - Verify if patent data has changed since last evaluation
   - Check publication dates for updates
   - Consider if re-evaluation is necessary

3. **Archive Old Report** (Optional):
   - Rename old report: `evaluation.md` → `evaluation.old.md`
   - Create new evaluation report
   - Keep both for comparison

**Best Practice**:

- Always ask user before overwriting existing files
- Provide clear information about what will be overwritten

### Issue: "Template file not found"

**Possible Causes**:

1. Wrong template path specified
2. Template file moved or deleted
3. Assets directory not properly structured

**Solutions**:

1. **Verify Template Location**:
   - Check `assets/evaluation-template.md` exists
   - Use `ls plugin/skills/evaluating/assets/` to verify
   - Ensure skill is loaded correctly

2. **Reinstall Skill** (if needed):
   - Uninstall and reinstall `patent-kit` plugin
   - Verify all template files are present
   - Check plugin directory structure

3. **Use Absolute Path**:
   - Instead of relative path, use full path
   - Example: `/workspaces/patent-kit/plugin/skills/evaluating/assets/evaluation-template.md`

**Prevention**:

- Keep template files in correct locations
- Don't move or rename template files
- Regularly verify plugin integrity

### Issue: "Constitution or Legal Checker skill not loaded"

**Possible Causes**:

1. Required skills not loaded before evaluation
2. Skill loading failed silently
3. Skill dependencies not satisfied

**Solutions**:

1. **Explicitly Load Skills**:

   ```
   Skill: constitution-reminding
   Skill: legal-checking
   ```

2. **Verify Skill Loading**:
   - Check skill was loaded successfully
   - Look for error messages in skill output
   - Confirm skill is available in marketplace

3. **Load in Correct Order**:
   1. Load constitution-reminding
   2. Load legal-checking
   3. Then proceed with evaluation

**Prevention**:

- Always load required skills before starting evaluation
- Check skill loading status
- Handle skill loading failures gracefully

## Debug Mode

If issues persist, enable debug mode:

1. **Check Plugin Status**:

   ```bash
   claude plugin status
   ```

2. **Verify MCP Servers**:

   ```bash
   claude plugin list
   ```

3. **Check Database**:

   ```bash
   sqlite3 patents.db ".tables"
   sqlite3 patents.db "SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant';"
   ```

4. **Review Logs**:
   - Check skill execution logs
   - Look for error messages
   - Identify the step where failure occurred

## Getting Help

If none of these solutions work:

1. Check the main SKILL.md for additional context
2. Review examples.md for correct usage patterns
3. Verify all prerequisites are met
4. Consider opening an issue on the repository
