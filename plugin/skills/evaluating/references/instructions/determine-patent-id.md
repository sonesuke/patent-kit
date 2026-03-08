# Step 0: Determine Patent ID

Determine which patent to evaluate based on user input or database query.

## If No Patent ID Provided

Query the database for the next relevant patent to evaluate:

1. Use the `investigating-database` skill
2. Request: "Get the next patent ID for evaluation"
3. The skill will find the first patent marked as `relevant` that doesn't yet have an evaluation report

## If Patent ID IS Provided

Check for existing evaluation report:

1. Check if `3-investigations/<patent-id>/evaluation.md` already exists
2. **If it exists**: **ASK the User for confirmation**
   - Message: "Evaluation report already exists for <patent-id>. Do you want to proceed with re-evaluating?"
3. **If it does NOT exist**: Proceed with the standard process

## Output

- **Patent ID**: The patent ID to evaluate (either provided or retrieved from database)
