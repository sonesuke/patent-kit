# Scene: Import CSV Files

## Purpose

Import patent data from CSV files into the `target_patents` table.

**⚠️ IMPORTANT: Follow the steps below in order to import CSV data correctly.**

CSV files require ETL (Extract, Transform, Load) processing before import. Direct `.import` to `target_patents` will fail due to:

- **CHECK constraint violations**: Patent IDs contain hyphens (e.g., `US-2024-2-92070-A1`) that violate format constraints
- **Data format inconsistencies**: Patent IDs need normalization (e.g., US month zero padding: `US-2024-2-92070-A1` → `US20240292070A1`)
- **Schema requirements**: Target table has specific column order and data types

This instruction provides a **step-by-step procedure** that must be followed exactly:
1. Inspect CSV structure
2. Create import table
3. Import raw CSV data
4. Transform and insert into target_patents (ETL)
5. Clean up import table

**Note**: Database initialization should be done before this procedure (see SKILL.md).

## Import Procedure

### Step 1: Inspect CSV Structure

**Purpose**: Identify column mapping and ETL requirements.

```bash
# Check first 10 rows to identify data patterns
head -n 10 test-patents.csv

# Count columns
head -n 1 test-patents.csv | awk -F',' '{print NF}'
```

**Expected Output**:
- **Data starts at**: Row 3 (skip 2 rows: search URL + header)
- **Column mapping**:
  - col1 = id (patent_id with hyphens)
  - col2 = title
  - col3 = assignee
  - col4 = inventor/author
  - col5 = priority date
  - col6 = filing/creation date
  - col7 = publication date
  - col8 = grant date
  - col9 = result link
  - col10 = representative figure link

- **ETL requirements**:
  - col1: Remove hyphens, normalize US month zero-padding (e.g., `US-2024-2-92070-A1` → `US20240292070A1`)
  - col2, col3, col4: Trim whitespace
  - col5, col6, col7, col8: Convert to date format
  - col9, col10: Keep as-is or store in extra_fields

### Step 2: Create Import Table

**Based on column mapping from Step 1**, create an import table to store raw CSV data:

```bash
sqlite3 patents.db <<'EOF'
DROP TABLE IF EXISTS raw_import;
CREATE TABLE raw_import (
    col1 TEXT,  -- id (patent_id with hyphens) → needs ETL in Step 4
    col2 TEXT,  -- title → needs trim in Step 4
    col3 TEXT,  -- assignee → needs trim in Step 4
    col4 TEXT,  -- inventor/author → needs trim in Step 4
    col5 TEXT,  -- priority date → needs date() in Step 4
    col6 TEXT,  -- filing/creation date → needs date() in Step 4
    col7 TEXT,  -- publication date → needs date() in Step 4
    col8 TEXT,  -- grant date → needs date() in Step 4
    col9 TEXT,  -- result link → keep as-is
    col10 TEXT  -- representative figure link → keep as-is
);
EOF
```

**Note**: Column names (col1, col2, ...) match Step 1 findings. ETL transformations will be applied in Step 4.

### Step 3: Import CSV to Import Table

**Based on Step 1 findings** (data starts at Row 3), skip first 2 rows (search URL + header):

```bash
sqlite3 patents.db <<'EOF'
.mode csv
.import --skip 2 ./test-patents.csv raw_import
EOF
```

**Skip calculation**: Row 3 - 1 = skip 2 rows (0-indexed)

**Verification**: Confirm import succeeded:
```bash
sqlite3 patents.db "SELECT COUNT(*) FROM raw_import;"
```

### Step 4: Transform and Insert (ETL)

```bash
sqlite3 patents.db <<'EOF'
INSERT OR IGNORE INTO target_patents (
    patent_id,
    title,
    assignee,
    country,
    publication_date,
    filing_date,
    grant_date,
    extra_fields
)
SELECT
    -- CRITICAL: Normalize patent_id for Google Patents format
    --
    -- Parse ORIGINAL format (with hyphens) BEFORE removing them to preserve boundaries.
    -- This allows us to correctly identify where month zero padding is needed.
    --
    -- Format examples (with hyphens → transformed):
    -- US: US-2024292070-A1 (16 chars) → US20240292070A1 (month zero padded)
    -- KR: KR-102637029-B1 (14 chars) → KR102637029B1 (just remove hyphens)
    -- WO: WO-2025073197-A1 (15 chars) → WO2025073197A1 (just remove hyphens)
    -- CA: CA-3234744-A1 (12 chars) → CA3234744A1 (just remove hyphens)
    -- JP: JP-7753310-B2 (12 chars) → JP7753310B2 (just remove hyphens)
    -- HK: HK-40120585-A (12 chars) → HK40120585A (just remove hyphens)
    --
    CASE
      -- US Patent ID Normalization Rules
      --
      -- Valid US patent ID formats (no hyphens, no spaces):
      -- 1. US + 6-digit serial + kind code (e.g., US12405982B2 - 12 chars)
      -- 2. US + 4-digit year + 2-digit month + 5-6 digit serial + kind code (e.g., US20240289545A1 - 15 chars)
      --
      -- Input patterns from Google Patents CSV:
      -- 1. US-YYYY-M-NNNNN-KK (16 chars with hyphens, single-digit month) → needs month zero padding
      --    Example: US-2024-2-92070-A1 → US20240292070A1
      -- 2. US-NNNNNNN-KK (14 chars with hyphens, already correct) → just remove hyphens
      --    Example: US-12405982-B2 → US12405982B2
      -- 3. USNNNNNNNNNKK (12-15 chars, no hyphens) → already correct, use as-is
      --    Example: US12405982B2, US20240289545A1
      --
      WHEN substr(upper(trim(replace(col1, ' ', ''))), 1, 2) = 'US'
           AND length(trim(replace(col1, ' ', ''))) = 16 THEN
        -- Parse: US-YYYY-M-NNNNN-KK → insert 0 after month digit
        -- Positions: 1-2=US, 3=-, 4-7=YYYY, 8=M, 9-13=NNNNN, 14=-, 15-16=KK
        substr(upper(trim(replace(col1, ' ', ''))), 1, 2) ||    -- US
        substr(upper(trim(replace(col1, ' ', ''))), 4, 4) ||    -- YYYY (year)
        '0' ||                                                           -- 0 (month padding)
        substr(upper(trim(replace(col1, ' ', ''))), 8, 1) ||     -- M (single-digit month)
        substr(upper(trim(replace(col1, ' ', ''))), 9, 5) ||     -- NNNNN (serial number)
        substr(upper(trim(replace(col1, ' ', ''))), 15, 100)     -- KK (kind code)

      -- All other US formats: just remove hyphens (for 14-char and already-clean formats)
      WHEN substr(upper(trim(replace(col1, ' ', ''))), 1, 2) = 'US' THEN
        replace(upper(trim(replace(col1, ' ', ''))), '-', '')

      -- All other countries: just remove hyphens
      ELSE replace(upper(trim(replace(col1, ' ', ''))), '-', '')
    END as patent_id,
    trim(col2) as title,
    trim(col3) as assignee,
    substr(upper(trim(replace(col1, ' ', ''))), 1, 2) as country,
    date(col7) as publication_date,
    NULLIF(date(col6), NULL) as filing_date,
    NULLIF(date(col8), NULL) as grant_date,
    '{"source": "csv"}' as extra_fields
  FROM raw_import
  WHERE col1 IS NOT NULL
    AND col1 != '';
EOF
```

### Step 5: Drop Import Table

```bash
sqlite3 patents.db "DROP TABLE raw_import;"
```

**This ETL script handles:**
- ✅ Google Patents CSV format (10 columns)
- ✅ US patent month zero padding (e.g., US-2024-2-92070-A1 → US20240292070A1)
- ✅ All other patent formats (KR, JP, CN, WO, CA, HK, etc.)
- ✅ Hyphen removal and normalization
- ✅ Date validation and formatting
