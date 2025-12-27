use anyhow::{Context, Result};
use clap::{Parser, Subcommand, ValueEnum};
use flate2::read::GzDecoder;
use rust_embed::RustEmbed;
use std::fs;
use std::fs::File;
use std::io::{self, Cursor};
use std::path::{Path, PathBuf};
use tar::Archive;
use zip::ZipArchive;

#[derive(RustEmbed)]
#[folder = "src/templates"]
struct Asset;

#[derive(Parser, Debug)]
#[command(name = "ftoc")]
#[command(about = "Generate Table of Contents for Markdown files or initialize project", long_about = None)]
struct Args {
    #[command(subcommand)]
    command: Commands,
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

        /// Skip SSL verification for downloads
        #[arg(long)]
        insecure: bool,
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
        Commands::Init { path, ai, insecure } => init_project(path, ai, insecure),
    }
}

fn init_project(path: PathBuf, ai: AiAssistant, insecure: bool) -> Result<()> {
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
    // Copy common templates (.patent-kit)
    copy_embedded_dir(
        "common/templates",
        &target_dir.join(".patent-kit/templates"),
    )?;

    // Generate AI specific prompts
    generate_prompts(ai, &target_dir)?;

    // Install dependencies (arxiv-cli, google-patent-cli)
    install_dependencies(&target_dir, insecure)?;

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
            // strip leading slash if present
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

fn generate_prompts(ai: AiAssistant, target_dir: &Path) -> Result<()> {
    let (output_dir, file_suffix) = match ai {
        AiAssistant::Claude => (target_dir.join(".claude/commands"), ".md"),
        AiAssistant::Copilot => (target_dir.join(".github/prompts"), ".prompt.md"),
    };

    if !output_dir.exists() {
        fs::create_dir_all(&output_dir).context("Failed to create prompt directory")?;
    }

    let prefix = "common/prompts";
    for file_path in Asset::iter() {
        let file_path_str = file_path.as_ref();
        if file_path_str.starts_with(prefix) {
            let filename = Path::new(file_path_str)
                .file_name()
                .and_then(|s| s.to_str())
                .context("Failed to get filename")?;

            let name_stem = filename.trim_end_matches(".md");

            let content = Asset::get(file_path_str)
                .context("Failed to read embedded file")?
                .data;
            let content_str = std::str::from_utf8(content.as_ref())
                .context("Failed to parse embedded file as UTF-8")?;

            let next_step_instruction = get_next_step_instruction(ai, name_stem);
            let new_content =
                content_str.replace("{{ NEXT_STEP_INSTRUCTION }}", &next_step_instruction);

            let new_filename = format!("patent-kit.{}{}", name_stem, file_suffix);
            let dest_path = output_dir.join(new_filename);

            fs::write(&dest_path, new_content)
                .with_context(|| format!("Failed to write prompt file {:?}", dest_path))?;
            println!("Generated: {:?}", dest_path);
        }
    }

    Ok(())
}

fn get_next_step_instruction(ai: AiAssistant, phase: &str) -> String {
    match (ai, phase) {
        (AiAssistant::Claude, "screening") => {
            "Run /patent-kit.evaluation investigations/<patent-id>/screening.md".to_string()
        }
        (AiAssistant::Claude, "evaluation") => {
            "Run /patent-kit.infringement investigations/<patent-id>/evaluation.md".to_string()
        }
        (AiAssistant::Claude, "infringement") => {
            "Run /patent-kit.prior investigations/<patent-id>/infringement.md".to_string()
        }
        // No next step for prior
        (AiAssistant::Claude, _) => "".to_string(),

        (AiAssistant::Copilot, "screening") => {
            "## Next Step\n\nRun Phase 2 (Evaluation).".to_string()
        }
        (AiAssistant::Copilot, "evaluation") => {
            "## Next Step\n\nRun Phase 3 (Infringement).".to_string()
        }
        (AiAssistant::Copilot, "infringement") => {
            "## Next Step\n\nRun Phase 4 (Prior Art).".to_string()
        }
        (AiAssistant::Copilot, _) => "".to_string(),
    }
}
fn install_dependencies(target_dir: &Path, insecure: bool) -> Result<()> {
    let bin_dir = target_dir.join(".patent-kit").join("bin");
    if !bin_dir.exists() {
        fs::create_dir_all(&bin_dir).context("Failed to create bin directory")?;
    }

    let tools = [
        (
            "google-patent-cli",
            "https://github.com/sonesuke/google-patent-cli",
        ),
        ("arxiv-cli", "https://github.com/sonesuke/arxiv-cli"),
    ];

    for (name, repo_url) in tools {
        let exe_name = if cfg!(windows) {
            format!("{}.exe", name)
        } else {
            name.to_string()
        };

        let dest_path = bin_dir.join(&exe_name);
        if dest_path.exists() {
            println!("{} already exists in {:?}", name, bin_dir);
            continue;
        }

        println!("Downloading {}...", name);
        if let Err(e) = download_and_install_tool(name, repo_url, &bin_dir, insecure) {
            eprintln!("Failed to install {}: {}", name, e);
            // Don't fail the whole init process if download fails, just warn
        }
    }

    Ok(())
}

fn download_and_install_tool(
    name: &str,
    repo_base: &str,
    bin_dir: &Path,
    insecure: bool,
) -> Result<()> {
    let os = std::env::consts::OS;
    let arch = std::env::consts::ARCH;

    let (target_os, target_arch, ext) = match (os, arch) {
        ("macos", "x86_64") => ("macos", "x86_64", "tar.gz"),
        ("macos", "aarch64") => ("macos", "arm64", "tar.gz"),
        ("linux", "x86_64") => ("linux", "x86_64", "tar.gz"),
        ("windows", "x86_64") => ("windows", "x86_64", "zip"),
        _ => anyhow::bail!("Unsupported platform: {} {}", os, arch),
    };

    let filename = format!("{}-{}-{}.{}", name, target_os, target_arch, ext);
    let url = format!("{}/releases/latest/download/{}", repo_base, filename);

    let client = reqwest::blocking::Client::builder()
        .danger_accept_invalid_certs(insecure)
        .build()?;

    let response = client
        .get(&url)
        .send()
        .with_context(|| format!("Failed to download from {}", url))?;

    if !response.status().is_success() {
        anyhow::bail!("Failed to download tool: HTTP {}", response.status());
    }

    let items = response.bytes()?;

    if ext == "zip" {
        let reader = Cursor::new(items);
        let mut archive = ZipArchive::new(reader)?;

        // We expect the binary to be at the root or flexible
        // The release archives usually contain the binary directly
        for i in 0..archive.len() {
            let mut file = archive.by_index(i)?;
            let file_name = file.name().to_string();
            // Simple check: simple filename matches expected binary name (with or without .exe)
            if Path::new(&file_name).file_stem().and_then(|s| s.to_str()) == Some(name) {
                let dest = bin_dir.join(file.enclosed_name().unwrap_or(Path::new(&file_name)));
                let mut outfile = File::create(&dest)?;
                io::copy(&mut file, &mut outfile)?;
                return Ok(());
            }
        }
    } else {
        let tar = GzDecoder::new(Cursor::new(items));
        let mut archive = Archive::new(tar);

        for entry in archive.entries()? {
            let mut entry = entry?;
            let path = entry.path()?;
            let path_str = path.to_string_lossy();

            // Check if this entry is likely the binary
            if Path::new(path_str.as_ref())
                .file_stem()
                .and_then(|s| s.to_str())
                == Some(name)
            {
                let dest = bin_dir.join(path.file_name().unwrap());
                entry.unpack(&dest)?;

                #[cfg(unix)]
                {
                    use std::os::unix::fs::PermissionsExt;
                    let mut perms = fs::metadata(&dest)?.permissions();
                    perms.set_mode(0o755);
                    fs::set_permissions(&dest, perms)?;
                }
                return Ok(());
            }
        }
    }

    anyhow::bail!("Binary not found in archive")
}
