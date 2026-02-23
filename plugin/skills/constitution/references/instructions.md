# Patent Investigation Constitution - Core Principles

Version: 1.0.0 | Status: Active

## I. Element-by-Element Analysis (The Golden Rule)

Every claim analysis or validity analysis MUST test the target invention against the reference patent element by element.

- **Rule**: Do not rely on "general similarity".
- **Templates**: strict adherence to the output templates in each skill's `templates/` or `assets/` directory is required.
- **Requirement**: Break down the invention into Elements A, B, C. Find references that disclose A AND B AND C for anticipation (Novelty).

## II. Unified Search Scope

Investigations MUST cover the "Big 4" jurisdictions unless explicitly restricted.

- **Rule**: Always consider US, EP, JP, and CN references.
- **Mechanism**: Use machine translation for CN/JP if native language skills are unavailable.

## III. Comprehensive Literature Coverage

Prior art searches MUST cover both patent literature and non-patent literature.

- **Rule**: Use BOTH `search_patents`/`fetch_patents` and `search_papers`/`fetch_paper` for every prior art investigation.
- **Rationale**: Comprehensive prior art analysis requires checking academic papers, conference proceedings, and technical publications alongside patents.
- **Requirement**: Document search results from both sources in the final report.

## IV. Evidence-Based Reporting

Every assertion in a report MUST be backed by specific citations.

- **Rule**: Never say "This feature is known."
- **Requirement**: Say "This feature is disclosed in [Patent ID], Column X, Line Y."

## V. Risk-Averse Screening

When in doubt during screening, err on the side of inclusion.

- **Rule**: If a reference is "borderline", grade it as 'B' (Relevant) rather than 'D' (Noise).
- **Rationale**: Missing a risk is worse than reviewing an extra document.

## VI. Breadth of Published Applications

For published applications (not yet granted), assume rights may be broadly secured based on the embodiments.

- **Rule**: Do not judge solely based on current claims.
- **Requirement**: Consider the "Detailed Description" and embodiments as potential scope for future amendments.

## VII. User "Hearing" for Claim Analysis

For Claim Analysis/FTO, accurate understanding of the target product is crucial.

- **Rule**: You MUST interview the user to get a detailed description of the product/service.
- **Requirement**: Do not proceed until you have a clear definition of the "Target Product" to compare against the claim elements.
- **Output**: Write the gathered information to `0-specifications/specification.md` using the concept-interview skill's `assets/templates/specification-template.md`.

## VIII. Prior Art Cutoff Date

Prior art searches MUST respect the target patent's effective filing/priority date.

- **Rule**: Prior art search results must be published BEFORE the target's priority date.
- **Requirement**: Use the `--before` flag in `search_patents`/`fetch_patents` or `search_papers`/`fetch_paper` with the correct date (YYYY-MM-DD).

## IX. Search Query Optimization

Long or overly complex queries often return zero results in both `search_patents`/`fetch_patents` and `search_papers`/`fetch_paper`.

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

## X. Output Management

To maintain context window efficiency, large tool outputs MUST be saved to files.

- **Rule**: `search_patents` and `search_papers` results MUST be saved to a JSON file.
  - Path: `3-investigations/<patent-id>/json/<patent-id>.json` (for single patent)
  - Path: `3-investigations/<patent-id>/json/search_results_<timestamp>.json` (for search)
  - Path: `1-targeting/json/search_results_<desc>.json` (for targeting)
  - Path: `2-screening/json/<patent-id>.json` (for screening fetch)
- **Requirement**: Do NOT load large JSON outputs directly into context.
- **Action**: Use Read tool or jq to access specific fields from the saved JSON file when needed.
