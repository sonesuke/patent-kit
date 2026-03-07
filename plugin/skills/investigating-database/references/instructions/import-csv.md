# Scene: Import CSV Files

## Scenario

Import patent data from CSV files into the `target_patents` table.

The CSV files may contain extra columns or have inconsistent formatting. This scene uses SQLite's ETL capabilities to clean and transform the data during import.

## Key Steps

### Step 1: Inspect CSV File

First, examine the CSV file to determine:

1. **Where the CSV data starts** (which row number is the header)
   - This determines how many rows to skip with `.import --skip N`
   - Usually row 1, but may be different if there are empty lines at the top

2. **How many columns the CSV has**
   - This determines how many columns to create in the temporary table
   - The temporary table must match the CSV column count exactly

**Linux/macOS**:

```bash
# Check the header row
head -n 1 patents.csv

# Count total columns (using awk)
head -n 1 patents.csv | awk -F',' '{print NF}'
```

**Windows (PowerShell)**:

```powershell
# Check the header row
Get-Content patents.csv -First 1

# Count total columns
(Get-Content patents.csv -First 1).Split(',').Count
```

**Alternative: Use any text editor** to open the CSV and count columns manually.

### Step 2: Create Temporary Table

Create a temporary table to hold the raw CSV data. All columns are TEXT type to handle any data format.

```sql
-- Adjust column count based on your CSV
CREATE TEMP TABLE raw_import (
    col1 TEXT,
    col2 TEXT,
    col3 TEXT,
    col4 TEXT,
    -- ... add more columns as needed
    colN TEXT
);
```

### Step 3: Import CSV to Temporary Table

Import the CSV file, skipping the header row:

```bash
sqlite3 patents.db <<EOF
.mode csv
.import --skip 1 /path/to/patents.csv raw_import
EOF
```

### Step 4: Transform and Insert into target_patents

Use SQL to extract, clean, transform, and insert data into `target_patents`:

```sql
INSERT INTO target_patents (
    patent_id,
    title,
    country,
    assignee,
    extra_fields,
    publication_date,
    filing_date,
    grant_date
)
SELECT
    -- Clean and normalize patent_id
    replace(trim(col1), ' ', '') as patent_id,  -- Remove spaces
    upper(col2) as title,                         -- Convert to uppercase
    col3 as country,
    col4 as assignee,
    NULL as extra_fields,                          -- Set default values
    -- Normalize date to ISO 8601 format
    date(col5) as publication_date,               -- Validates and formats date
    NULL as filing_date,                          -- Set NULL for missing data
    NULL as grant_date
FROM raw_import
WHERE col1 IS NOT NULL                            -- Filter out invalid rows
  AND date(col5) IS NOT NULL;                     -- Filter out invalid dates
```

**Common Transformations**:

| Transformation                | SQL Example                   | Purpose                          |
| ----------------------------- | ----------------------------- | -------------------------------- |
| Remove hyphens from patent_id | `replace(patent_id, '-', '')` | Standardize patent ID format     |
| Convert to uppercase          | `upper(title)`                | Normalize text case              |
| Trim whitespace               | `trim(column)`                | Remove leading/trailing spaces   |
| Remove spaces                 | `replace(column, ' ', '')`    | Remove internal spaces           |
| Normalize date                | `date(column)`                | Convert to ISO 8601 (YYYY-MM-DD) |
| Handle empty strings          | `NULLIF(column, '')`          | Convert empty string to NULL     |
| Extract year from date        | `strftime('%Y', date_column)` | Get 4-digit year                 |

**Patent ID Normalization Examples**:

The database requires patent IDs in the format `US1234567A` (no hyphens, no spaces). Here are common transformations:

| Input Format    | Output Format | SQL Transformation                                     |
| --------------- | ------------- | ------------------------------------------------------ |
| `US-1234-567-A` | `US1234567A`  | `replace(replace(patent_id, '-', ''), ' ', '')`        |
| `us-1234-567-a` | `US1234567A`  | `upper(replace(replace(patent_id, '-', ''), ' ', ''))` |
| `US 1234 567 A` | `US1234567A`  | `upper(replace(replace(patent_id, ' ', ''), '-', ''))` |
| `US-1234-567`   | `US1234567`   | `replace(replace(patent_id, '-', ''), ' ', '')`        |
| `US1234-567A`   | `US1234567A`  | `replace(patent_id, '-', '')`                          |
| `US1234 567A`   | `US1234567A`  | `replace(patent_id, ' ', '')`                          |

**Recommended Patent ID Transformation**:

```sql
-- Comprehensive cleaning: remove hyphens, spaces, convert to uppercase
upper(replace(replace(trim(patent_id), '-', ''), ' ', '')) as patent_id
```

This handles all common formats:

- Removes hyphens: `US-1234-567A` → `US1234567A`
- Removes spaces: `US 1234 567A` → `US1234567A`
- Trims whitespace: `  US1234567A  ` → `US1234567A`
- Converts to uppercase: `us1234567a` → `US1234567A`

**Example with Multiple Transformations**:

```sql
INSERT INTO target_patents (patent_id, title, publication_date)
SELECT
    -- Patent ID: remove hyphens, spaces, convert to uppercase
    upper(replace(replace(trim(col1), '-', ''), ' ', '')) as patent_id,
    -- Title: trim whitespace, convert to uppercase
    upper(trim(col2)) as title,
    -- Publication date: validate and normalize to ISO 8601
    date(col3) as publication_date
FROM raw_import
WHERE col1 IS NOT NULL
  AND date(col3) IS NOT NULL;
```

### Step 5: Clean Up

Drop the temporary table:

```sql
DROP TABLE raw_import;
```
