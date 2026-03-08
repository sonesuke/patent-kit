# Evaluating - Examples

## Example 1: Evaluating a Specific Patent

**User Request**: "Please evaluate JP-2023-12345-A"

**Actions**:

1. **Check Specification**: Verify `specification.md` exists
2. **Fetch Patent Data**:
   - Use `google-patent-cli:patent-fetch` skill with patent ID "JP-2023-12345-A"
   - The skill provides access to all patent details
3. **Analyze Claims**:
   - Read Claim 1 and decompose into elements (A, B, C...)
   - Identify key dependent claims
   - Check legal status and filing dates
4. **Draft Report**:
   - Fill in `assets/evaluation-template.md`
   - Include constituent elements analysis
   - Note any divisional applications or status issues
5. **Save Report**: `3-investigations/JP-2023-12345-A/evaluation.md`

**Result**: Evaluation report created with:

- Constituent elements breakdown
- Dependent claims summary
- Legal status verification
- No legal assertions (infringement analysis avoided)

## Example 2: Automatic Patent Selection

**User Request**: "Evaluate the next patent"

**Actions**:

1. **Query Database**:
   - Use `investigation-preparing` skill
   - Request: "Get the next patent ID for evaluation"
2. **Receive Result**: Database returns "US20240292070A1"
3. **Check for Existing Report**:
   - Verify `3-investigations/US20240292070A1/evaluation.md` does not exist
4. **Fetch and Analyze**:
   - Use `google-patent-cli:patent-fetch` with returned patent ID
   - Proceed with standard analysis workflow
5. **Save Report**: `3-investigations/US20240292070A1/evaluation.md`

**Result**: Next relevant patent automatically selected and evaluated.

## Example 3: Handling Existing Evaluation

**User Request**: "Re-evaluate US20240292070A1"

**Actions**:

1. **Check for Existing Report**:
   - Found: `3-investigations/US20240292070A1/evaluation.md` exists
2. **Ask User Confirmation**:
   - Message: "Evaluation report already exists for US20240292070A1. Do you want to proceed with re-evaluating?"
3. **Wait for User Response**:
   - If "yes": Proceed with re-evaluation
   - If "no": Stop and inform user
4. **If Confirmed**:
   - Fetch latest patent data
   - Create new evaluation report
   - Overwrite existing file

**Result**: User controls whether to proceed with re-evaluation.

## Example 4: Divisional Application Handling

**Patent**: "JP2023-123456-A" (Divisional of JP2020-123456)

**Actions**:

1. **Fetch Patent Data**:
   - Use `google-patent-cli:patent-fetch` with "JP2023-123456-A"
2. **Identify Divisional**:
   - Check patent family and priority claims
   - Found: This is a divisional application
   - Parent: JP2020-123456 (Filing Date: 2020-01-15)
3. **Use Parent Date**:
   - For prior art search, use parent's filing date (2020-01-15)
   - Note in report: "Divisional application - priority based on parent filing date"
4. **Complete Analysis**:
   - Analyze claims using parent's date as reference
   - Document divisional relationship in report

**Result**: Correct prior art search date used for divisional application.

## Example 5: Zombie Pending Status

**Patent**: "US2021/123456-A1"

**Actions**:

1. **Fetch Patent Data**:
   - Use `google-patent-cli:patent-fetch` with "US2021/123456-A1"
2. **Check Filing Date**: 2020-05-10
3. **Check Status**: "Pending"
4. **Calculate 3-Year Rule**:
   - Current date: 2024-03-08
   - Filing date: 2020-05-10
   - Time elapsed: ~3 years 10 months
5. **Identify Issue**: Examination deadline exceeded (3 years)
6. **Mark in Report**:
   - Status: "Pending (Likely Withdrawn - Examination Deadline Exceeded)"
   - Note: "Under Japanese law, examination request deadline is 3 years from filing. This patent may be deemed withdrawn."

**Result**: Correct legal status assessment with proper warning.

## Example 6: Avoiding Legal Assertions

**Patent**: "US20240292070A1" - Similar product features found

**Incorrect Approach**:

- "The patent does not satisfy the requirements for infringement."
- "Our product does not infringe this patent."
- "This is not a core technology patent."

**Correct Approach**:

- "Claim 1 requires [specific feature], which differs from our product's [alternative approach]."
- "The patent describes [method A], while our specification indicates [method B]."
- "Constituent elements: A=[feature A], B=[feature B], C=[feature C]."

**Result**: Factual claim analysis without legal conclusions about infringement.
