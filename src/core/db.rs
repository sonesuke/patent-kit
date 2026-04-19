use rusqlite::{Connection, params};
use std::path::Path;
use std::sync::Mutex;

use crate::core::error::{Error, Result};
use crate::core::models::*;

pub struct Database {
    conn: Mutex<Connection>,
}

impl Database {
    pub fn open(path: &Path) -> Result<Self> {
        let conn = Connection::open(path)?;
        let db = Self {
            conn: Mutex::new(conn),
        };
        db.init_schema()?;
        Ok(db)
    }

    pub fn open_in_memory() -> Result<Self> {
        let conn = Connection::open_in_memory()?;
        let db = Self {
            conn: Mutex::new(conn),
        };
        db.init_schema()?;
        Ok(db)
    }

    fn init_schema(&self) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        conn.execute_batch(
            "
            PRAGMA journal_mode = WAL;
            PRAGMA foreign_keys = ON;

            -- target_patents
            CREATE TABLE IF NOT EXISTS target_patents (
                patent_id TEXT PRIMARY KEY NOT NULL CHECK(
                    length(patent_id) >= 5 AND
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

            -- screened_patents
            CREATE TABLE IF NOT EXISTS screened_patents (
                patent_id TEXT PRIMARY KEY NOT NULL,
                judgment TEXT NOT NULL CHECK(judgment IN ('relevant', 'irrelevant')),
                legal_status TEXT,
                reason TEXT NOT NULL,
                abstract_text TEXT NOT NULL,
                screened_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                FOREIGN KEY (patent_id) REFERENCES target_patents(patent_id) ON DELETE CASCADE
            );

            -- progress view
            CREATE VIEW IF NOT EXISTS v_screening_progress AS
            SELECT
                (SELECT COUNT(*) FROM target_patents) as total_targets,
                (SELECT COUNT(*) FROM screened_patents) as total_screened,
                (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'relevant') as relevant,
                (SELECT COUNT(*) FROM screened_patents WHERE judgment = 'irrelevant') as irrelevant,
                (SELECT COUNT(*) FROM screened_patents WHERE legal_status IN ('Expired', 'Withdrawn')) as expired;

            -- timestamp triggers: target_patents
            CREATE TRIGGER IF NOT EXISTS update_target_patents_timestamp
            AFTER UPDATE ON target_patents
            FOR EACH ROW
            BEGIN
                UPDATE target_patents SET updated_at = datetime('now') WHERE patent_id = NEW.patent_id;
            END;

            -- timestamp triggers: screened_patents
            CREATE TRIGGER IF NOT EXISTS update_screened_patents_timestamp
            AFTER UPDATE ON screened_patents
            FOR EACH ROW
            BEGIN
                UPDATE screened_patents SET updated_at = datetime('now') WHERE patent_id = NEW.patent_id;
            END;

            -- claims
            CREATE TABLE IF NOT EXISTS claims (
                patent_id TEXT NOT NULL,
                claim_number INTEGER NOT NULL,
                claim_type TEXT NOT NULL CHECK(claim_type IN ('independent', 'dependent')),
                claim_text TEXT NOT NULL,
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                PRIMARY KEY (patent_id, claim_number),
                FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE
            );

            -- elements
            CREATE TABLE IF NOT EXISTS elements (
                patent_id TEXT NOT NULL,
                claim_number INTEGER NOT NULL,
                element_label TEXT NOT NULL,
                element_description TEXT NOT NULL,
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                PRIMARY KEY (patent_id, claim_number, element_label),
                FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE,
                FOREIGN KEY (patent_id, claim_number) REFERENCES claims(patent_id, claim_number) ON DELETE CASCADE
            );

            -- similarities
            CREATE TABLE IF NOT EXISTS similarities (
                patent_id TEXT NOT NULL,
                claim_number INTEGER NOT NULL,
                element_label TEXT NOT NULL,
                similarity_level TEXT CHECK(similarity_level IN ('Significant', 'Moderate', 'Limited')),
                analysis_notes TEXT,
                analyzed_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                PRIMARY KEY (patent_id, claim_number, element_label),
                FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE,
                FOREIGN KEY (patent_id, claim_number) REFERENCES claims(patent_id, claim_number) ON DELETE CASCADE,
                FOREIGN KEY (patent_id, claim_number, element_label) REFERENCES elements(patent_id, claim_number, element_label) ON DELETE CASCADE
            );

            -- features (product-level)
            CREATE TABLE IF NOT EXISTS features (
                feature_id INTEGER PRIMARY KEY AUTOINCREMENT,
                feature_name TEXT NOT NULL UNIQUE,
                description TEXT NOT NULL,
                category TEXT,
                presence TEXT CHECK(presence IN ('present', 'absent')),
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now'))
            );

            -- timestamp triggers: claims
            CREATE TRIGGER IF NOT EXISTS update_claims_timestamp
            AFTER UPDATE ON claims
            FOR EACH ROW
            BEGIN
                UPDATE claims SET updated_at = datetime('now')
                WHERE patent_id = NEW.patent_id AND claim_number = NEW.claim_number;
            END;

            -- timestamp triggers: elements
            CREATE TRIGGER IF NOT EXISTS update_elements_timestamp
            AFTER UPDATE ON elements
            FOR EACH ROW
            BEGIN
                UPDATE elements SET updated_at = datetime('now')
                WHERE patent_id = NEW.patent_id
                  AND claim_number = NEW.claim_number
                  AND element_label = NEW.element_label;
            END;

            -- timestamp triggers: similarities
            CREATE TRIGGER IF NOT EXISTS update_similarities_timestamp
            AFTER UPDATE ON similarities
            FOR EACH ROW
            BEGIN
                UPDATE similarities SET updated_at = datetime('now')
                WHERE patent_id = NEW.patent_id
                  AND claim_number = NEW.claim_number
                  AND element_label = NEW.element_label;
            END;

            -- timestamp triggers: features
            CREATE TRIGGER IF NOT EXISTS update_features_timestamp
            AFTER UPDATE ON features
            FOR EACH ROW
            BEGIN
                UPDATE features SET updated_at = datetime('now') WHERE feature_id = NEW.feature_id;
            END;

            -- prior_arts (master)
            CREATE TABLE IF NOT EXISTS prior_arts (
                reference_id TEXT PRIMARY KEY NOT NULL,
                reference_type TEXT NOT NULL CHECK(reference_type IN ('patent', 'npl')),
                title TEXT NOT NULL,
                publication_date TEXT CHECK(
                    publication_date IS NULL OR
                    date(publication_date) IS publication_date
                ),
                created_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now'))
            );

            -- prior_art_elements (detail)
            CREATE TABLE IF NOT EXISTS prior_art_elements (
                patent_id TEXT NOT NULL,
                claim_number INTEGER NOT NULL,
                element_label TEXT NOT NULL,
                reference_id TEXT NOT NULL,
                relevance_level TEXT CHECK(relevance_level IN ('Significant', 'Moderate', 'Limited')),
                analysis_notes TEXT,
                claim_chart TEXT,
                researched_at TEXT DEFAULT (datetime('now')),
                updated_at TEXT DEFAULT (datetime('now')),
                PRIMARY KEY (patent_id, claim_number, element_label, reference_id),
                FOREIGN KEY (patent_id) REFERENCES screened_patents(patent_id) ON DELETE CASCADE,
                FOREIGN KEY (patent_id, claim_number) REFERENCES claims(patent_id, claim_number) ON DELETE CASCADE,
                FOREIGN KEY (patent_id, claim_number, element_label) REFERENCES elements(patent_id, claim_number, element_label) ON DELETE CASCADE,
                FOREIGN KEY (reference_id) REFERENCES prior_arts(reference_id) ON DELETE CASCADE
            );

            -- timestamp triggers: prior_arts
            CREATE TRIGGER IF NOT EXISTS update_prior_arts_timestamp
            AFTER UPDATE ON prior_arts
            FOR EACH ROW
            BEGIN
                UPDATE prior_arts SET updated_at = datetime('now')
                WHERE reference_id = NEW.reference_id;
            END;

            -- timestamp triggers: prior_art_elements
            CREATE TRIGGER IF NOT EXISTS update_prior_art_elements_timestamp
            AFTER UPDATE ON prior_art_elements
            FOR EACH ROW
            BEGIN
                UPDATE prior_art_elements SET updated_at = datetime('now')
                WHERE patent_id = NEW.patent_id
                  AND claim_number = NEW.claim_number
                  AND element_label = NEW.element_label
                  AND reference_id = NEW.reference_id;
            END;

            -- indexes
            CREATE INDEX IF NOT EXISTS idx_claims_patent_id ON claims(patent_id);
            CREATE INDEX IF NOT EXISTS idx_prior_art_elements_patent_id ON prior_art_elements(patent_id);
            CREATE INDEX IF NOT EXISTS idx_prior_arts_reference_type ON prior_arts(reference_type);
            ",
        )?;
        Ok(())
    }

    // -----------------------------------------------------------------------
    // CSV import
    // -----------------------------------------------------------------------

    pub fn import_csv(&self, path: &str) -> Result<IndexPatentsResult> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let content = std::fs::read_to_string(path)?;
        let lines: Vec<&str> = content.lines().collect();

        let (header_line, _data_start) = if lines.len() >= 2 {
            let first = csv::ReaderBuilder::new()
                .flexible(true)
                .from_reader(lines[0].as_bytes())
                .headers()
                .ok()
                .cloned();
            if let Some(ref hdrs) = first {
                if hdrs
                    .iter()
                    .any(|h| h.eq_ignore_ascii_case("publication number"))
                {
                    (0, 1)
                } else {
                    (1, 2)
                }
            } else {
                (0, 1)
            }
        } else {
            return Ok(IndexPatentsResult { count: 0 });
        };

        let csv_content: String = lines[header_line..].join("\n");
        let mut rdr = csv::ReaderBuilder::new()
            .flexible(true)
            .from_reader(csv_content.as_bytes());
        let headers = rdr.headers()?.clone();

        let pub_num_idx = headers
            .iter()
            .position(|h| h.eq_ignore_ascii_case("publication number"));
        let title_idx = headers.iter().position(|h| h.eq_ignore_ascii_case("title"));
        let assignee_idx = headers
            .iter()
            .position(|h| h.eq_ignore_ascii_case("assignee"))
            .or_else(|| {
                headers
                    .iter()
                    .position(|h| h.eq_ignore_ascii_case("assignee (original)"))
            })
            .or_else(|| {
                headers
                    .iter()
                    .position(|h| h.eq_ignore_ascii_case("representative"))
            });
        let country_idx = headers
            .iter()
            .position(|h| h.eq_ignore_ascii_case("country"));
        let pub_date_idx = headers
            .iter()
            .position(|h| h.eq_ignore_ascii_case("publication date"));
        let filing_idx = headers
            .iter()
            .position(|h| h.eq_ignore_ascii_case("filing date"))
            .or_else(|| {
                headers
                    .iter()
                    .position(|h| h.eq_ignore_ascii_case("priority date"))
            });

        let Some(pub_num_idx) = pub_num_idx else {
            return Err(Error::Csv(csv::Error::from(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "CSV missing 'publication number' column",
            ))));
        };

        let mut count = 0usize;
        for result in rdr.records() {
            let record = result?;
            let raw_pub = record.get(pub_num_idx).unwrap_or_default().trim();
            let patent_id = Self::normalize_patent_id(raw_pub);
            if patent_id.is_empty() {
                continue;
            }
            let title = title_idx
                .and_then(|i| record.get(i))
                .unwrap_or_default()
                .trim()
                .to_string();
            let assignee = assignee_idx
                .and_then(|i| record.get(i))
                .map(|s| s.trim().to_string());
            let country = country_idx
                .and_then(|i| record.get(i))
                .map(|s| s.trim().to_string());
            let publication_date = pub_date_idx
                .and_then(|i| record.get(i))
                .map(|s| s.trim().to_string());
            let filing_date = filing_idx
                .and_then(|i| record.get(i))
                .map(|s| s.trim().to_string());

            conn.execute(
                "INSERT INTO target_patents (patent_id, title, assignee, country, publication_date, filing_date)
                 VALUES (?1, ?2, ?3, ?4, ?5, ?6)
                 ON CONFLICT(patent_id) DO UPDATE SET title = ?2, assignee = ?3, country = ?4, publication_date = ?5, filing_date = ?6",
                params![patent_id, title, assignee, country, publication_date, filing_date],
            )?;
            count += 1;
        }
        Ok(IndexPatentsResult { count })
    }

    fn normalize_patent_id(raw: &str) -> String {
        let trimmed = raw.trim();
        if !trimmed.contains('-') {
            return trimmed.to_string();
        }
        let parts: Vec<&str> = trimmed.split('-').collect();
        if parts.len() == 5
            && parts[0] == "US"
            && let Ok(year) = parts[1].parse::<u32>()
            && (2000..=2099).contains(&year)
        {
            let month = parts[2].parse::<u32>().unwrap_or(0);
            return format!(
                "{}{}{:02}{}{}",
                parts[0], parts[1], month, parts[3], parts[4],
            );
        }
        trimmed.replace('-', "")
    }

    // -----------------------------------------------------------------------
    // Screening
    // -----------------------------------------------------------------------

    pub fn get_unscreened(&self, limit: Option<usize>) -> Result<Vec<UnscreenedPatent>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut sql = String::from(
            "SELECT t.patent_id, t.title, t.assignee, t.country, t.filing_date, t.publication_date
             FROM target_patents t
             LEFT JOIN screened_patents s ON t.patent_id = s.patent_id
             WHERE s.patent_id IS NULL
             ORDER BY t.patent_id",
        );
        if let Some(n) = limit {
            sql.push_str(&format!(" LIMIT {n}"));
        }
        let mut stmt = conn.prepare(&sql)?;
        let rows = stmt.query_map([], |row| {
            Ok(UnscreenedPatent {
                patent_id: row.get(0)?,
                title: row.get(1)?,
                assignee: row.get(2)?,
                country: row.get(3)?,
                filing_date: row.get(4)?,
                publication_date: row.get(5)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn screen_patent(
        &self,
        patent_id: &str,
        judgment: &str,
        legal_status: Option<&str>,
        reason: &str,
        abstract_text: &str,
    ) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        conn.execute(
            "INSERT INTO screened_patents (patent_id, judgment, legal_status, reason, abstract_text)
             VALUES (?1, ?2, ?3, ?4, ?5)
             ON CONFLICT(patent_id) DO UPDATE SET judgment = ?2, legal_status = ?3, reason = ?4, abstract_text = ?5",
            params![patent_id, judgment, legal_status, reason, abstract_text],
        )?;
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Evaluation
    // -----------------------------------------------------------------------

    pub fn get_unevaluated(&self, limit: Option<usize>) -> Result<Vec<UnevaluatedPatent>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut sql = String::from(
            "SELECT s.patent_id, t.title
             FROM screened_patents s
             JOIN target_patents t ON s.patent_id = t.patent_id
             LEFT JOIN claims c ON s.patent_id = c.patent_id
             WHERE s.judgment = 'relevant' AND c.patent_id IS NULL
             ORDER BY s.patent_id",
        );
        if let Some(n) = limit {
            sql.push_str(&format!(" LIMIT {n}"));
        }
        let mut stmt = conn.prepare(&sql)?;
        let rows = stmt.query_map([], |row| {
            Ok(UnevaluatedPatent {
                patent_id: row.get(0)?,
                title: row.get(1)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    // -----------------------------------------------------------------------
    // Claims
    // -----------------------------------------------------------------------

    pub fn get_claims(&self, patent_id: &str) -> Result<Vec<ClaimRow>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT patent_id, claim_number, claim_type, claim_text
             FROM claims WHERE patent_id = ?1 ORDER BY claim_number",
        )?;
        let rows = stmt.query_map(params![patent_id], |row| {
            Ok(ClaimRow {
                patent_id: row.get(0)?,
                claim_number: row.get(1)?,
                claim_type: row.get(2)?,
                claim_text: row.get(3)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn record_claims(&self, patent_id: &str, claims: &[ClaimInput]) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        conn.execute(
            "DELETE FROM claims WHERE patent_id = ?1",
            params![patent_id],
        )?;
        let mut stmt = conn.prepare(
            "INSERT OR REPLACE INTO claims (patent_id, claim_number, claim_type, claim_text)
             VALUES (?1, ?2, ?3, ?4)",
        )?;
        for c in claims {
            stmt.execute(params![
                patent_id,
                c.claim_number,
                c.claim_type,
                c.claim_text
            ])?;
        }
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Elements
    // -----------------------------------------------------------------------

    pub fn get_elements(&self, patent_id: &str) -> Result<Vec<ElementRow>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT patent_id, claim_number, element_label, element_description
             FROM elements WHERE patent_id = ?1 ORDER BY claim_number, element_label",
        )?;
        let rows = stmt.query_map(params![patent_id], |row| {
            Ok(ElementRow {
                patent_id: row.get(0)?,
                claim_number: row.get(1)?,
                element_label: row.get(2)?,
                element_description: row.get(3)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn record_elements(&self, elements: &[ElementInput]) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "INSERT OR REPLACE INTO elements (patent_id, claim_number, element_label, element_description)
             VALUES (?1, ?2, ?3, ?4)",
        )?;
        for e in elements {
            stmt.execute(params![
                e.patent_id,
                e.claim_number,
                e.element_label,
                e.element_description,
            ])?;
        }
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Product features
    // -----------------------------------------------------------------------

    pub fn get_product_features(&self) -> Result<Vec<ProductFeatureRow>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT feature_id, feature_name, description, category, presence
             FROM features ORDER BY feature_id",
        )?;
        let rows = stmt.query_map([], |row| {
            Ok(ProductFeatureRow {
                feature_id: row.get(0)?,
                feature_name: row.get(1)?,
                description: row.get(2)?,
                category: row.get(3)?,
                presence: row.get(4)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn record_product_feature(
        &self,
        feature_name: &str,
        description: &str,
        category: Option<&str>,
        presence: Option<&str>,
    ) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        conn.execute(
            "INSERT OR REPLACE INTO features (feature_name, description, category, presence)
             VALUES (?1, ?2, ?3, ?4)",
            params![feature_name, description, category, presence],
        )?;
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Similarities
    // -----------------------------------------------------------------------

    pub fn get_unanalyzed(&self, limit: Option<usize>) -> Result<Vec<UnanalyzedPatent>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut sql = String::from(
            "SELECT s.patent_id, t.title, COUNT(DISTINCT e.element_label) AS element_count
             FROM screened_patents s
             JOIN target_patents t ON s.patent_id = t.patent_id
             JOIN elements e ON s.patent_id = e.patent_id
             LEFT JOIN similarities sim ON s.patent_id = sim.patent_id
               AND e.claim_number = sim.claim_number
               AND e.element_label = sim.element_label
             WHERE s.judgment = 'relevant' AND sim.patent_id IS NULL
             GROUP BY s.patent_id
             ORDER BY s.patent_id",
        );
        if let Some(n) = limit {
            sql.push_str(&format!(" LIMIT {n}"));
        }
        let mut stmt = conn.prepare(&sql)?;
        let rows = stmt.query_map([], |row| {
            Ok(UnanalyzedPatent {
                patent_id: row.get(0)?,
                title: row.get(1)?,
                element_count: row.get(2)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn record_similarities(&self, similarities: &[SimilarityInput]) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "INSERT OR REPLACE INTO similarities (patent_id, claim_number, element_label, similarity_level, analysis_notes)
             VALUES (?1, ?2, ?3, ?4, ?5)",
        )?;
        for s in similarities {
            stmt.execute(params![
                s.patent_id,
                s.claim_number,
                s.element_label,
                s.similarity_level,
                s.analysis_notes,
            ])?;
        }
        Ok(())
    }

    pub fn get_similarities(&self, patent_id: &str) -> Result<Vec<SimilarityRow>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT patent_id, claim_number, element_label, similarity_level, analysis_notes
             FROM similarities WHERE patent_id = ?1 ORDER BY claim_number",
        )?;
        let rows = stmt.query_map(params![patent_id], |row| {
            Ok(SimilarityRow {
                patent_id: row.get(0)?,
                claim_number: row.get(1)?,
                element_label: row.get(2)?,
                similarity_level: row.get(3)?,
                analysis_notes: row.get(4)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    // -----------------------------------------------------------------------
    // Prior arts
    // -----------------------------------------------------------------------

    pub fn get_unresearched(&self, limit: Option<usize>) -> Result<Vec<UnresearchedPatent>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut sql = String::from(
            "SELECT s.patent_id, t.title, COUNT(DISTINCT e.element_label) AS element_count
             FROM screened_patents s
             JOIN target_patents t ON s.patent_id = t.patent_id
             JOIN elements e ON s.patent_id = e.patent_id
             JOIN similarities sim ON s.patent_id = sim.patent_id
               AND e.claim_number = sim.claim_number
               AND e.element_label = sim.element_label
             LEFT JOIN prior_art_elements pae ON s.patent_id = pae.patent_id
               AND e.claim_number = pae.claim_number
               AND e.element_label = pae.element_label
             WHERE s.judgment = 'relevant'
               AND sim.similarity_level IN ('Significant', 'Moderate')
               AND pae.patent_id IS NULL
             GROUP BY s.patent_id
             ORDER BY s.patent_id",
        );
        if let Some(n) = limit {
            sql.push_str(&format!(" LIMIT {n}"));
        }
        let mut stmt = conn.prepare(&sql)?;
        let rows = stmt.query_map([], |row| {
            Ok(UnresearchedPatent {
                patent_id: row.get(0)?,
                title: row.get(1)?,
                element_count: row.get(2)?,
            })
        })?;
        let mut result = Vec::new();
        for row in rows {
            result.push(row?);
        }
        Ok(result)
    }

    pub fn record_prior_arts(&self, prior_arts: &[PriorArtInput]) -> Result<()> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        for pa in prior_arts {
            conn.execute(
                "INSERT OR REPLACE INTO prior_arts (reference_id, reference_type, title, publication_date)
                 VALUES (?1, ?2, ?3, ?4)",
                params![pa.reference_id, pa.reference_type, pa.title, pa.publication_date],
            )?;
            let mut stmt = conn.prepare(
                "INSERT OR REPLACE INTO prior_art_elements
                 (patent_id, claim_number, element_label, reference_id, relevance_level, analysis_notes, claim_chart)
                 VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
            )?;
            for el in &pa.elements {
                stmt.execute(params![
                    el.patent_id,
                    el.claim_number,
                    el.element_label,
                    pa.reference_id,
                    el.relevance_level,
                    el.analysis_notes,
                    el.claim_chart,
                ])?;
            }
        }
        Ok(())
    }

    // -----------------------------------------------------------------------
    // Progress & Detail
    // -----------------------------------------------------------------------

    pub fn get_progress(&self) -> Result<Progress> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT total_targets, total_screened, relevant, irrelevant, expired FROM v_screening_progress",
        )?;
        let row = stmt.query_row([], |row| {
            Ok(Progress {
                total_targets: row.get(0)?,
                total_screened: row.get(1)?,
                relevant: row.get(2)?,
                irrelevant: row.get(3)?,
                expired: row.get(4)?,
            })
        })?;
        Ok(row)
    }

    pub fn get_patent_detail(&self, patent_id: &str) -> Result<Option<PatentDetail>> {
        let conn = self.conn.lock().map_err(|e| Error::Other(e.to_string()))?;
        let mut stmt = conn.prepare(
            "SELECT t.patent_id, t.title, t.assignee, t.country, t.extra_fields,
                    t.publication_date, t.filing_date, t.grant_date,
                    s.judgment, s.legal_status, s.reason, s.abstract_text
             FROM target_patents t
             LEFT JOIN screened_patents s ON t.patent_id = s.patent_id
             WHERE t.patent_id = ?1",
        )?;
        let mut rows = stmt.query(params![patent_id])?;
        match rows.next() {
            Ok(Some(row)) => Ok(Some(PatentDetail {
                patent_id: row.get(0)?,
                title: row.get(1)?,
                assignee: row.get(2)?,
                country: row.get(3)?,
                extra_fields: row.get(4)?,
                publication_date: row.get(5)?,
                filing_date: row.get(6)?,
                grant_date: row.get(7)?,
                judgment: row.get(8)?,
                legal_status: row.get(9)?,
                reason: row.get(10)?,
                abstract_text: row.get(11)?,
            })),
            Ok(None) => Ok(None),
            Err(e) => Err(Error::from(e)),
        }
    }
}
