---
name: constitution
description: "Core Principles and Operational Guidelines for the Patent Kit"
disable-model-invocation: true
---

# Patent Investigation Constitution

Version: 1.0.0 Status: Active

## Core Principles

### I. Element-by-Element Analysis (The Golden Rule)

Every claim analysis or validity analysis MUST test the target invention against the reference patent element by element.

- **Rule**: Do not rely on "general similarity".
- **Templates**: strict adherence to the output templates in `.patent-kit/templates/` is required.
- **Requirement**: Break down the invention into Elements A, B, C. Find references that disclose A AND B AND C for anticipation (Novelty).

### II. Unified Search Scope

Investigations MUST cover the "Big 4" jurisdictions unless explicitly restricted.

- **Rule**: Always consider US, EP, JP, and CN references.
- **Mechanism**: Use machine translation for CN/JP if native language skills are unavailable.

### III. Comprehensive Literature Coverage

Prior art searches MUST cover both patent literature and non-patent literature.

- **Rule**: Use BOTH `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli` for every prior art investigation.
- **Rationale**: Comprehensive prior art analysis requires checking academic papers, conference proceedings, and technical publications alongside patents.
- **Requirement**: Document search results from both sources in the final report.

### IV. Evidence-Based Reporting

Every assertion in a report MUST be backed by specific citations.

- **Rule**: Never say "This feature is known."
- **Requirement**: Say "This feature is disclosed in [Patent ID], Column X, Line Y."

### V. Risk-Averse Screening

When in doubt during screening, err on the side of inclusion.

- **Rule**: If a reference is "borderline", grade it as 'B' (Relevant) rather than 'D' (Noise).
- **Rationale**: Missing a risk is worse than reviewing an extra document.

### VI. Breadth of Published Applications

For published applications (not yet granted), assume rights may be broadly secured based on the embodiments.

- **Rule**: Do not judge solely based on current claims.
- **Requirement**: Consider the "Detailed Description" and embodiments as potential scope for future amendments.

### VII. User "Hearing" for Claim Analysis

For Claim Analysis/FTO, accurate understanding of the target product is crucial.

- **Rule**: You MUST interview the user to get a detailed description of the product/service.
- **Requirement**: Do not proceed until you have a clear definition of the "Target Product" to compare against the claim elements.
- **Output**: Write the gathered information to `0-specification/specification.md` using the template `.patent-kit/templates/specification-template.md`.

### VIII. Prior Art Cutoff Date

Prior art searches MUST respect the target patent's effective filing/priority date.

- **Rule**: Prior art search results must be published BEFORE the target's priority date.
- **Requirement**: Use the `--before` flag in `./.patent-kit/bin/google-patent-cli` or `./.patent-kit/bin/arxiv-cli` with the correct date (YYYY-MM-DD).

- **Requirement**: Use the `--before` flag in `./.patent-kit/bin/google-patent-cli` or `./.patent-kit/bin/arxiv-cli` with the correct date (YYYY-MM-DD).

### IX. Search Query Optimization

Long or overly complex queries often return zero results in both `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli`.

- **Rule**: Start with broad, essential keywords (2-4 terms maximum).
- **Rule**: If a search returns zero results, progressively simplify the query:
  1. Remove technical modifiers and adjectives.
  2. Break compound concepts into separate searches.
  3. Try synonyms or broader terms.

- **Example**:
  - ❌ Too long: `"interactive bidirectional real-time data visualization dashboard"`
  - ✅ Better: `"interactive visualization"` OR `"data dashboard"`
- **Requirement**: Document the query evolution in your report (what worked, what didn't).
- **Requirement**: If multiple simplified queries are needed, save each result separately with descriptive filenames.

### X. Tool Integrity & Execution

Strictly adhere to the capabilities of provided tools.

- **Rule**: Do NOT hallucinate command options. Check `--help` if unsure.
- **Rule**: Use `./.patent-kit/bin/google-patent-cli` for patent literature and `./.patent-kit/bin/arxiv-cli` for non-patent literature (academic papers).
- **Rule**: STOP immediately if a command execution fails. Do not simulate results or proceed with the workflow.
- **Requirement**: Verify command success (exit code 0) before reading outputs.

### XI. Output Management

To maintain context window efficiency, large outputs from CLI tools MUST be handled via files.

- **Rule**: `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli` output MUST be redirected to a JSON file.
  - Path: `3-investigations/<patent-id>/json/<patent-id>.json` (for single patent)
  - Path: `3-investigations/<patent-id>/json/search_results_<timestamp>.json` (for search)
  - Path: `1-targeting/json/search_results_<desc>.json` (for targeting)
  - Path: `2-screening/json/<patent-id>.json` (for screening fetch)
- **Requirement**: Do NOT read the output from stdout.
- **Action**: Use `jq` or file reading tools to access specific fields from the generated JSON file only when needed.

### XII. Prohibited Legal Assertions (STRICT)

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

### XIII. Descriptive Equivalence Language

When discussing potential equivalence or similarity, strictly descriptive language describing the technical reality MUST be used.

- **Prohibited**: "This implementation satisfies the 5 requirements of equivalence."
- **Recommended**:
  - "The alternative implementation achieves the same functional outcome and exhibits comparable system behavior under typical operating conditions."
  - "The variation represents a commonly used implementation approach."
- **Rationale**: The AI provides technical analysis of function and behavior, not legal determination of equivalence.
