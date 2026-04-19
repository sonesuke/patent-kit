use std::sync::Arc;

use clap::{Parser, Subcommand};
use google_patent_cli::core::models::SearchOptions;
use google_patent_cli::core::patent_search::PatentSearch;

use crate::core::config::Config;
use crate::core::db::Database;
use crate::core::models::CheckAssigneeResult;

#[derive(clap::Args)]
struct VerboseFlag {
    #[arg(long, global = true)]
    verbose: bool,
}

#[derive(Parser)]
#[command(name = "patent-kit", about = "Patent investigation toolkit")]
pub struct Cli {
    #[command(flatten)]
    verbose: VerboseFlag,
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    /// Start the MCP server over stdio
    Mcp,
    /// Import patents from a Google Patents CSV file
    ImportCsv {
        #[arg(value_name = "FILE")]
        file_path: String,
    },
    /// Search Google Patents
    SearchPatents {
        #[arg(value_name = "QUERY")]
        query: String,
        #[arg(long)]
        assignee: Option<Vec<String>>,
        #[arg(long)]
        country: Option<String>,
        #[arg(long)]
        limit: Option<usize>,
    },
    /// Check assignee name variations
    CheckAssignee {
        #[arg(value_name = "NAME")]
        assignee: String,
    },
    /// Get unscreened patents
    GetUnscreened {
        #[arg(long)]
        limit: Option<usize>,
    },
    /// Screen a patent with judgment
    ScreenPatent {
        #[arg(value_name = "ID")]
        patent_id: String,
        /// Judgment: relevant or irrelevant
        #[arg(long)]
        judgment: String,
        #[arg(long)]
        legal_status: Option<String>,
        /// Reason for judgment
        #[arg(long)]
        reason: String,
        /// Patent abstract text
        #[arg(long)]
        abstract_text: String,
    },
    /// Get unevaluated patents (relevant, no claims)
    GetUnevaluated {
        #[arg(long)]
        limit: Option<usize>,
    },
    /// Get claims for a patent
    GetClaims {
        #[arg(value_name = "ID")]
        patent_id: String,
    },
    /// Get elements for a patent
    GetElements {
        #[arg(value_name = "ID")]
        patent_id: String,
    },
    /// Get unanalyzed patents (have elements, no similarities)
    GetUnanalyzed {
        #[arg(long)]
        limit: Option<usize>,
    },
    /// Get product-level features
    GetProductFeatures,
    /// Get unresearched patents (Significant/Moderate similarities, no prior arts)
    GetUnresearched {
        #[arg(long)]
        limit: Option<usize>,
    },
    /// Get patent detail from database
    GetPatentDetail {
        #[arg(value_name = "ID")]
        patent_id: String,
    },
    /// Show investigation progress
    Progress,
}

pub async fn run() -> anyhow::Result<()> {
    let cli = Cli::parse();

    match cli.command {
        Commands::Mcp => {
            crate::mcp::run(cli.verbose.verbose).await?;
        }
        Commands::ImportCsv { file_path } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let result = db.import_csv(&file_path)?;
            println!("Imported {} patents from {}", result.count, file_path);
        }
        Commands::SearchPatents {
            query,
            assignee,
            country,
            limit,
        } => {
            let config = Config::load()?;
            let (browser_path, chrome_args) = config.resolve_browser();
            let searcher = Arc::new(
                google_patent_cli::core::patent_search::PatentSearcher::new(
                    browser_path,
                    true,
                    false,
                    cli.verbose.verbose,
                    chrome_args,
                )
                .await?,
            );
            let opts = SearchOptions {
                query: Some(query),
                assignee,
                country,
                limit,
                ..Default::default()
            };
            let results = searcher.as_ref().search(&opts).await?;
            println!("Total results: {}", results.total_results);
            for p in &results.patents {
                println!(
                    "- {} ({}){}",
                    p.title,
                    p.id,
                    p.assignee
                        .as_ref()
                        .map(|a| format!(" [{}]", a))
                        .unwrap_or_default()
                );
            }
        }
        Commands::CheckAssignee { assignee } => {
            let config = Config::load()?;
            let (browser_path, chrome_args) = config.resolve_browser();
            let searcher = Arc::new(
                google_patent_cli::core::patent_search::PatentSearcher::new(
                    browser_path,
                    true,
                    false,
                    cli.verbose.verbose,
                    chrome_args,
                )
                .await?,
            );
            let opts = SearchOptions {
                assignee: Some(vec![assignee.clone()]),
                limit: Some(5),
                ..Default::default()
            };
            let results = searcher.as_ref().search(&opts).await?;
            let result = CheckAssigneeResult::from_top_assignees(results.top_assignees);
            if result.variations.is_empty() {
                println!("No assignee variations found");
            } else {
                println!(
                    "Assignee variations for '{}' ({}):",
                    assignee,
                    result.variations.len()
                );
                for v in &result.variations {
                    if v.percentage.is_empty() {
                        println!("  - {}", v.name);
                    } else {
                        println!("  - {} ({})", v.name, v.percentage);
                    }
                }
            }
        }
        Commands::GetUnscreened { limit } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let patents = db.get_unscreened(limit)?;
            if patents.is_empty() {
                println!("No unscreened patents");
            } else {
                println!("Unscreened patents ({}):", patents.len());
                for p in &patents {
                    println!("- {} ({})", p.title, p.patent_id);
                }
            }
        }
        Commands::ScreenPatent {
            patent_id,
            judgment,
            legal_status,
            reason,
            abstract_text,
        } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            db.screen_patent(
                &patent_id,
                &judgment,
                legal_status.as_deref(),
                &reason,
                &abstract_text,
            )?;
            println!("Patent {} screened: {}", patent_id, judgment);
        }
        Commands::GetUnevaluated { limit } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let patents = db.get_unevaluated(limit)?;
            if patents.is_empty() {
                println!("No unevaluated patents");
            } else {
                println!("Unevaluated patents ({}):", patents.len());
                for p in &patents {
                    println!("- {} ({})", p.title, p.patent_id);
                }
            }
        }
        Commands::GetClaims { patent_id } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let claims = db.get_claims(&patent_id)?;
            if claims.is_empty() {
                println!("No claims found for {}", patent_id);
            } else {
                println!("Claims for {} ({}):", patent_id, claims.len());
                for c in &claims {
                    println!(
                        "Claim {} [{}]: {}",
                        c.claim_number, c.claim_type, c.claim_text
                    );
                }
            }
        }
        Commands::GetElements { patent_id } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let elements = db.get_elements(&patent_id)?;
            if elements.is_empty() {
                println!("No elements found for {}", patent_id);
            } else {
                println!("Elements for {} ({}):", patent_id, elements.len());
                for e in &elements {
                    println!(
                        "- Claim {}: {} — {}",
                        e.claim_number, e.element_label, e.element_description
                    );
                }
            }
        }
        Commands::GetUnanalyzed { limit } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let patents = db.get_unanalyzed(limit)?;
            if patents.is_empty() {
                println!("No unanalyzed patents");
            } else {
                println!("Unanalyzed patents ({}):", patents.len());
                for p in &patents {
                    println!(
                        "- {} ({}) — {} elements",
                        p.title, p.patent_id, p.element_count
                    );
                }
            }
        }
        Commands::GetProductFeatures => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let features = db.get_product_features()?;
            if features.is_empty() {
                println!("No product features");
            } else {
                println!("Product Features ({}):", features.len());
                for f in &features {
                    let cat = f
                        .category
                        .as_ref()
                        .map(|c| format!(" [{}]", c))
                        .unwrap_or_default();
                    println!("- {}{}: {}", f.feature_name, cat, f.description);
                }
            }
        }
        Commands::GetUnresearched { limit } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let patents = db.get_unresearched(limit)?;
            if patents.is_empty() {
                println!("No unresearched patents");
            } else {
                println!("Unresearched patents ({}):", patents.len());
                for p in &patents {
                    println!(
                        "- {} ({}) — {} elements",
                        p.title, p.patent_id, p.element_count
                    );
                }
            }
        }
        Commands::GetPatentDetail { patent_id } => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            match db.get_patent_detail(&patent_id)? {
                Some(detail) => {
                    println!("Patent: {}", detail.patent_id);
                    println!("Title: {}", detail.title.as_deref().unwrap_or("N/A"));
                    println!("Assignee: {}", detail.assignee.as_deref().unwrap_or("N/A"));
                    println!("Country: {}", detail.country.as_deref().unwrap_or("N/A"));
                    println!(
                        "Filing Date: {}",
                        detail.filing_date.as_deref().unwrap_or("N/A")
                    );
                    println!(
                        "Publication Date: {}",
                        detail.publication_date.as_deref().unwrap_or("N/A")
                    );
                    println!(
                        "Grant Date: {}",
                        detail.grant_date.as_deref().unwrap_or("N/A")
                    );
                    println!("Judgment: {}", detail.judgment.as_deref().unwrap_or("N/A"));
                    println!(
                        "Legal Status: {}",
                        detail.legal_status.as_deref().unwrap_or("N/A")
                    );
                    println!("Reason: {}", detail.reason.as_deref().unwrap_or("N/A"));
                    println!(
                        "Abstract: {}",
                        detail.abstract_text.as_deref().unwrap_or("N/A")
                    );
                }
                None => {
                    println!("Patent {} not found in database", patent_id);
                }
            }
        }
        Commands::Progress => {
            let config = Config::load()?;
            let db = Database::open(&config.resolve_db_path())?;
            let p = db.get_progress()?;
            println!("Investigation Progress:");
            println!("  Total targets: {}", p.total_targets);
            println!("  Screened: {}/{}", p.total_screened, p.total_targets);
            println!("  Relevant: {}", p.relevant);
            println!("  Irrelevant: {}", p.irrelevant);
            println!("  Expired/Withdrawn: {}", p.expired);
        }
    }

    Ok(())
}
