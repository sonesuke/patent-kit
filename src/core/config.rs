use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct Config {
    pub browser_path: Option<PathBuf>,
    pub chrome_args: Vec<String>,
    pub db_path: Option<PathBuf>,
}

impl Config {
    pub fn load() -> Result<Self> {
        let config_dir = Self::config_dir()?;
        let config_path = config_dir.join("config.toml");
        if config_path.exists() {
            let content = std::fs::read_to_string(&config_path)?;
            let config: Config = toml::from_str(&content)?;
            Ok(config)
        } else {
            Ok(Config::default())
        }
    }

    pub fn save(&self) -> Result<()> {
        let config_dir = Self::config_dir()?;
        std::fs::create_dir_all(&config_dir)?;
        let config_path = config_dir.join("config.toml");
        let content = toml::to_string_pretty(self)?;
        std::fs::write(&config_path, content)?;
        Ok(())
    }

    fn config_dir() -> Result<PathBuf> {
        let base = directories::ProjectDirs::from("com", "patent-kit", "patent-kit")
            .map(|d| d.config_dir().to_path_buf())
            .or_else(|| {
                let home = std::env::var("HOME").ok()?;
                Some(PathBuf::from(home).join(".config/patent-kit"))
            })
            .ok_or_else(|| anyhow::anyhow!("Cannot determine config directory"))?;
        Ok(base)
    }

    pub fn resolve_db_path(&self) -> PathBuf {
        self.db_path
            .clone()
            .unwrap_or_else(|| PathBuf::from("patents.db"))
    }

    pub fn resolve_browser(&self) -> (Option<PathBuf>, Vec<String>) {
        let browser_path = self.browser_path.clone().or_else(|| {
            let candidates = [
                "/bin/chromium",
                "/bin/google-chrome",
                "/bin/google-chrome-stable",
                "/usr/bin/chromium",
                "/usr/bin/google-chrome",
                "/usr/bin/google-chrome-stable",
            ];
            candidates
                .iter()
                .find(|p| PathBuf::from(*p).exists())
                .map(|p| PathBuf::from(*p))
        });
        let chrome_args = if self.chrome_args.is_empty() {
            vec![
                "--no-sandbox".to_string(),
                "--disable-setuid-sandbox".to_string(),
                "--disable-gpu".to_string(),
            ]
        } else {
            self.chrome_args.clone()
        };
        (browser_path, chrome_args)
    }
}
