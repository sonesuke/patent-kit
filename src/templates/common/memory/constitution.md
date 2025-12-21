# Patent Investigation Constitution

Version: 1.0.0 Status: Active

## Core Principles

### I. Element-by-Element Analysis (The Golden Rule)

Every infringement or validity analysis MUST test the target invention against the reference patent element by element.

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
- **Rationale**: Comprehensive invalidity analysis requires checking academic papers, conference proceedings, and technical publications alongside patents.
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

### VII. User "Hearing" for Infringement

For Infringement/FTO analysis, accurate understanding of the target product is crucial.

- **Rule**: You MUST interview the user to get a detailed description of the product/service.
- **Requirement**: Do not proceed until you have a clear definition of the "Target Product" to compare against the claim elements.
- **Requirement**: Do not proceed until you have a clear definition of the "Target Product" to compare against the claim elements.

### VIII. Prior Art Cutoff Date

Invalidity searches MUST respect the target patent's effective filing/priority date.

- **Rule**: Prior art search results must be published BEFORE the target's priority date.
- **Requirement**: Use the `--before` flag in `./.patent-kit/bin/google-patent-cli` or `./.patent-kit/bin/arxiv-cli` with the correct date (YYYY-MM-DD).

- **Requirement**: Use the `--before` flag in `./.patent-kit/bin/google-patent-cli` or `./.patent-kit/bin/arxiv-cli` with the correct date (YYYY-MM-DD).

### IX. Adaptive Strategy Selection

Unless the user explicitly specifies a strategy:
- **Rule**: Dynamically determine the best path (FTO vs Invalidation) *during* the search.
- **Process**:

  1. Start broad.
  2. If *Product Features* are found -> Switch to **FTO Logic** (Easier/Safer).
  3. If *Product Features* are NOT found, but *Claim Elements* are -> Switch to **Invalidation Logic**.

- **Requirement**: The final report must clearly state which logic was successfully applied.

### X. Search Query Optimization

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

### XI. Tool Integrity & Execution

Strictly adhere to the capabilities of provided tools.

- **Rule**: Do NOT hallucinate command options. Check `--help` if unsure.
- **Rule**: Use `./.patent-kit/bin/google-patent-cli` for patent literature and `./.patent-kit/bin/arxiv-cli` for non-patent literature (academic papers).
- **Rule**: STOP immediately if a command execution fails. Do not simulate results or proceed with the workflow.
- **Requirement**: Verify command success (exit code 0) before reading outputs.

### Evaluation Gate

- [ ] Are all constituent elements (A+B+C...) clearly defined?
- [ ] Is the objective (FTO vs Invalidation) explicitly selected?

### Plan Gate

- [ ] Are keywords provided for at least English, Japanese, and Chinese scopes?
- [ ] Are classification codes (IPC/CPC) validated against a known database?

### Report Gate

- [ ] Does every Grade A result have a corresponding claim chart or mapping?
- [ ] Are all dates verified (Priority date vs Publication date)?

### XII. Output Management

To maintain context window efficiency, large outputs from CLI tools MUST be handled via files.

- **Rule**: `./.patent-kit/bin/google-patent-cli` and `./.patent-kit/bin/arxiv-cli` output MUST be redirected to a JSON file.
  - Path: `investigations/<patent-id>/json/<patent-id>.json` (for single patent)
  - Path: `investigations/<patent-id>/json/search_results_<timestamp>.json` (for search)
  - Path: `screening/json/search_results_<desc>.json` (for screening)
- **Requirement**: Do NOT read the output from stdout.
- **Action**: Use `jq` or file reading tools to access specific fields from the generated JSON file only when needed.
