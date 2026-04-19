#[tokio::main]
async fn main() -> anyhow::Result<()> {
    patent_kit::cli::run().await
}
