# Step 3: Report Generation

Generate the evaluation report based on patent analysis.

## 1. Draft Report

Fill in the evaluation template:

- **Template**: Use `assets/evaluation-template.md`
- **Include**:
  - Constituent elements analysis
  - Dependent claims summary
  - Divisional application notes (if applicable)
  - Legal status and 3-year rule check results

## 2. Avoid Legal Assertions

**IMPORTANT**: Do NOT make legal assertions about infringement or validity.

**Avoid These Terms**:

- "Does not satisfy"
- "Does not infringe"
- "Is a core technology"
- Specific court case examples

**Use Factual Language Instead**:

- "Claim 1 requires [specific feature]"
- "The patent describes [method A]"
- "Constituent elements: A=[feature A], B=[feature B]"

## 3. Save Report

Create the evaluation report file:

- **Path**: `3-investigations/<patent-id>/evaluation.md`
- **Format**: Follow the template structure
- **Content**: Complete analysis results

## Quality Gates

- [ ] **Template Filled**: All analysis results entered into evaluation template
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology"
  - [ ] Avoid citing specific court case examples
- [ ] **Report Saved**: `3-investigations/<patent-id>/evaluation.md` created

## Deliverables

1. `3-investigations/<patent-id>/evaluation.md` - Complete evaluation report
