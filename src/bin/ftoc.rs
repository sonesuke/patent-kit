use clap::Parser;
use std::fs;
use std::io::{self, BufRead, BufReader};
use std::path::PathBuf;

#[derive(Parser, Debug)]
#[command(name = "ftoc")]
#[command(about = "Generate Table of Contents for Markdown files", long_about = None)]
struct Args {
    /// Markdown file to process
    #[arg(value_name = "FILE")]
    file: PathBuf,

    /// Minimum heading level to include (default: 1)
    #[arg(long, default_value = "1")]
    min_depth: usize,

    /// Maximum heading level to include (default: 6)
    #[arg(long, default_value = "6")]
    max_depth: usize,
}

fn main() -> io::Result<()> {
    let args = Args::parse();

    let file = fs::File::open(&args.file)?;
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
            
            if level >= args.min_depth && level <= args.max_depth {
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
        let indent = "  ".repeat(level - args.min_depth);
        println!("{}- [{}](#{anchor})", indent, title);
    }

    Ok(())
}
