-- Initialize Database
-- This script creates the patents.db file with proper schema

-- Enable SQLite optimizations
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

-- Create target_patents table
CREATE TABLE IF NOT EXISTS target_patents (
    patent_id TEXT PRIMARY KEY NOT NULL CHECK(
        length(patent_id) >= 9 AND
        length(patent_id) <= 15 AND
        instr(patent_id, '-') = 0 AND
        instr(patent_id, '_') = 0 AND
        instr(patent_id, ' ') = 0
    ),
    title TEXT,
    country TEXT,
    assignee TEXT,
    extra_fields TEXT,
    publication_date TEXT CHECK(
        publication_date IS NULL OR
        date(publication_date) IS publication_date
    ),
    filing_date TEXT CHECK(
        filing_date IS NULL OR
        date(filing_date) IS filing_date
    ),
    grant_date TEXT CHECK(
        grant_date IS NULL OR
        date(grant_date) IS grant_date
    ),
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
);

-- Create screened_patents table (with CHECK constraint for judgment)
CREATE TABLE IF NOT EXISTS screened_patents (
    patent_id TEXT PRIMARY KEY NOT NULL,
    judgment TEXT NOT NULL CHECK(judgment IN ('relevant', 'irrelevant', 'expired')),
    reason TEXT NOT NULL,
    abstract_text TEXT NOT NULL,
    screened_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (patent_id) REFERENCES target_patents(patent_id) ON DELETE CASCADE
);

-- Create progress view
CREATE VIEW IF NOT EXISTS v_screening_progress AS
SELECT
    (SELECT COUNT(*) FROM target_patents) as total_targets,
    (SELECT COUNT(*) FROM screened_patents) as total_screened,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant') as relevant,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'irrelevant') as irrelevant,
    (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'expired') as expired;

-- Create timestamp triggers
CREATE TRIGGER IF NOT EXISTS update_target_patents_timestamp
AFTER UPDATE ON target_patents
FOR EACH ROW
BEGIN
    UPDATE target_patents SET updated_at = datetime('now') WHERE patent_id = NEW.patent_id;
END;

CREATE TRIGGER IF NOT EXISTS update_screened_patents_timestamp
AFTER UPDATE ON screened_patents
FOR EACH ROW
BEGIN
    UPDATE screened_patents SET updated_at = datetime('now') WHERE patent_id = NEW.patent_id;
END;

-- Create claims table for storing patent claims during evaluation
CREATE TABLE IF NOT EXISTS claims (
    patent_id TEXT NOT NULL,
    claim_id TEXT NOT NULL,  -- Use actual claim ID from patent data (e.g., "clm-1", "CLM-0001")
    claim_number INTEGER NOT NULL,
    claim_type TEXT NOT NULL CHECK(claim_type IN ('independent', 'dependent')),
    claim_text TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    PRIMARY KEY (patent_id, claim_id),
    FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE
);

-- Create elements table for storing claim constituent elements
CREATE TABLE IF NOT EXISTS elements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patent_id TEXT NOT NULL,
    claim_id TEXT NOT NULL,  -- Reference to claims composite primary key
    element_label TEXT,
    element_description TEXT NOT NULL,
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE,
    FOREIGN KEY (patent_id, claim_id) REFERENCES claims(patent_id, claim_id) ON DELETE CASCADE
);

-- Create timestamp triggers for claims and elements
CREATE TRIGGER IF NOT EXISTS update_claims_timestamp
AFTER UPDATE ON claims
FOR EACH ROW
BEGIN
    UPDATE claims SET updated_at = datetime('now') WHERE id = NEW.id;
END;

CREATE TRIGGER IF NOT EXISTS update_elements_timestamp
AFTER UPDATE ON elements
FOR EACH ROW
BEGIN
    UPDATE elements SET updated_at = datetime('now') WHERE id = NEW.id;
END;

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_claims_patent_id ON claims(patent_id);
CREATE INDEX IF NOT EXISTS idx_elements_patent_id ON elements(patent_id);
CREATE INDEX IF NOT EXISTS idx_elements_claim_id ON elements(claim_id);
