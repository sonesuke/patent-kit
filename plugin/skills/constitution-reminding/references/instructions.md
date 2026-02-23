# Patent Investigation Constitution - Core Principles

Version: 1.0.0 | Status: Active

## I. Element-by-Element Analysis (The Golden Rule)

Every claim analysis or validity analysis MUST test the target invention against the reference patent element by element.

- **Rule**: Do not rely on "general similarity".
- **Requirement**: Break down the invention into Elements A, B, C. Find references that disclose A AND B AND C for anticipation (Novelty).
- **Templates**: Each skill defines its own template requirements in its instructions.

## II. Comprehensive Literature Coverage

Prior art searches MUST cover both patent literature and non-patent literature.

- **Rule**: Use BOTH `search_patents`/`fetch_patents` and `search_papers`/`fetch_paper` for every prior art investigation.
- **Rationale**: Comprehensive prior art analysis requires checking academic papers, conference proceedings, and technical publications alongside patents.
- **Requirement**: Document search results from both sources in the final report.

## III. Evidence-Based Reporting

Every assertion in a report MUST be backed by specific citations.

- **Rule**: Never say "This feature is known."
- **Requirement**: Say "This feature is disclosed in [Patent ID], Column X, Line Y."

## IV. Risk-Averse Screening

When in doubt during screening, err on the side of inclusion.

- **Rule**: If a reference is "borderline", grade it as 'B' (Relevant) rather than 'D' (Noise).
- **Rationale**: Missing a risk is worse than reviewing an extra document.

## V. Breadth of Published Applications

For published applications (not yet granted), assume rights may be broadly secured based on the embodiments.

- **Rule**: Do not judge solely based on current claims.
- **Requirement**: Consider the "Detailed Description" and embodiments as potential scope for future amendments.

## VI. Prior Art Cutoff Date

Prior art searches MUST respect the target patent's effective filing/priority date.

- **Rule**: Prior art search results must be published BEFORE the target's priority date.
- **Requirement**: Use the `--before` flag in `search_patents`/`fetch_patents` or `search_papers`/`fetch_paper` with the correct date (YYYY-MM-DD).

## VII. Search Query Optimization

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

## VIII. Efficient Context Management

Large tool outputs MUST be saved to files to maintain context window efficiency.

- **Rule**: Do NOT load large outputs directly into context.
- **Action**: Save to files and use targeted access (Read tool, jq) when needed.
- **Specifics**: Each skill defines its own file output paths in its instructions.
