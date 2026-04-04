# Prior Art Research - Detailed Instructions

## Multi-Layer Search Strategy

For each patent element, execute a multi-layer search by invoking Skills in parallel.

### Layer 1: General Terminology Search

- **Purpose**: Capture broad technical concepts
- **Keywords**: High-level terms from element description
- **Limit**: 10-20 results
- Invoke: `Skill: google-patent-cli:patent-search` and `Skill: arxiv-cli:arxiv-search` in parallel

### Layer 2: Specific Nomenclature Search

- **Purpose**: Find exact matches using specific technical terms
- **Keywords**: Specific model names, algorithms, parameter names
- **Limit**: 30-50 results (expanded for critical searches)
- Invoke: Same as Layer 1 — multiple Skills in parallel

### Layer 3: Functional/Role-based Search

- **Purpose**: Catch patents describing function rather than specific names
- **Keywords**: "configured to", "means for", functional descriptions
- **Limit**: 10-20 results
- Invoke: Same as Layer 1 — multiple Skills in parallel

## Screening and Analysis

1. **Screen Search Results**:
   - Identify Grade A candidates (highly relevant)
   - Verify publication dates are before priority date
   - For NPL: Invoke `Skill: arxiv-cli:arxiv-fetch` to get full text

2. **Detailed Analysis**:
   - Create claim charts comparing prior art against patent claims
   - Include specific paragraph-level citations
   - Verify evidence quality

## Recording Results

Invoke `Skill: investigation-recording` with the following data for each prior art reference:

- patent_id (target patent)
- claim_number (claim number)
- element_label (element label: A, B, C, etc.)
- reference_id (patent number or arXiv ID)
- reference_type (patent or npl)
- title
- relevance_level (Significant, Moderate, Limited)
- analysis_notes
- publication_date
- claim_chart (if applicable)

## Return Format

Provide a summary report with:

- Patent ID and title
- Number of prior art references found
- Relevance levels for each reference
- Key findings summary
- Overall similarity assessment
