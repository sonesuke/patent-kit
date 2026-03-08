# Database Schema

## Tables

### target_patents

Stores patent master data imported from CSV files.

| Column           | Type    | Description                        |
| ---------------- | ------- | ---------------------------------- |
| patent_id        | TEXT PK | Patent number (e.g., `US1234567A`) |
| title            | TEXT    | Patent title                       |
| country          | TEXT    | Country code                       |
| assignee         | TEXT    | Assignee name                      |
| extra_fields     | TEXT    | Additional data in JSON format     |
| publication_date | TEXT    | Publication date (ISO 8601)        |
| filing_date      | TEXT    | Filing date (ISO 8601)             |
| grant_date       | TEXT    | Grant date (ISO 8601)              |
| created_at       | TEXT    | Record creation timestamp          |
| updated_at       | TEXT    | Last update timestamp              |

**Constraints**:

- `patent_id` must not contain hyphens (`-`), underscores (`_`), or spaces
- `patent_id` must be 9-15 characters (country + year/month/number + kind)
- `patent_id` must be non-empty
- Date columns (`publication_date`, `filing_date`, `grant_date`) must be in ISO 8601 format (`YYYY-MM-DD`) or NULL

### screened_patents

Stores latest screening results only (no history tracking).

| Column        | Type          | Description                                      |
| ------------- | ------------- | ------------------------------------------------ |
| patent_id     | TEXT PK       | Patent number (FK to target_patents.patent_id)   |
| judgment      | TEXT NOT NULL | Judgment: `relevant`, `irrelevant`, or `expired` |
| reason        | TEXT NOT NULL | Screening rationale                              |
| abstract_text | TEXT NOT NULL | Abstract content (fetched during screening)      |
| screened_at   | TEXT          | Screening timestamp                              |
| updated_at    | TEXT          | Last update timestamp                            |

**Constraints**:

- `patent_id` is a FOREIGN KEY referencing `target_patents(patent_id)` with `ON DELETE CASCADE`
- `judgment` only allows: `relevant`, `irrelevant`, `expired`
- `reason` and `abstract_text` must NOT be NULL

### claims

Stores patent claims analyzed during evaluation phase.

| Column       | Type    | Description                                           |
| ------------ | ------- | ----------------------------------------------------- |
| patent_id    | TEXT PK | Patent number (FK to screened_patents.patent_id)      |
| claim_id     | TEXT PK | Claim ID from patent data (e.g., `clm-1`, `CLM-0001`) |
| claim_number | INTEGER | Claim sequence number                                 |
| claim_type   | TEXT    | Claim type: `independent` or `dependent`              |
| claim_text   | TEXT    | Full text of the claim                                |
| created_at   | TEXT    | Record creation timestamp                             |
| updated_at   | TEXT    | Last update timestamp                                 |

**Constraints**:

- **Primary Key**: `(patent_id, claim_id)` - ensures unique claim_id per patent
- `patent_id` is a FOREIGN KEY referencing `screened_patents(patent_id)` with `ON DELETE CASCADE`
- `claim_id` uses actual claim ID from patent data (not auto-increment) for traceability
- `claim_type` only allows: `independent`, `dependent`

### elements

Stores constituent elements of claims analyzed during evaluation phase.

| Column              | Type       | Description                                              |
| ------------------- | ---------- | -------------------------------------------------------- |
| id                  | INTEGER PK | Auto-increment primary key                               |
| patent_id           | TEXT       | Patent number (FK to screened_patents.patent_id)         |
| claim_id            | TEXT       | Claim ID (part of composite FK to claims with patent_id) |
| element_label       | TEXT       | Element label (e.g., A, B, C...)                         |
| element_description | TEXT       | Description of the constituent element                   |
| created_at          | TEXT       | Record creation timestamp                                |
| updated_at          | TEXT       | Last update timestamp                                    |

**Constraints**:

- `patent_id` is a FOREIGN KEY referencing `screened_patents(patent_id)` with `ON DELETE CASCADE`
- `(patent_id, claim_id)` is a composite FOREIGN KEY referencing `claims(patent_id, claim_id)` with `ON DELETE CASCADE`
- `element_description` must NOT be NULL

## Views

### v_screening_progress

Aggregates screening statistics.

| Column         | Type    | Description                                 |
| -------------- | ------- | ------------------------------------------- |
| total_targets  | INTEGER | Count of all patents in target_patents      |
| total_screened | INTEGER | Count of all patents in screened_patents    |
| relevant       | INTEGER | Count of patents with judgment='relevant'   |
| irrelevant     | INTEGER | Count of patents with judgment='irrelevant' |
| expired        | INTEGER | Count of patents with judgment='expired'    |

## Triggers

### update_target_patents_timestamp

Automatically updates `updated_at` when a row in `target_patents` is modified.

### update_screened_patents_timestamp

Automatically updates `updated_at` when a row in `screened_patents` is modified.

## Relationships

```
target_patents (1) -----> (1) screened_patents (1) -----> (*) claims (1) -----> (*) elements
     |                            |                            |                    |
     |-- patent_id (PK)            |-- patent_id (PK, FK)        |-- patent_id (FK)     |-- patent_id (FK)
     |-- title                     |-- judgment                  |-- id (PK, claim_id) |-- claim_id (FK)
     |-- country                   |-- reason                    |-- claim_number       |-- id (PK)
     |-- assignee                  |-- abstract_text             |-- claim_type         |-- element_label
     |-- extra_fields              |-- screened_at               |-- claim_text         |-- element_description
     |-- publication_date          |-- updated_at                |-- created_at         |-- created_at
     |-- filing_date               |                            |-- updated_at         |-- updated_at
     |-- grant_date                |
     |-- created_at                |
     |-- updated_at                |
```

**Legend**:

- `(1)`: One-to-one relationship
- `(*)`: One-to-many relationship
- `PK`: Primary Key
- `FK`: Foreign Key

## Column Naming Convention

All patent identifiers use `patent_id`:

| Table            | Column    | Description            |
| ---------------- | --------- | ---------------------- |
| target_patents   | patent_id | Patent number (PK)     |
| screened_patents | patent_id | Patent number (PK, FK) |

## Upsert Behavior

`INSERT OR REPLACE` on `screened_patents`:

- Same patent re-screened → **Overwrites** (no history)
- Previous screening result is lost
- Only latest judgment is kept
