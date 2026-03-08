# Screening Troubleshooting

## Common Issues and Solutions

### Issue: "Team creation fails"

**Symptoms**:

- Agent tool returns error when creating team
- Teammates fail to initialize

**Solutions**:

1. Check agent availability in the environment
2. Verify team size is reasonable (3-5 agents recommended)
3. Reduce team size if resource constraints exist
4. Retry team creation with smaller team

### Issue: "Rate limit exceeded / Timeout"

**Symptoms**:

- Patent fetch operations fail with timeout
- Too many requests error from patent API

**Solutions**:

1. **Reduce parallelism**: Decrease team size to reduce concurrent requests
2. **Add delays**: Implement brief delays between batch processing
3. **Resume capability**: Screening automatically skips processed patents on retry
4. **Check progress**: Use investigating-database skill to monitor completion

### Issue: "Inconsistent judgments across agents"

**Symptoms**:

- Similar patents judged differently by different agents
- Criteria application varies between teammates

**Solutions**:

1. **Clear specification**: Ensure all agents read `0-specifications/specification.md`
2. **Provide examples**: Include judgment examples in agent instructions
3. **Quality check**: Review sample results from each agent
4. **Standardize criteria**: Document edge cases and share with all agents

### Issue: "Agent fails to respond"

**Symptoms**:

- One or more teammates stop responding
- Partial completion of assigned patents

**Solutions**:

1. **Check agent status**: Use TaskOutput to check if agent is still running
2. **Reassign patents**: Assign failed agent's patents to another teammate
3. **Investigate logs**: Check agent's output for error messages
4. **Retry failed patents**: Use investigating-database skill to identify unprocessed patents

### Issue: "Skill not available"

**Symptoms**:

- investigating-database skill fails to load
- google-patent-cli skill returns error

**Solutions**:

1. **Verify skill installation**: Check skills are available in marketplace
2. **Check skill configuration**: Verify skill settings are correct
3. **Retry skill loading**: Reload skill and retry operation

## Getting Help

If issues persist:

1. **Check team status**: Verify all teammates are running and responsive
2. **Review agent outputs**: Check individual agent results for errors
3. **Verify database**: Use investigating-database skill to check database state
4. **Consult references**: Review instructions.md for detailed process steps
