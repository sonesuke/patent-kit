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

---

## Tool Reference

### Database Management

#### `init_database`

Initialize `patents.db` with schema. Idempotent — safe to call multiple times.

```json
{ "tool": "init_database", "arguments": {} }
```

Returns: `{ tables: ["target_patents", "screened_patents", "claims", "elements", "similarities", "features", "prior_arts"] }`

#### `import_csv`

Import CSV files from Google Patents into `target_patents` table.

```json
{ "tool": "import_csv", "arguments": { "paths": ["csv/search_results.csv"] } }
```

Returns: `{ imported: 150 }`

---

### Patent Indexing

#### `index_patent`

Fetch a single patent from Google Patents and store in DB. Stores:

- `screened_patents`: abstract_text, legal_status (judgment = NULL → unscreened)
- `claims`: all claims with number, text, claim_type

No LLM involvement. Returns abstract_text so the caller can immediately judge.

```json
{ "tool": "index_patent", "arguments": { "patent_id": "US1234567A1" } }
```

Returns:

```json
{
  "patent_id": "US1234567A1",
  "title": "...",
  "abstract_text": "...",
  "legal_status": "Pending",
  "assignee": "Google LLC",
  "claims_indexed": 18
}
```

#### `index_patents`

Find all patents in `target_patents` that have no entry in `screened_patents`, and index them automatically (batch version of `index_patent`). Processes sequentially with error handling.

```json
{ "tool": "index_patents", "arguments": {} }
```

Returns: `{ indexed: 150, errors: [] }`

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
    "priority_after": "2020-01-01",
    "priority_before": "2025-01-01",
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
    {
      "id": "US1234567A1",
      "title": "...",
      "snippet": "...",
      "assignee": "Apple Inc.",
      "url": "..."
    }
  ]
}
```

#### `check_assignee`

Discover assignee name variations in patent databases.

```json
{ "tool": "check_assignee", "arguments": { "name": "Google" } }
```

Returns: `{ variations: ["Google LLC", "Google Inc.", "Alphabet Inc."] }`

---

### Paper Search & Fetch

#### `search_papers`

Search arXiv. Used in prior-art-researching.

```json
{
  "tool": "search_papers",
  "arguments": {
    "query": "neural network pruning",
    "limit": 20,
    "before": "2023-01-01"
  }
}
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
  "id": "2301.00001",
  "title": "...",
  "authors": [...],
  "summary": "...",
  "published_date": "2023-01-01",
  "url": "...",
  "pdf_url": "...",
  "description_paragraphs": [{ "number": "0001", "text": "..." }]
}
```

---

### Screening

#### `get_unscreened_patents`

Get patents that have been indexed (abstract available) but not yet judged. Returns abstract_text so LLM can judge immediately.

```json
{ "tool": "get_unscreened_patents", "arguments": { "limit": 10 } }
```

Returns:

```json
[
  {
    "patent_id": "US1234567A1",
    "title": "...",
    "abstract_text": "...",
    "legal_status": "Pending",
    "assignee": "..."
  },
  {
    "patent_id": "US9876543B2",
    "title": "...",
    "abstract_text": "...",
    "legal_status": "Active",
    "assignee": "..."
  }
]
```

#### `screen_patent`

Record LLM's relevance judgment. Only `judgment` and `reason` come from LLM.

```json
{
  "tool": "screen_patent",
  "arguments": {
    "patent_id": "US1234567A1",
    "judgment": "relevant",
    "reason": "Describes gesture-based UI for mobile devices, directly relevant to target product."
  }
}
```

---

### Evaluation

#### `get_unevaluated_patents`

Get relevant patents that have claims but no elements. Returns claim_count so LLM knows the workload.

```json
{ "tool": "get_unevaluated_patents", "arguments": { "limit": 5 } }
```

Returns:

```json
[{ "patent_id": "US1234567A1", "title": "...", "claim_count": 12 }]
```

#### `get_claims`

Get claims for a patent. Used by LLM for element decomposition.

```json
{ "tool": "get_claims", "arguments": { "patent_id": "US1234567A1" } }
```

Returns:

```json
[
  {
    "claim_number": 1,
    "claim_type": "independent",
    "claim_text": "1. A method comprising: ..."
  },
  {
    "claim_number": 2,
    "claim_type": "dependent",
    "claim_text": "2. The method of claim 1, ..."
  }
]
```

#### `record_elements`

Store LLM's element decomposition results.

```json
{
  "tool": "record_elements",
  "arguments": {
    "patent_id": "US1234567A1",
    "elements": [
      {
        "claim_number": 1,
        "label": "A",
        "description": "A gesture recognition module that detects touch patterns"
      },
      {
        "claim_number": 1,
        "label": "B",
        "description": "A mapping engine that translates gestures to commands"
      },
      {
        "claim_number": 1,
        "label": "C",
        "description": "A command executor that performs mapped operations"
      }
    ]
  }
}
```

---

### Claim Analysis

#### `get_unanalyzed_patents`

Get patents that have elements but no similarities.

```json
{ "tool": "get_unanalyzed_patents", "arguments": { "limit": 5 } }
```

Returns:

```json
[{ "patent_id": "US1234567A1", "title": "...", "element_count": 9 }]
```

#### `get_elements`

Get elements for a patent.

```json
{ "tool": "get_elements", "arguments": { "patent_id": "US1234567A1" } }
```

Returns:

```json
[
  {
    "claim_number": 1,
    "label": "A",
    "description": "A gesture recognition module..."
  },
  { "claim_number": 1, "label": "B", "description": "A mapping engine..." }
]
```

#### `query_features`

Search product features by keyword matching against feature_name and description.

```json
{ "tool": "query_features", "arguments": { "search_term": "gesture" } }
```

Returns:

```json
[
  {
    "feature_name": "Gesture Recognition",
    "description": "...",
    "category": "Input",
    "presence": "present"
  }
]
```

#### `record_features`

Store product features (from concept-interviewing or user input).

```json
{
  "tool": "record_features",
  "arguments": {
    "features": [
      {
        "name": "Gesture Recognition",
        "description": "Detects multi-touch gestures",
        "category": "Input",
        "presence": "present"
      }
    ]
  }
}
```

#### `record_similarities`

Store LLM's similarity analysis results.

```json
{
  "tool": "record_similarities",
  "arguments": {
    "patent_id": "US1234567A1",
    "similarities": [
      {
        "claim_number": 1,
        "element_label": "A",
        "similarity_level": "Significant",
        "analysis_notes": "Product's gesture recognition module uses the same accelerometer-based approach described in the claim."
      }
    ]
  }
}
```

---

### Prior Art Research

#### `get_unresearched_patents`

Get patents with Moderate/Significant similarities that have no prior art recorded.

```json
{ "tool": "get_unresearched_patents", "arguments": { "limit": 5 } }
```

Returns:

```json
[{ "patent_id": "US1234567A1", "title": "...", "high_similarity_count": 3 }]
```

#### `record_prior_arts`

Store prior art references with element-level claim charts.

```json
{
  "tool": "record_prior_arts",
  "arguments": {
    "patent_id": "US1234567A1",
    "prior_arts": [
      {
        "claim_number": 1,
        "element_label": "A",
        "reference_id": "US9876543B2",
        "reference_type": "patent",
        "title": "Touch gesture recognition system",
        "relevance_level": "Significant",
        "publication_date": "2018-06-15",
        "analysis_notes": "Discloses accelerometer-based gesture detection...",
        "claim_chart": "Element A → Col. 5, lines 10-25: 'The sensor module detects...'"
      }
    ]
  }
}
```

---

### Reporting

#### `get_progress`

Get workflow progress statistics for all phases.

```json
{ "tool": "get_progress", "arguments": {} }
```

Returns:

```json
{
  "screening": {
    "total": 150,
    "screened": 120,
    "relevant": 35,
    "irrelevant": 85
  },
  "evaluation": { "total": 35, "completed": 20, "remaining": 15 },
  "claim_analysis": { "total": 20, "completed": 12, "remaining": 8 },
  "prior_art": { "total": 8, "completed": 3, "remaining": 5 }
}
```

#### `get_patent_detail`

Get all data for a specific patent (used for reporting).

```json
{ "tool": "get_patent_detail", "arguments": { "patent_id": "US1234567A1" } }
```

Returns:

```json
{
  "screening": {
    "judgment": "relevant",
    "reason": "...",
    "legal_status": "...",
    "abstract_text": "..."
  },
  "claims": [
    { "claim_number": 1, "claim_type": "independent", "claim_text": "..." }
  ],
  "elements": [{ "claim_number": 1, "label": "A", "description": "..." }],
  "similarities": [
    {
      "claim_number": 1,
      "element_label": "A",
      "similarity_level": "...",
      "analysis_notes": "..."
    }
  ],
  "prior_arts": [
    {
      "reference_id": "...",
      "reference_type": "patent",
      "title": "...",
      "relevance_level": "..."
    }
  ]
}
```

---

## Workflow Summary

### Targeting (LLM: interactive search)

```
search_patents(assignee, keywords, dates)  ← LLM iterates queries with user
check_assignee(name)                        ← verify assignee names
→ User downloads CSV
import_csv(paths)                           ← one-time
```

### Screening (LLM: relevance judgment only)

```
index_patents()                              ← MCP: fetch all + store claims
get_unscreened_patents(limit: 10)           ← returns id + abstract
LLM: read abstract → judge
screen_patent(id, judgment, reason)          ← loop
```

### Evaluation (LLM: element decomposition)

```
get_unevaluated_patents(limit: 5)        ← returns id + claim_count
get_claims(patent_id)                       ← read claims
LLM: decompose into elements
record_elements(patent_id, elements)         ← loop per claim
```

### Claim Analysis (LLM: similarity assessment)

```
get_unanalyzed_patents(limit: 5)
get_elements(patent_id)
query_features() / query_features(search_term)
LLM: compare features vs elements → ask user if needed
record_features(features)                    ← if new features discovered
record_similarities(patent_id, similarities)
```

### Prior Art Research (LLM: search + analysis)

```
get_unresearched_patents(limit: 5)
search_patents(query, dates)                 ← per element
search_papers(query, dates)                  ← per element
fetch_patent/paper for Grade A candidates    ← full details
LLM: create claim charts
record_prior_arts(patent_id, prior_arts)
```

### Reporting (LLM: template formatting)

```
get_progress()                               ← overall statistics
get_patent_detail(patent_id)                ← per-patent report
LLM: format report using template
```

---

## Tool Summary (21 tools)

| Category       | Tool                       | LLM Involvement      |
| -------------- | -------------------------- | -------------------- |
| DB Management  | `init_database`            | None                 |
| DB Management  | `import_csv`               | None                 |
| Indexing       | `index_patent`             | None                 |
| Indexing       | `index_patents`            | None                 |
| Search         | `search_patents`           | Query crafting       |
| Search         | `check_assignee`           | None                 |
| Search         | `search_papers`            | Query crafting       |
| Fetch          | `fetch_paper`              | None                 |
| Screening      | `get_unscreened_patents`   | None                 |
| Screening      | `screen_patent`            | Judgment only        |
| Evaluation     | `get_unevaluated_patents`  | None                 |
| Evaluation     | `get_claims`               | None                 |
| Evaluation     | `record_elements`          | None (data from LLM) |
| Claim Analysis | `get_unanalyzed_patents`   | None                 |
| Claim Analysis | `get_elements`             | None                 |
| Claim Analysis | `query_features`           | None                 |
| Claim Analysis | `record_features`          | None (data from LLM) |
| Claim Analysis | `record_similarities`      | None (data from LLM) |
| Prior Art      | `get_unresearched_patents` | None                 |
| Prior Art      | `record_prior_arts`        | None (data from LLM) |
| Reporting      | `get_progress`             | None                 |
| Reporting      | `get_patent_detail`        | None                 |
