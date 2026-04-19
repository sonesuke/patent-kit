use std::path::PathBuf;
use std::sync::Arc;

use google_patent_cli::core::models::SearchOptions;
use google_patent_cli::core::patent_search::PatentSearch;
use rmcp::ServerHandler;
use rmcp::handler::server::router::Router;
use rmcp::handler::server::router::tool::ToolRoute;
use rmcp::handler::server::tool::ToolCallContext;
use rmcp::model::{CallToolResult, ServerCapabilities, ServerInfo, Tool};
use rmcp::transport::io::stdio;
use schemars::JsonSchema;

use crate::core::db::Database;
use crate::core::models::{CheckAssigneeResult, *};

pub struct PatentKitHandler {
    pub searcher: Arc<dyn PatentSearch>,
    pub arxiv: Arc<arxiv_cli::core::ArxivClient>,
    pub db: std::sync::Mutex<Option<Database>>,
    pub db_path: PathBuf,
    pub indexing_in_progress: std::sync::Arc<std::sync::atomic::AtomicBool>,
}

impl PatentKitHandler {
    pub fn new(
        searcher: Arc<dyn PatentSearch>,
        arxiv: Arc<arxiv_cli::core::ArxivClient>,
        db_path: PathBuf,
    ) -> Self {
        Self {
            searcher,
            arxiv,
            db: std::sync::Mutex::new(None),
            db_path,
            indexing_in_progress: std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false)),
        }
    }

    fn ensure_db(&self) -> Result<(), rmcp::model::ErrorData> {
        let mut guard = self.db.lock().unwrap();
        if guard.is_none() {
            *guard = Some(Database::open(&self.db_path).map_err(internal_error)?);
        }
        Ok(())
    }
}

macro_rules! with_db {
    ($service:expr, $db:ident, $body:expr) => {{
        $service.ensure_db()?;
        let _guard = $service.db.lock().unwrap();
        let $db = _guard.as_ref().unwrap();
        $body
    }};
}

impl ServerHandler for PatentKitHandler {
    fn get_info(&self) -> ServerInfo {
        ServerInfo {
            capabilities: ServerCapabilities::builder().enable_tools().build(),
            instructions: Some(
                "Patent Kit MCP server. Use the available tools to search patents, \
                 manage patent investigation workflow, and track progress."
                    .to_string(),
            ),
            ..Default::default()
        }
    }
}

fn tools() -> Vec<Tool> {
    vec![
        Tool::new(
            "import_csv",
            "Import patents from a Google Patents CSV file",
            schema_for::<ImportCsvRequest>(),
        ),
        Tool::new(
            "search_patents",
            "Search Google Patents for matching patents",
            schema_for::<SearchPatentsRequest>(),
        ),
        Tool::new(
            "check_assignee",
            "Check assignee name variations",
            schema_for::<CheckAssigneeRequest>(),
        ),
        Tool::new(
            "search_papers",
            "Search arXiv for academic papers",
            schema_for::<SearchPapersRequest>(),
        ),
        Tool::new(
            "fetch_paper",
            "Fetch paper details from arXiv by ID",
            schema_for::<FetchPaperRequest>(),
        ),
        Tool::new(
            "get_unscreened",
            "Get patents that have not been screened yet",
            schema_for::<GetUnscreenedRequest>(),
        ),
        Tool::new(
            "index_patents",
            "Fetch patent details (abstract, legal status, claims) from Google Patents for all unindexed patents and store in database",
            schema_for::<IndexPatentsRequest>(),
        ),
        Tool::new(
            "stop_indexing",
            "Stop the background indexing process if it is running",
            schema_for::<StopIndexingRequest>(),
        ),
        Tool::new(
            "screen_patent",
            "Screen a patent with judgment (relevant/irrelevant) and reason",
            schema_for::<ScreenPatentRequest>(),
        ),
        Tool::new(
            "get_unevaluated",
            "Get relevant screened patents that have no claims recorded yet",
            schema_for::<GetUnevaluatedRequest>(),
        ),
        Tool::new(
            "record_claims",
            "Record claims extracted from a patent",
            schema_for::<RecordClaimsRequest>(),
        ),
        Tool::new(
            "get_claims",
            "Get claims for a specific patent",
            schema_for::<GetClaimsRequest>(),
        ),
        Tool::new(
            "record_elements",
            "Record technical elements decomposed from claims",
            schema_for::<RecordElementsRequest>(),
        ),
        Tool::new(
            "get_elements",
            "Get recorded elements for a patent",
            schema_for::<GetElementsRequest>(),
        ),
        Tool::new(
            "get_unanalyzed",
            "Get patents with elements but no similarity analysis",
            schema_for::<GetUnanalyzedRequest>(),
        ),
        Tool::new(
            "record_similarities",
            "Record similarity analysis results per element",
            schema_for::<RecordSimilaritiesRequest>(),
        ),
        Tool::new(
            "get_product_features",
            "Get all product-level features",
            schema_for::<GetProductFeaturesRequest>(),
        ),
        Tool::new(
            "record_product_feature",
            "Record a product-level feature",
            schema_for::<RecordProductFeatureRequest>(),
        ),
        Tool::new(
            "get_unresearched",
            "Get patents with Significant/Moderate similarities but no prior arts",
            schema_for::<GetUnresearchedRequest>(),
        ),
        Tool::new(
            "record_prior_arts",
            "Record prior art references with element-level claim charts",
            schema_for::<RecordPriorArtsRequest>(),
        ),
        Tool::new(
            "get_patent_detail",
            "Get full detail of a patent from the database",
            schema_for::<GetPatentDetailRequest>(),
        ),
        Tool::new(
            "get_progress",
            "Get investigation progress summary",
            schema_for::<GetProgressRequest>(),
        ),
    ]
}

fn schema_for<T: JsonSchema + 'static>() -> Arc<rmcp::model::JsonObject> {
    rmcp::handler::server::common::schema_for_type::<T>()
}

pub fn create_handler(
    searcher: Arc<dyn PatentSearch>,
    arxiv: Arc<arxiv_cli::core::ArxivClient>,
    db_path: PathBuf,
) -> Router<PatentKitHandler> {
    let handler = PatentKitHandler::new(searcher, arxiv, db_path);
    let mut router = Router::new(handler);
    for tool in tools() {
        let route = ToolRoute::new_dyn(tool.clone(), |ctx| {
            let tool_name = ctx.name.clone();
            Box::pin(handle_tool_call(ctx, tool_name))
        });
        router = router.with_tool(route);
    }
    router
}

async fn handle_tool_call(
    mut ctx: ToolCallContext<'_, PatentKitHandler>,
    tool_name: std::borrow::Cow<'static, str>,
) -> Result<CallToolResult, rmcp::model::ErrorData> {
    let service = ctx.service;
    let args: serde_json::Map<String, serde_json::Value> = ctx.arguments.take().unwrap_or_default();

    let result = match tool_name.as_ref() {
        "import_csv" => {
            let req: ImportCsvRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.import_csv(&req.file_path)
                    .map(|r| format!("Imported {} patents from CSV", r.count))
                    .map_err(internal_error)
            })
        }
        "search_patents" => {
            let req: SearchPatentsRequest = parse_args(&args)?;
            let opts = SearchOptions {
                query: Some(req.query),
                assignee: req.assignee,
                country: req.country,
                limit: req.limit,
                ..Default::default()
            };
            match service.searcher.as_ref().search(&opts).await {
                Ok(results) => Ok(format_search_results(&results)),
                Err(e) => Err(internal_error(e)),
            }
        }
        "check_assignee" => {
            let req: CheckAssigneeRequest = parse_args(&args)?;
            let opts = SearchOptions {
                assignee: Some(vec![req.assignee]),
                limit: Some(5),
                ..Default::default()
            };
            match service.searcher.as_ref().search(&opts).await {
                Ok(results) => {
                    let result = CheckAssigneeResult::from_top_assignees(results.top_assignees);
                    if result.variations.is_empty() {
                        Ok("No assignee variations found".to_string())
                    } else {
                        let lines: Vec<String> = result
                            .variations
                            .iter()
                            .map(|v| {
                                if v.percentage.is_empty() {
                                    format!("- {}", v.name)
                                } else {
                                    format!("- {} ({})", v.name, v.percentage)
                                }
                            })
                            .collect();
                        Ok(format!(
                            "Assignee variations found ({}):\n{}",
                            result.variations.len(),
                            lines.join("\n")
                        ))
                    }
                }
                Err(e) => Err(internal_error(e)),
            }
        }
        "search_papers" => {
            let req: SearchPapersRequest = parse_args(&args)?;
            match service
                .arxiv
                .search(&req.query, req.limit, None, None, None, false)
                .await
            {
                Ok(papers) => {
                    let mut lines = vec![format!("Found {} papers", papers.len())];
                    for p in &papers {
                        lines.push(format!("- {} ({}) [{}]", p.title, p.id, p.published_date));
                    }
                    Ok(lines.join("\n"))
                }
                Err(e) => Err(internal_error(e)),
            }
        }
        "fetch_paper" => {
            let req: FetchPaperRequest = parse_args(&args)?;
            match service.arxiv.fetch(&req.id).await {
                Ok(paper) => {
                    let mut lines = vec![
                        format!("Title: {}", paper.title),
                        format!("ID: {}", paper.id),
                        format!("Published: {}", paper.published_date),
                        format!("URL: {}", paper.url),
                        format!("PDF: {}", paper.pdf_url),
                        format!("Authors: {}", paper.authors.join(", ")),
                        format!("Summary:\n{}", paper.summary),
                    ];
                    if let Some(ref paragraphs) = paper.description_paragraphs {
                        lines.push(String::new());
                        lines.push("Extracted text (first 10 paragraphs):".to_string());
                        for p in paragraphs.iter().take(10) {
                            lines.push(format!("[{}] {}", p.number, p.text));
                        }
                    }
                    Ok(lines.join("\n"))
                }
                Err(e) => Err(internal_error(e)),
            }
        }
        "get_unscreened" => {
            let req: GetUnscreenedRequest = parse_args(&args)?;
            let indexing = service
                .indexing_in_progress
                .load(std::sync::atomic::Ordering::Relaxed);
            with_db!(service, db, {
                let r = db
                    .get_unscreened(req.limit.or(Some(10)))
                    .map_err(internal_error)?;
                let mut lines = Vec::new();
                if indexing {
                    lines.push(format!(
                        "Indexing in progress... ({} patent(s) remaining)",
                        r.unindexed_count
                    ));
                }
                if !lines.is_empty() && !r.patents.is_empty() {
                    lines.push(String::new());
                }
                if r.patents.is_empty() && !indexing {
                    if r.unindexed_count > 0 {
                        lines.push(format!(
                            "{} patents need indexing. Call index_patents first.",
                            r.unindexed_count
                        ));
                    } else {
                        lines.push("All patents have been screened.".to_string());
                    }
                }
                if !r.patents.is_empty() {
                    lines.push(format_unscreened(&r.patents));
                }
                Ok::<String, rmcp::model::ErrorData>(lines.join("\n"))
            })
        }
        "index_patents" => {
            let patent_ids = {
                service.ensure_db()?;
                let guard = service.db.lock().unwrap();
                let db = guard.as_ref().unwrap();
                db.get_unindexed().map_err(internal_error)?
            };
            let total = patent_ids.len();
            if total == 0 {
                Ok("All patents are already indexed.".to_string())
            } else {
                service
                    .indexing_in_progress
                    .store(true, std::sync::atomic::Ordering::Relaxed);
                let searcher = service.searcher.clone();
                let db_path = service.db_path.clone();
                let flag = service.indexing_in_progress.clone();
                std::thread::spawn(move || {
                    let rt = tokio::runtime::Builder::new_current_thread()
                        .enable_all()
                        .build();
                    let rt = match rt {
                        Ok(rt) => rt,
                        Err(_) => {
                            flag.store(false, std::sync::atomic::Ordering::Relaxed);
                            return;
                        }
                    };
                    let db = match Database::open(&db_path) {
                        Ok(db) => db,
                        Err(_) => return,
                    };
                    for patent_id in &patent_ids {
                        if !flag.load(std::sync::atomic::Ordering::Relaxed) {
                            break;
                        }
                        let opts = SearchOptions {
                            patent_number: Some(patent_id.clone()),
                            ..Default::default()
                        };
                        match rt.block_on(searcher.as_ref().search(&opts)) {
                            Ok(results) => {
                                let patent = results.patents.first();
                                let abstract_text = patent.and_then(|p| p.abstract_text.clone());
                                let legal_status = patent.and_then(|p| p.legal_status.clone());
                                let claims: Vec<_> = patent
                                    .and_then(|p| p.claims.as_ref())
                                    .map(|c| {
                                        c.iter()
                                            .enumerate()
                                            .map(|(i, cl)| ClaimInput {
                                                claim_number: i as i64 + 1,
                                                claim_type: if cl.id.contains("-ind")
                                                    || cl.id.contains("independent")
                                                {
                                                    "independent"
                                                } else {
                                                    "dependent"
                                                }
                                                .to_string(),
                                                claim_text: cl.text.clone(),
                                            })
                                            .collect()
                                    })
                                    .unwrap_or_default();
                                let _ = db.update_patent_index(
                                    patent_id,
                                    abstract_text.as_deref(),
                                    legal_status.as_deref(),
                                );
                                if !claims.is_empty() {
                                    let _ = db.record_claims(patent_id, &claims);
                                }
                            }
                            Err(_) => continue,
                        }
                    }
                    flag.store(false, std::sync::atomic::Ordering::Relaxed);
                });
                Ok(format!("Indexing {} patents started in background.", total))
            }
        }
        "stop_indexing" => {
            let was_indexing = service
                .indexing_in_progress
                .swap(false, std::sync::atomic::Ordering::Relaxed);
            if was_indexing {
                Ok(
                    "Indexing stop requested. The current patent will finish before stopping."
                        .to_string(),
                )
            } else {
                Ok("No indexing in progress.".to_string())
            }
        }
        "screen_patent" => {
            let req: ScreenPatentRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.screen_patent(&req.patent_id, &req.judgment, &req.reason)
                    .map(|_| format!("Patent {} screened as {}", req.patent_id, req.judgment))
                    .map_err(internal_error)
            })
        }
        "get_unevaluated" => {
            let req: GetUnevaluatedRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_unevaluated(req.limit)
                    .map(|p| format_unevaluated(&p))
                    .map_err(internal_error)
            })
        }
        "record_claims" => {
            let req: RecordClaimsRequest = parse_args(&args)?;
            let db_claims: Vec<ClaimInput> = req.claims;
            with_db!(service, db, {
                db.record_claims(&req.patent_id, &db_claims)
                    .map(|_| format!("Recorded {} claims for {}", db_claims.len(), req.patent_id))
                    .map_err(internal_error)
            })
        }
        "get_claims" => {
            let req: GetClaimsRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_claims(&req.patent_id)
                    .map(|c| format_claims(&c))
                    .map_err(internal_error)
            })
        }
        "record_elements" => {
            let req: RecordElementsRequest = parse_args(&args)?;
            let count = req.elements.len();
            with_db!(service, db, {
                db.record_elements(&req.elements)
                    .map(|_| format!("Recorded {} elements", count))
                    .map_err(internal_error)
            })
        }
        "get_elements" => {
            let req: GetElementsRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_elements(&req.patent_id)
                    .map(|e| format_elements(&e))
                    .map_err(internal_error)
            })
        }
        "get_unanalyzed" => {
            let req: GetUnanalyzedRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_unanalyzed(req.limit)
                    .map(|p| format_unanalyzed(&p))
                    .map_err(internal_error)
            })
        }
        "record_similarities" => {
            let req: RecordSimilaritiesRequest = parse_args(&args)?;
            let count = req.similarities.len();
            with_db!(service, db, {
                db.record_similarities(&req.similarities)
                    .map(|_| format!("Recorded {} similarities", count))
                    .map_err(internal_error)
            })
        }
        "get_product_features" => {
            with_db!(service, db, {
                db.get_product_features()
                    .map(|f| format_product_features(&f))
                    .map_err(internal_error)
            })
        }
        "record_product_feature" => {
            let req: RecordProductFeatureRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.record_product_feature(
                    &req.feature_name,
                    &req.description,
                    req.category.as_deref(),
                    req.presence.as_deref(),
                )
                .map(|_| format!("Recorded product feature: {}", req.feature_name))
                .map_err(internal_error)
            })
        }
        "get_unresearched" => {
            let req: GetUnresearchedRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_unresearched(req.limit)
                    .map(|p| format_unresearched(&p))
                    .map_err(internal_error)
            })
        }
        "record_prior_arts" => {
            let req: RecordPriorArtsRequest = parse_args(&args)?;
            let count = req.prior_arts.len();
            with_db!(service, db, {
                db.record_prior_arts(&req.prior_arts)
                    .map(|_| format!("Recorded {} prior arts", count))
                    .map_err(internal_error)
            })
        }
        "get_patent_detail" => {
            let req: GetPatentDetailRequest = parse_args(&args)?;
            with_db!(service, db, {
                db.get_patent_detail(&req.patent_id)
                    .map(|detail| match detail {
                        Some(d) => format_patent_detail(&d),
                        None => format!("Patent {} not found in database", req.patent_id),
                    })
                    .map_err(internal_error)
            })
        }
        "get_progress" => {
            with_db!(service, db, {
                db.get_progress()
                    .map(|p| format_progress(&p))
                    .map_err(internal_error)
            })
        }
        _ => Err(rmcp::model::ErrorData::invalid_params(
            format!("Unknown tool: {}", tool_name),
            None,
        )),
    };

    match result {
        Ok(text) => Ok(CallToolResult::success(vec![rmcp::model::Content::text(
            text,
        )])),
        Err(e) => Err(e),
    }
}

fn internal_error<E: std::fmt::Display>(e: E) -> rmcp::model::ErrorData {
    rmcp::model::ErrorData::internal_error(e.to_string(), None)
}

fn parse_args<T: serde::de::DeserializeOwned>(
    args: &serde_json::Map<String, serde_json::Value>,
) -> std::result::Result<T, rmcp::model::ErrorData> {
    serde_json::from_value(serde_json::Value::Object(args.clone())).map_err(|e| {
        rmcp::model::ErrorData::invalid_params(format!("Invalid arguments: {e}"), None)
    })
}

// ---------------------------------------------------------------------------
// Formatters
// ---------------------------------------------------------------------------

fn format_search_results(results: &google_patent_cli::core::models::SearchResult) -> String {
    let mut lines = vec![format!("Total results: {}", results.total_results)];
    for p in &results.patents {
        lines.push(format!(
            "- {} ({}){}",
            p.title,
            p.id,
            p.assignee
                .as_ref()
                .map(|a| format!(" [{}]", a))
                .unwrap_or_default()
        ));
    }
    lines.join("\n")
}

fn format_unscreened(patents: &[UnscreenedPatent]) -> String {
    if patents.is_empty() {
        return "No unscreened patents".to_string();
    }
    let mut lines = vec![format!("Unscreened patents ({}):", patents.len())];
    for p in patents {
        let assignee = p.assignee.as_deref().unwrap_or("N/A");
        lines.push(format!("- {} ({}) [{}]", p.title, p.patent_id, assignee));
        if let Some(abstract_text) = &p.abstract_text {
            lines.push(format!("  Abstract: {}", abstract_text));
        }
    }
    lines.join("\n")
}

fn format_unevaluated(patents: &[UnevaluatedPatent]) -> String {
    if patents.is_empty() {
        return "No unevaluated patents".to_string();
    }
    let mut lines = vec![format!("Unevaluated patents ({}):", patents.len())];
    for p in patents {
        lines.push(format!("- {} ({})", p.title, p.patent_id));
    }
    lines.join("\n")
}

fn format_claims(claims: &[ClaimRow]) -> String {
    if claims.is_empty() {
        return "No claims found".to_string();
    }
    let mut lines = vec![format!("Claims ({}):", claims.len())];
    for c in claims {
        lines.push(format!(
            "Claim {} [{}]: {}",
            c.claim_number, c.claim_type, c.claim_text
        ));
    }
    lines.join("\n")
}

fn format_elements(elements: &[ElementRow]) -> String {
    if elements.is_empty() {
        return "No elements found".to_string();
    }
    let mut lines = vec![format!("Elements ({}):", elements.len())];
    for e in elements {
        lines.push(format!(
            "- Claim {}: {} — {}",
            e.claim_number, e.element_label, e.element_description
        ));
    }
    lines.join("\n")
}

fn format_unanalyzed(patents: &[UnanalyzedPatent]) -> String {
    if patents.is_empty() {
        return "No unanalyzed patents".to_string();
    }
    let mut lines = vec![format!("Unanalyzed patents ({}):", patents.len())];
    for p in patents {
        lines.push(format!(
            "- {} ({}) — {} elements",
            p.title, p.patent_id, p.element_count
        ));
    }
    lines.join("\n")
}

fn format_product_features(features: &[ProductFeatureRow]) -> String {
    if features.is_empty() {
        return "No product features".to_string();
    }
    let mut lines = vec![format!("Product Features ({}):", features.len())];
    for f in features {
        let cat = f
            .category
            .as_ref()
            .map(|c| format!(" [{}]", c))
            .unwrap_or_default();
        let presence = f
            .presence
            .as_ref()
            .map(|p| format!(" ({})", p))
            .unwrap_or_default();
        lines.push(format!(
            "- {}{}{}: {}",
            f.feature_name, cat, presence, f.description
        ));
    }
    lines.join("\n")
}

fn format_unresearched(patents: &[UnresearchedPatent]) -> String {
    if patents.is_empty() {
        return "No unresearched patents".to_string();
    }
    let mut lines = vec![format!("Unresearched patents ({}):", patents.len())];
    for p in patents {
        lines.push(format!(
            "- {} ({}) — {} elements",
            p.title, p.patent_id, p.element_count
        ));
    }
    lines.join("\n")
}

fn format_patent_detail(detail: &PatentDetail) -> String {
    let mut lines = vec![
        format!("Patent: {}", detail.patent_id),
        format!("Title: {}", detail.title.as_deref().unwrap_or("N/A")),
        format!("Assignee: {}", detail.assignee.as_deref().unwrap_or("N/A")),
        format!("Country: {}", detail.country.as_deref().unwrap_or("N/A")),
        format!(
            "Filing Date: {}",
            detail.filing_date.as_deref().unwrap_or("N/A")
        ),
        format!(
            "Publication Date: {}",
            detail.publication_date.as_deref().unwrap_or("N/A")
        ),
        format!(
            "Grant Date: {}",
            detail.grant_date.as_deref().unwrap_or("N/A")
        ),
    ];
    lines.push(String::new());
    lines.push("--- Screening ---".to_string());
    lines.push(format!(
        "Judgment: {}",
        detail.judgment.as_deref().unwrap_or("N/A")
    ));
    lines.push(format!(
        "Legal Status: {}",
        detail.legal_status.as_deref().unwrap_or("N/A")
    ));
    lines.push(format!(
        "Reason: {}",
        detail.reason.as_deref().unwrap_or("N/A")
    ));
    lines.push(format!(
        "Abstract: {}",
        detail.abstract_text.as_deref().unwrap_or("N/A")
    ));
    lines.join("\n")
}

fn format_progress(p: &Progress) -> String {
    format!(
        "Investigation Progress:\n\
         - Total targets: {}\n\
         - Screened: {} ({})\n\
         - Relevant: {}\n\
         - Irrelevant: {}\n\
         - Expired/Withdrawn: {}",
        p.total_targets,
        p.total_screened,
        p.total_targets - p.total_screened,
        p.relevant,
        p.irrelevant,
        p.expired,
    )
}

// ---------------------------------------------------------------------------
// Server entry point
// ---------------------------------------------------------------------------

pub async fn run(verbose: bool) -> anyhow::Result<()> {
    let config = crate::core::Config::load()?;
    let db_path = config.resolve_db_path();

    let (browser_path, chrome_args) = config.resolve_browser();
    let searcher = Arc::new(
        google_patent_cli::core::patent_search::PatentSearcher::new(
            browser_path.clone(),
            true,
            false,
            verbose,
            chrome_args.clone(),
        )
        .await?,
    );

    let arxiv_config = arxiv_cli::core::Config {
        headless: true,
        browser_path: browser_path.map(|p| p.to_string_lossy().to_string()),
        chrome_args,
    };
    let arxiv = Arc::new(arxiv_cli::core::ArxivClient::new(&arxiv_config).await?);

    let router = create_handler(searcher.clone(), arxiv.clone(), db_path);

    let transport = stdio();
    let running = rmcp::service::serve_directly(router, transport, None);
    let result = running.waiting().await;

    drop(searcher);
    drop(arxiv);
    kill_orphan_chrome();

    result?;
    Ok(())
}

fn kill_orphan_chrome() {
    use std::process::Command;
    let _ = Command::new("pkill").args(["-f", "chromium"]).output();
}
