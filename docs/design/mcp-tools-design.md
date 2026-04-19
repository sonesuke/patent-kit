# patent-kit MCP Tool Design

## Architecture

```
Skills (LLM: judgment/interpretation only)
  ↓
MCP: patent-kit (Rust)
  ├── google-patent-cli crate → Google Patents
  ├── arxiv-cli crate        → arXiv
  └── rusqlite               → patents.db
```

### Design Principles

1. **MCP handles all data operations**: fetch, parse, store, query
2. **LLM handles judgment only**: relevance, element decomposition, similarity analysis
3. **No external API calls during LLM turns**: data is pre-loaded into DB
4. **Skill instructions are minimal**: just "call this tool, interpret, call that tool"
5. **One patent at a time**: `get_unanalyzed` returns a single patent to avoid context overload

---

## Schema

```
patents (PK: patent_id)
  ├── screened_patents (FK: patent_id) — judgment: relevant | irrelevant
  ├── claims (FK: patent_id, PK: patent_id + claim_number)
  │   └── elements (FK: patent_id + claim_number, PK: patent_id + claim_number + element_label)
  │       └── similarities (FK: patent_id + claim_number + element_label)
  └── prior_art_elements (FK: patent_id + claim_number + element_label)

features (standalone, PK: feature_id)
prior_arts (standalone, PK: reference_id)
  └── prior_art_elements (FK: reference_id)
```

---

## Tool Reference

### Database Management

#### `import_csv`

Import patents from a Google Patents CSV file into the `patents` table.

```json
{ "tool": "import_csv", "arguments": { "file_path": "csv/search_results.csv" } }
```

Returns: `"Imported 150 patents from csv/search_results.csv"`

---

### Patent Indexing

#### `index_patents`

Find all patents in `patents` that have no entry in `screened_patents`, fetch their details (abstract, legal status, claims) from Google Patents, and store in database. Runs as a background thread — returns immediately with a count.

```json
{ "tool": "index_patents", "arguments": {} }
```

Returns: `"Indexed 150 patents (0 errors)"`

#### `stop_indexing`

Stop the background indexing process if it is running.

```json
{ "tool": "stop_indexing", "arguments": {} }
```

Returns: `"Indexing stopped"` or `"No indexing in progress"`

---

### Patent Search & Fetch

#### `search_patents`

Search Google Patents. Used in targeting phase. Returns summary only (no claims).

```json
{
  "tool": "search_patents",
  "arguments": {
    "query": "\"smartphone\" AND \"gesture\"",
    "assignee": ["Apple Inc."],
    "country": "US",
    "limit": 20
  }
}
```

Returns:

```json
{
  "total_results": "1234",
  "top_assignees": [{ "name": "Apple Inc.", "percentage": "15%" }],
  "top_cpcs": [{ "name": "G06F", "percentage": "45%" }],
  "patents": [
    { "id": "US1234567A1", "title": "...", "snippet": "...", "assignee": "Apple Inc.", "url": "..." }
  ]
}
```

#### `check_assignee`

Discover assignee name variations in patent databases.

```json
{ "tool": "check_assignee", "arguments": { "assignee": "Google" } }
```

Returns: `"Assignee variations for 'Google' (3):\n  - Google LLC (85%)\n  - Google Inc. (10%)\n  - Alphabet Inc. (5%)"`

---

### Paper Search & Fetch

#### `search_papers`

Search arXiv. Used in prior-art-researching.

```json
{ "tool": "search_papers", "arguments": { "query": "neural network pruning", "limit": 20 } }
```

Returns:

```json
[{ "id": "2301.00001", "title": "...", "authors": [...], "summary": "...", "published_date": "2023-01-01", "url": "..." }]
```

#### `fetch_paper`

Fetch a single paper from arXiv with full details.

```json
{ "tool": "fetch_paper", "arguments": { "id": "2301.00001" } }
```

Returns:

```json
{
  "id": "2301.00001", "title": "...", "authors": [...], "summary": "...",
  "published_date": "2023-01-01", "url": "...", "pdf_url": "...",
  "description_paragraphs": [{ "number": "0001", "text": "..." }]
}
```

---

### Screening

#### `get_unscreened`

Get patents that have been indexed (abstract available) but not yet judged. Returns abstract_text so LLM can judge immediately. Includes `total_remaining` count and `unindexed_count` for patents not yet fetched.

```json
{ "tool": "get_unscreened", "arguments": { "limit": 10 } }
```

Returns:

```json
{
  "patents": [
    { "patent_id": "US1234567A1", "title": "...", "assignee": "...", "abstract_text": "..." }
  ],
  "total_remaining": 42,
  "unindexed_count": 0
}
```

#### `screen_patent`

Record LLM's relevance judgment. Only `judgment` and `reason` come from LLM.

```json
{
  "tool": "screen_patent",
  "arguments": {
    "patent_id": "US1234567A1",
    "judgment": "relevant",
    "reason": "Describes gesture-based UI for mobile devices."
  }
}
```

Returns: `"Patent US1234567A1 screened: relevant"`

---

### Claim Analysis

#### `get_unanalyzed`

Get the next patent that needs analysis. Returns exactly 1 patent. The `needs` field indicates whether the patent needs element decomposition (`"elements"`) or similarity recording (`"similarities"`). Priority: patents needing elements > patents needing similarities.

```json
{ "tool": "get_unanalyzed", "arguments": {} }
```

Returns:

```json
"US1234567A1 — Title — needs: elements"
```

or `"All patents have been analyzed."` when complete.

#### `get_claims`

Get claims for a patent. Optionally filter by decomposition status.

```json
{ "tool": "get_claims", "arguments": { "patent_id": "US1234567A1", "decomposed": false } }
```

Parameters:
- `patent_id` (required)
- `decomposed` (optional): `false` = claims with no elements yet, `true` = claims with elements, omitted = all

Returns:

```json
[
  { "patent_id": "US1234567A1", "claim_number": 1, "claim_type": "independent", "claim_text": "1. A method comprising: ..." },
  { "patent_id": "US1234567A1", "claim_number": 2, "claim_type": "dependent", "claim_text": "2. The method of claim 1, ..." }
]
```

#### `record_claims`

Record claims extracted from a patent. Typically used by `index_patents` but available for manual entry.

```json
{
  "tool": "record_claims",
  "arguments": {
    "patent_id": "US1234567A1",
    "claims": [
      { "claim_number": 1, "claim_type": "independent", "claim_text": "1. A method comprising: ..." }
    ]
  }
}
```

#### `record_elements`

Store LLM's element decomposition results.

```json
{
  "tool": "record_elements",
  "arguments": {
    "elements": [
      { "patent_id": "US1234567A1", "claim_number": 1, "element_label": "Element A", "element_description": "A gesture recognition module that detects touch patterns" },
      { "patent_id": "US1234567A1", "claim_number": 1, "element_label": "Element B", "element_description": "A mapping engine that translates gestures to commands" }
    ]
  }
}
```

Returns: `"Recorded 2 elements for US1234567A1"`

#### `get_elements`

Get elements for a patent. Optionally filter by claim number and analysis status.

```json
{ "tool": "get_elements", "arguments": { "patent_id": "US1234567A1", "analyzed": false } }
```

Parameters:
- `patent_id` (required)
- `claim_number` (optional): filter by specific claim
- `analyzed` (optional): `false` = elements with no similarities yet, `true` = elements with similarities, omitted = all

Returns:

```json
[
  { "patent_id": "US1234567A1", "claim_number": 1, "element_label": "Element A", "element_description": "A gesture recognition module..." },
  { "patent_id": "US1234567A1", "claim_number": 1, "element_label": "Element B", "element_description": "A mapping engine..." }
]
```

#### `get_product_features`

Get all product-level features.

```json
{ "tool": "get_product_features", "arguments": {} }
```

Returns:

```json
[
  { "feature_id": 1, "feature_name": "Gesture Recognition", "description": "Detects multi-touch gestures", "category": "Input", "presence": "present" }
]
```

#### `record_product_feature`

Record a single product-level feature.

```json
{
  "tool": "record_product_feature",
  "arguments": {
    "feature_name": "Gesture Recognition",
    "description": "Detects multi-touch gestures",
    "category": "Input",
    "presence": "present"
  }
}
```

#### `record_similarities`

Store LLM's similarity analysis results per element.

```json
{
  "tool": "record_similarities",
  "arguments": {
    "similarities": [
      {
        "patent_id": "US1234567A1",
        "claim_number": 1,
        "element_label": "Element A",
        "similarity_level": "Significant",
        "analysis_notes": "Product uses the same accelerometer-based approach described in the claim."
      }
    ]
  }
}
```

---

### Prior Art Research

#### `get_unresearched`

Get patents with Significant/Moderate similarities that have no prior arts recorded.

```json
{ "tool": "get_unresearched", "arguments": { "limit": 5 } }
```

Returns:

```json
{
  "items": [{ "patent_id": "US1234567A1", "title": "...", "element_count": 3 }],
  "total_remaining": 8
}
```

#### `record_prior_arts`

Store prior art references with element-level claim charts.

```json
{
  "tool": "record_prior_arts",
  "arguments": {
    "prior_arts": [
      {
        "reference_id": "US9876543B2",
        "reference_type": "patent",
        "title": "Touch gesture recognition system",
        "publication_date": "2018-06-15",
        "elements": [
          {
            "patent_id": "US1234567A1",
            "claim_number": 1,
            "element_label": "Element A",
            "relevance_level": "Significant",
            "analysis_notes": "Discloses accelerometer-based gesture detection...",
            "claim_chart": "Element A → Col. 5, lines 10-25: 'The sensor module detects...'"
          }
        ]
      }
    ]
  }
}
```

---

### Reporting

#### `get_progress`

Get investigation progress summary.

```json
{ "tool": "get_progress", "arguments": {} }
```

Returns:

```json
{
  "total_targets": 150,
  "total_screened": 120,
  "relevant": 35,
  "irrelevant": 85,
  "expired": 3
}
```

#### `get_patent_detail`

Get full detail of a patent from the database.

```json
{ "tool": "get_patent_detail", "arguments": { "patent_id": "US1234567A1" } }
```

Returns:

```json
{
  "patent_id": "US1234567A1",
  "title": "...",
  "assignee": "Apple Inc.",
  "country": "US",
  "publication_date": "2020-01-15",
  "filing_date": "2019-01-15",
  "grant_date": "2021-06-01",
  "judgment": "relevant",
  "legal_status": "Active",
  "reason": "...",
  "abstract_text": "..."
}
```

---

## Workflow Summary

### Targeting (LLM: interactive search)

```
search_patents(assignee, keywords, dates)  ← LLM iterates queries with user
check_assignee(name)                        ← verify assignee names
→ User downloads CSV
import_csv(file_path)                       ← one-time
```

### Screening (LLM: relevance judgment only)

```
index_patents()                             ← MCP: fetch all + store claims (background)
get_unscreened(limit: 10)                   ← returns id + abstract + remaining counts
LLM: read abstract → judge
screen_patent(id, judgment, reason)          ← loop
```

### Claim Analysis — Elements (LLM: element decomposition)

```
get_unanalyzed()                            ← returns 1 patent, needs: "elements"
get_claims(patent_id, decomposed: false)    ← un-decomposed claims
LLM: decompose into elements
record_elements(elements)                   ← loop per claim
→ get_unanalyzed() again (same patent, needs: "similarities")
```

### Claim Analysis — Similarities (LLM: similarity assessment)

```
get_unanalyzed()                            ← returns 1 patent, needs: "similarities"
get_elements(patent_id, analyzed: false)    ← un-analyzed elements
get_product_features()                      ← existing features
LLM: compare features vs elements → ask user if needed
record_product_feature(...)                 ← if new features discovered
record_similarities(similarities)           ← per element
→ Skill: legal-checking                     ← compliance review
→ get_unanalyzed() again (next patent or "All analyzed")
```

### Prior Art Research (LLM: search + analysis)

```
get_unresearched(limit: 5)
search_patents(query, dates)                ← per element
search_papers(query, dates)                 ← per element
fetch_paper(id)                             ← for NPL candidates
LLM: create claim charts
record_prior_arts(prior_arts)
```

### Reporting (LLM: template formatting)

```
get_progress()                              ← overall statistics
get_patent_detail(patent_id)               ← per-patent report
LLM: format report using template
```

---

## Tool Summary (19 tools)

| Category       | Tool                    | LLM Involvement      |
| -------------- | ----------------------- | -------------------- |
| DB Management  | `import_csv`            | None                 |
| Indexing       | `index_patents`         | None (background)    |
| Indexing       | `stop_indexing`         | None                 |
| Search         | `search_patents`        | Query crafting       |
| Search         | `check_assignee`        | None                 |
| Search         | `search_papers`         | Query crafting       |
| Fetch          | `fetch_paper`           | None                 |
| Screening      | `get_unscreened`        | None                 |
| Screening      | `screen_patent`         | Judgment only        |
| Claim Analysis | `get_unanalyzed`        | None                 |
| Claim Analysis | `get_claims`            | None                 |
| Claim Analysis | `record_claims`         | None (data from LLM) |
| Claim Analysis | `record_elements`       | None (data from LLM) |
| Claim Analysis | `get_elements`          | None                 |
| Claim Analysis | `get_product_features`  | None                 |
| Claim Analysis | `record_product_feature`| None (data from LLM) |
| Claim Analysis | `record_similarities`   | None (data from LLM) |
| Prior Art      | `get_unresearched`      | None                 |
| Prior Art      | `record_prior_arts`     | None (data from LLM) |
| Reporting      | `get_progress`          | None                 |
| Reporting      | `get_patent_detail`     | None                 |
