# Targeting Report / Search Queries

## 1. Scope Definition

- **Product Concept**: (Summarize the refined concept)
- **Target Country**: ...
- **Target Release Date**: ...
- **Priority Date Cutoff**: ...

## 2. Competitor Verification

- **User Input**: (List provided names)
- **Verified Assignee Names (Canonicalized)**:

  | Canonical Name | Variants Found in DB | Verified? | Notes |
  |---|---|---|---|
  | (e.g. Google LLC) | (e.g. Google Inc., GOOGLE LLC) | Yes | Main assignee |

  **Decision**: Use all verified variants in assignee filter.

## Competitor Patent Research

**Objective**:  
Identify patents filed by direct competitors that may overlap with the product concept or reveal defensive filing strategies.

## Market Patent Research

**Objective**:  
Identify non-competitor prior art and industry-wide technical solutions relevant to the product concept.

## Validation & Adjustment Log

| Research Type | Initial Results (Top 20) | Noise Cause | Adjustment | Result Count | Final Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Competitor Patent Research | ... | ... | ... | ... |  |
| Market Patent Research | ... | ... | ... | ... | ... |

## Final Optimized Queries

### Competitor Patent Research (Target: < 1000 hits)

- **Query**: `...`
- **Hit Count**: ...
- **Included Keywords**: "X", "Y"
- **Excluded Noise**: "Z"
- **Rationale**: Why this query is considered optimal

### Market Patent Research (Target: < 1000 hits)

- **Query**: `...`
- **Hit Count**: ...
- **Included Keywords**: "X", "Y"
- **Excluded Noise**: "Z"
- **Rationale**: Why this query is considered optimal

## Google Patent UI Queries

Copy and paste these queries directly into [Google Patents](https://patents.google.com/).

> [!IMPORTANT]
> **Formatting Rules**:
> 
> 1. **Order**: Keywords MUST be placed **at the beginning** of the query string.
> 2. **Keywords**: MUST be quoted (e.g., `"smartphone"`).
> 3. **Assignees**: MUST be quoted and space-separated keys (e.g., `assignee:"Google LLC" assignee:"Microsoft Corp"`).
> 4. **Country/Language**: If a country is specified, the language MUST also be specified (e.g., `country:JP language:JAPANESE`, `country:CN language:CHINESE`).

### Competitor Patent Research

```text
(Paste query string here)
```

### Market Patent Research

```text
(Paste query string here)
```
