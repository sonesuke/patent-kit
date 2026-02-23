# Legal Checker - Patent Investigation Guidelines

Version: 1.0.0 | Status: Active

## I. Prohibited Legal Assertions (STRICT)

To detect risks without crossing into the practice of law, specific legal assertions and definitive judgments are STRICTLY PROHIBITED in all outputs.

- **Rule**: You MUST NOT use the following terms:
  - "Does not satisfy"
  - "Does not infringe"
  - "Is a core technology"
  - "Is invalid"

- **Rules**:
  - **Avoid definitive legal conclusions**: Use technical descriptors (e.g., "features not found", "low likelihood of mapping", "fundamental feature").
  - **No Specific Case Citations**: Do not cite specific court cases or legal precedents to justify a conclusion.

- **Requirement**: Focus entirely on technical comparison (Element A vs Feature A') and factual observation.

## II. Descriptive Equivalence Language

When discussing potential equivalence or similarity, strictly descriptive language describing the technical reality MUST be used.

- **Prohibited**: "This implementation satisfies the 5 requirements of equivalence."

- **Recommended**:
  - "The alternative implementation achieves the same functional outcome and exhibits comparable system behavior under typical operating conditions."
  - "The variation represents a commonly used implementation approach."

- **Rationale**: The AI provides technical analysis of function and behavior, not legal determination of equivalence.

## III. Acceptable vs. Unacceptable Language Examples

### Unacceptable (Legal Determinations):

- ❌ "The claim does not infringe the reference."
- ❌ "This element is satisfied by the prior art."
- ❌ "The product is clearly outside the scope of the claims."
- ❌ "This patent is invalid due to obviousness."

### Acceptable (Technical Descriptions):

- ✅ "Feature A' performs the same function as Element A: [describe technical function]."
- ✅ "The reference discloses a component that [technical description]."
- ✅ "Element A requires [technical requirement], which is not found in the reference."
- ✅ "The implementation differs in the following technical aspects: [list differences]."

## IV. Claim Mapping Best Practices

When mapping claim elements to prior art features:

1. **Be Specific**: Quote exact claim language and compare to specific reference disclosures.
2. **Avoid Conclusions**: Present the comparison facts; let the reader draw legal conclusions.
3. **Use Neutral Language**: "The reference shows X" instead of "The reference proves X."
4. **Document Gaps**: Clearly state what is NOT found in the reference.

### Example Format:

**Element A**: [Quote from claim]

**Reference Analysis**:

- Found: [describe what IS in the reference]
- Not found: [describe what is NOT in the reference]
- Technical difference: [describe any differences]

**Conclusion**: [Technical summary, NOT legal conclusion]

## V. FTO Analysis Guidelines

For Freedom to Operate analysis:

1. **Identify Risks, Not Infringements**: Use terms like "potential risk," "requires further review," "may overlap."
2. **Scope Assessment**: Describe claim breadth in technical terms, not legal terms.
3. **Design Around Options**: Suggest technical alternatives without guaranteeing non-infringement.

### Acceptable FTO Language:

- "The claim covers [technical description], which may overlap with [product feature]."
- "Consider design modifications to [technical element] to reduce potential risk."
- "Further analysis recommended for [specific technical area]."

## VI. Invalidity Analysis Guidelines

For invalidity or novelty analysis:

1. **Anticipation**: Describe what the reference discloses; avoid "anticipates" or "renders obvious."
2. **Obviousness**: Present technical differences; avoid "would have been obvious."
3. **Claim Construction**: Describe claim meaning in technical terms; avoid legal claim construction.

### Acceptable Invalidity Language:

- "The reference discloses all elements of Claim 1: [list]."
- "The implementation differs from the reference in [technical aspect]."
- "The reference teaches away from [technical feature]."
