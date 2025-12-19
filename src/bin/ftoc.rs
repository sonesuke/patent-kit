use anyhow::{Context, Result};
use clap::{Parser, Subcommand, ValueEnum};
use rust_embed::RustEmbed;
use std::fs;
use std::io::{BufRead, BufReader};
use std::path::{Path, PathBuf};

#[derive(RustEmbed)]
#[folder = "src/templates"]
struct Asset;

#[derive(Parser, Debug)]
#[command(name = "ftoc")]
#[command(about = "Generate Table of Contents for Markdown files or initialize project", long_about = None)]
struct Args {
    #[command(subcommand)]
    command: Option<Commands>,

    /// Markdown file to process (backwards compatibility for default TOC behavior)
    #[arg(value_name = "FILE")]
    file: Option<PathBuf>,

    /// Minimum heading level to include (default: 1)
    #[arg(long, default_value = "1")]
    min_depth: usize,

    /// Maximum heading level to include (default: 6)
    #[arg(long, default_value = "6")]
    max_depth: usize,
}

#[derive(Subcommand, Debug)]
enum Commands {
    /// Initialize a new project or configure current directory
    Init {
        /// Project name (defaults to current directory if ".")
        #[arg(default_value = ".")]
        path: PathBuf,

        /// AI assistant to configure
        #[arg(long, value_enum)]
        ai: AiAssistant,
    },
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum AiAssistant {
    Claude,
    Copilot,
}

fn main() -> Result<()> {
    let args = Args::parse();

    match args.command {
        Some(Commands::Init { path, ai }) => init_project(path, ai),
        None => {
            if let Some(file) = args.file {
                generate_toc(file, args.min_depth, args.max_depth)
            } else {
                // Should be unreachable due to required_unless_present, but good fallback
                anyhow::bail!("No file specified or command provided")
            }
        }
    }
}

fn init_project(path: PathBuf, ai: AiAssistant) -> Result<()> {
    let target_dir = if path.to_string_lossy() == "." {
        std::env::current_dir().context("Failed to get current directory")?
    } else {
        path
    };

    if !target_dir.exists() {
        fs::create_dir_all(&target_dir).context("Failed to create project directory")?;
        println!("Created directory: {:?}", target_dir);
    }

    // Copy common templates (.patent-kit)
    copy_embedded_dir("common", &target_dir.join(".patent-kit"))?;

    // Copy AI specific templates
    match ai {
        AiAssistant::Claude => {
            copy_embedded_dir("claude", &target_dir.join(".claude"))?;
        }
        AiAssistant::Copilot => {
            if Asset::get("copilot").is_none() {
                // Try to fallback or check if directory exists in embed even if empty
                // rust-embed doesn't list directories easily, but we know the structure
                // If we just copy "copilot" folder content
                copy_embedded_dir("copilot", &target_dir.join(".github"))?;
            } else {
                copy_embedded_dir("copilot", &target_dir.join(".github"))?;
            }
        }
    }

    println!(
        "Initialized project in {:?} with {:?} configuration",
        target_dir, ai
    );
    Ok(())
}

fn copy_embedded_dir(prefix: &str, target_path: &Path) -> Result<()> {
    for file_path in Asset::iter() {
        let file_path_str = file_path.as_ref();
        if file_path_str.starts_with(prefix) {
            let relative_path = file_path_str.strip_prefix(prefix).unwrap_or(file_path_str);
            // strip leading slash if present (it shouldn't be for strip_prefix but handling just in case logic matches)
            let relative_path = relative_path.trim_start_matches('/');

            if relative_path.is_empty() {
                continue;
            }

            let dest_path = target_path.join(relative_path);

            if let Some(parent) = dest_path.parent() {
                fs::create_dir_all(parent).context("Failed to create parent directory")?;
            }

            let content = Asset::get(file_path_str).context("Failed to read embedded file")?;
            fs::write(&dest_path, content.data)
                .with_context(|| format!("Failed to write file {:?}", dest_path))?;
            println!("Created: {:?}", dest_path);
        }
    }
    Ok(())
}

fn generate_toc(file_path: PathBuf, min_depth: usize, max_depth: usize) -> Result<()> {
    let file = fs::File::open(&file_path)
        .with_context(|| format!("Failed to open file {:?}", file_path))?;
    let reader = BufReader::new(file);

    let mut toc_entries = Vec::new();
    let mut in_frontmatter = false;
    let mut frontmatter_count = 0;

    for line in reader.lines() {
        let line = line?;
        let trimmed = line.trim();

        // Handle YAML frontmatter
        if trimmed == "---" {
            frontmatter_count += 1;
            if frontmatter_count <= 2 {
                in_frontmatter = !in_frontmatter;
                continue;
            }
        }

        if in_frontmatter {
            continue;
        }

        // Parse headings
        if trimmed.starts_with('#') {
            let level = trimmed.chars().take_while(|&c| c == '#').count();

            if level >= min_depth && level <= max_depth {
                let title = trimmed[level..].trim();
                let anchor = title
                    .to_lowercase()
                    .replace(|c: char| !c.is_alphanumeric() && c != ' ' && c != '-', "")
                    .replace(' ', "-");

                toc_entries.push((level, title.to_string(), anchor));
            }
        }
    }

    // Print the table of contents
    println!("## Table of Contents\n");
    for (level, title, anchor) in toc_entries {
        let indent = "  ".repeat(level - min_depth);
        println!("{}- [{}](#{anchor})", indent, title);
    }

    Ok(())
}
