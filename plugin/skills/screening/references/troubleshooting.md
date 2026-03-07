# Screening Troubleshooting

## Common Issues and Solutions

### Issue: "No patents found in database"

**Symptoms**:

- Query returns empty results
- `total_targets` is 0

**Diagnosis**:

```bash
sqlite3 patents.db "SELECT COUNT(*) FROM target_patents;"
```

**Solutions**:

1. Ensure targeting phase completed successfully
2. Check that `patents.db` exists in workspace root
3. Verify CSV import completed without errors

### Issue: "Resume support not working"

**Symptoms**:

- Same patents being screened twice
- Duplicate entries in screened_patents table

**Diagnosis**:

```bash
sqlite3 patents.db "SELECT patent_id, COUNT(*) FROM screened_patents GROUP BY patent_id HAVING COUNT(*) > 1;"
```

**Solutions**:

1. Check investigating-database skill's get-patent-id logic
2. Verify it skips already-screened patents
3. Ensure database query filters out screened patents

### Issue: "Rate limit exceeded / Timeout"

**Symptoms**:

- `fetch-patent` command fails with timeout
- Too many requests error

**Solutions**:

1. **Resume from interruption**: Screening automatically skips processed patents
2. **Check progress**:
   ```bash
   sqlite3 patents.db "SELECT * FROM v_screening_progress;"
   ```
3. **Retry failed patents**: Investigating-database skill tracks unscreened patents

### Issue: "Abstract text not available"

**Symptoms**:

- `abstract_text` field is NULL or empty
- Cannot determine relevance without abstract

**Solutions**:

1. Check if patent was fetched successfully using google-patent-cli:patent-fetch skill
2. If abstract unavailable, use title and claims for relevance judgment

### Issue: "Legal status not available"

**Symptoms**:

- `legal_status` field is NULL or empty
- Cannot determine if patent is expired

**Solutions**:

1. Check patent status via `fetch-patent` tool
2. If status still unavailable, mark as `irrelevant` with note: "Status unknown, exclude from evaluation"

### Issue: "Template formatting errors"

**Symptoms**:

- Generated `screening.md` doesn't match template
- Missing sections or incorrect structure

**Solutions**:

1. **Strictly follow** `screening-template.md` structure
2. **DO NOT add** extra sections or fields
3. **DO NOT remove** required sections
4. Verify all required sections are present:
   - Progress
   - Relevance Distribution (Relevant, Irrelevant, Expired)
   - Top 10 Relevant Patents

### Issue: "Judgment consistency problems"

**Symptoms**:

- Similar patents judged differently
- Inconsistent criteria application

**Solutions**:

1. **Reference specification**: Re-read `0-specifications/specification.md` every 10 patents
2. **Self-check**: "Am I applying the same criteria as the previous patent?"
3. **Document edge cases**: Note unusual cases in reason field
4. **Conservative approach**: When in doubt, mark as `relevant` (can re-evaluate in Evaluation phase)

### Issue: "Database locked errors"

**Symptoms**:

- SQLite "database is locked" error
- Cannot record screening result

**Solutions**:

1. **WAL mode**: Ensure `PRAGMA journal_mode = WAL` is set
2. **Retry logic**: Investigating-database skill should retry on lock
3. **Single process**: Ensure only one screening instance running
4. **Close connections**: Verify no hanging SQLite connections

## Validation Checklist

Before finalizing screening:

- [ ] All `target_patents` processed: `total_screened = total_targets`
- [ ] No legal assertions in reasons

## Getting Help

If issues persist:

1. **Check database**:

   ```bash
   sqlite3 patents.db "SELECT * FROM v_screening_progress;"
   sqlite3 patents.db "SELECT * FROM target_patents LIMIT 5;"
   sqlite3 patents.db "SELECT * FROM screened_patents LIMIT 5;"
   ```

2. **Verify references**: Ensure `investigating-database` skill is functioning correctly

3. **Resume capability**: Screening should automatically resume from last processed patent
