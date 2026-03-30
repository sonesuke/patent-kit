#!/bin/bash

if [ -z "$CI" ] && [ -z "$GITHUB_ACTIONS" ]; then

    # Install Claude CLI as vscode user if not already installed
    if ! command -v claude >/dev/null 2>&1; then
        echo "[Devcontainer Setup] Installing Claude CLI..."
        curl -fsSL https://claude.ai/install.sh | bash

        # Add .local/bin to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"

        # Add to shell configs for future sessions
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
    else
        echo "[Devcontainer Setup] Claude CLI already installed: $(claude --version)"
    fi

    echo "[Devcontainer Setup] Configuring claude alias..."
    echo 'alias claude="claude --allow-dangerously-skip-permissions"' >> $HOME/.bashrc
    echo 'alias claude="claude --allow-dangerously-skip-permissions"' >> $HOME/.zshrc

    # Install mise
    if ! command -v mise >/dev/null 2>&1; then
        echo "[Devcontainer Setup] Installing mise..."
        curl https://mise.run | sh

        # Add .local/bin to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"

        # Add to shell configs for future sessions
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.zshrc
    else
        echo "[Devcontainer Setup] mise already installed: $(mise --version)"
    fi

    echo "[Devcontainer Setup] Configuring mise..."
    echo 'eval "$(mise activate bash)"' >> $HOME/.bashrc
    echo 'eval "$(mise activate zsh)"' >> $HOME/.zshrc

    # Trust mise config and install tools
    if command -v mise >/dev/null 2>&1; then
        echo "[Devcontainer Setup] Trusting mise configuration..."
        mise trust

        echo "[Devcontainer Setup] Installing tools with mise..."
        mise install
    else
        echo "[Devcontainer Setup] WARNING: mise is not installed."
    fi

    echo "[Devcontainer Setup] Authenticating claude..."
    if [ -n "$Z_AI_API_KEY" ]; then
        mkdir -p "$HOME/.claude"
        cat > "$HOME/.claude/settings.json" <<EOF
{
    "env": {
        "ANTHROPIC_AUTH_TOKEN": "$Z_AI_API_KEY",
        "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
        "API_TIMEOUT_MS": "3000000",
        "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
        "ANTHROPIC_DEFAULT_OPUS_MODEL": "glm-5.1",
        "ANTHROPIC_DEFAULT_SONNET_MODEL": "glm-5-turbo",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL": "glm-4.5-air"
    }
}
EOF
    fi

    echo "[Devcontainer Setup] Installing MCP tools..."
    curl -fsSL https://raw.githubusercontent.com/sonesuke/google-patent-cli/main/install.sh | bash
    curl -fsSL https://raw.githubusercontent.com/sonesuke/arxiv-cli/main/install.sh | bash

    echo "[Devcontainer Setup] Configuring google-patent-cli for Docker..."
    mkdir -p ~/.config/google-patent-cli
    cat > ~/.config/google-patent-cli/config.toml << 'EOF'
# Chrome browser path
browser_path = "/usr/bin/chromium"

# Chrome arguments for Docker/DevContainer environment
chrome_args = [
    "--no-sandbox",
    "--disable-setuid-sandbox",
    "--disable-gpu"
]
EOF

    echo "[Devcontainer Setup] Configuring arxiv-cli for Docker..."
    mkdir -p ~/.config/arxiv-cli
    cat > ~/.config/arxiv-cli/config.toml << 'EOF'
# Chrome browser path
browser_path = "/usr/bin/chromium"

# Chrome arguments for Docker/DevContainer environment
chrome_args = [
    "--no-sandbox",
    "--disable-setuid-sandbox",
    "--disable-gpu"
]
EOF

    # Install external skills from marketplace
    echo "[Devcontainer Setup] Installing external skills..."
    if command -v claude >/dev/null 2>&1; then
        # Add marketplaces
        echo "[Devcontainer Setup]   Adding google-patent-cli marketplace..."
        claude plugin marketplace add sonesuke/google-patent-cli 2>/dev/null || echo "[Devcontainer Setup]   google-patent-cli marketplace already added or failed"

        echo "[Devcontainer Setup]   Adding arxiv-cli marketplace..."
        claude plugin marketplace add sonesuke/arxiv-cli 2>/dev/null || echo "[Devcontainer Setup]   arxiv-cli marketplace already added or failed"

        # Install skills
        echo "[Devcontainer Setup]   Installing google-patent-cli skills..."
        claude plugin install google-patent-cli@google-patent-cli-marketplace 2>/dev/null || echo "[Devcontainer Setup]   google-patent-cli skills already installed or failed"

        echo "[Devcontainer Setup]   Installing arxiv-cli skills..."
        claude plugin install arxiv-cli@arxiv-cli-marketplace 2>/dev/null || echo "[Devcontainer Setup]   arxiv-cli skills already installed or failed"
    else
        echo "[Devcontainer Setup] WARNING: Claude CLI not found, skipping skill installation"
    fi

    echo "[Devcontainer Setup] Complete!"
else
    echo "Running in CI environment, skipping development setup..."
fi
