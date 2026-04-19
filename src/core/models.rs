use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

// ---------------------------------------------------------------------------
// Request types (parameters for MCP tools / CLI subcommands)
// ---------------------------------------------------------------------------

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ImportCsvRequest {
    pub file_path: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct SearchPatentsRequest {
    pub query: String,
    pub assignee: Option<Vec<String>>,
    pub country: Option<String>,
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct CheckAssigneeRequest {
    pub assignee: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct SearchPapersRequest {
    pub query: String,
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct FetchPaperRequest {
    pub id: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetUnscreenedRequest {
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ScreenPatentRequest {
    pub patent_id: String,
    pub judgment: String, // "relevant" or "irrelevant"
    pub legal_status: Option<String>,
    pub reason: String,
    pub abstract_text: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetUnevaluatedRequest {
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetClaimsRequest {
    pub patent_id: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RecordClaimsRequest {
    pub patent_id: String,
    pub claims: Vec<ClaimInput>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ClaimInput {
    pub claim_number: i64,
    pub claim_type: String, // "independent" or "dependent"
    pub claim_text: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RecordElementsRequest {
    pub elements: Vec<ElementInput>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ElementInput {
    pub patent_id: String,
    pub claim_number: i64,
    pub element_label: String,
    pub element_description: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetUnanalyzedRequest {
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetElementsRequest {
    pub patent_id: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetProductFeaturesRequest {}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RecordProductFeatureRequest {
    pub feature_name: String,
    pub description: String,
    pub category: Option<String>,
    pub presence: Option<String>, // "present" or "absent"
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RecordSimilaritiesRequest {
    pub similarities: Vec<SimilarityInput>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct SimilarityInput {
    pub patent_id: String,
    pub claim_number: i64,
    pub element_label: String,
    pub similarity_level: String, // "Significant", "Moderate", "Limited"
    pub analysis_notes: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetUnresearchedRequest {
    pub limit: Option<usize>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct RecordPriorArtsRequest {
    pub prior_arts: Vec<PriorArtInput>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct PriorArtInput {
    pub reference_id: String,
    pub reference_type: String, // "patent" or "npl"
    pub title: String,
    pub publication_date: Option<String>,
    pub elements: Vec<PriorArtElementInput>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct PriorArtElementInput {
    pub patent_id: String,
    pub claim_number: i64,
    pub element_label: String,
    pub relevance_level: Option<String>, // "Significant", "Moderate", "Limited"
    pub analysis_notes: Option<String>,
    pub claim_chart: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetPatentDetailRequest {
    pub patent_id: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct GetProgressRequest {}

// ---------------------------------------------------------------------------
// Response / result types
// ---------------------------------------------------------------------------

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct IndexPatentsResult {
    pub count: usize,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct UnscreenedPatent {
    pub patent_id: String,
    pub title: String,
    pub assignee: Option<String>,
    pub country: Option<String>,
    pub filing_date: Option<String>,
    pub publication_date: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct UnevaluatedPatent {
    pub patent_id: String,
    pub title: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ClaimRow {
    pub patent_id: String,
    pub claim_number: i64,
    pub claim_type: String,
    pub claim_text: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ElementRow {
    pub patent_id: String,
    pub claim_number: i64,
    pub element_label: String,
    pub element_description: String,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct UnanalyzedPatent {
    pub patent_id: String,
    pub title: String,
    pub element_count: i64,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct ProductFeatureRow {
    pub feature_id: i64,
    pub feature_name: String,
    pub description: String,
    pub category: Option<String>,
    pub presence: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct SimilarityRow {
    pub patent_id: String,
    pub claim_number: i64,
    pub element_label: String,
    pub similarity_level: String,
    pub analysis_notes: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct UnresearchedPatent {
    pub patent_id: String,
    pub title: String,
    pub element_count: i64,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct Progress {
    pub total_targets: i64,
    pub total_screened: i64,
    pub relevant: i64,
    pub irrelevant: i64,
    pub expired: i64,
}

#[derive(Debug, Serialize, Deserialize, JsonSchema)]
pub struct PatentDetail {
    pub patent_id: String,
    pub title: Option<String>,
    pub assignee: Option<String>,
    pub country: Option<String>,
    pub extra_fields: Option<String>,
    pub publication_date: Option<String>,
    pub filing_date: Option<String>,
    pub grant_date: Option<String>,
    pub judgment: Option<String>,
    pub legal_status: Option<String>,
    pub reason: Option<String>,
    pub abstract_text: Option<String>,
}
