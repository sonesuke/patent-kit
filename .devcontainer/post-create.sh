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

    echo "[Devcontainer Setup] Configuring tmux..."
    cat > $HOME/.tmux.conf << 'EOF'
# Display pane number
bind-key p display-panes
set display-panes-time 10000
EOF

    echo "[Devcontainer Setup] Configuring claude alias..."
    echo 'alias claude="claude --allow-dangerously-skip-permissions"' >> $HOME/.bashrc
    echo 'alias claude="claude --allow-dangerously-skip-permissions"' >> $HOME/.zshrc

    echo "[Devcontainer Setup] Configuring mise..."
    echo 'eval "$(mise activate bash)"' >> $HOME/.bashrc
    echo 'eval "$(mise activate zsh)"' >> $HOME/.zshrc

    # Run mise install
    if command -v mise >/dev/null 2>&1; then
        echo "[Devcontainer Setup] Installing tools with mise..."
        mise trust
        mise install
    else
        echo "[Devcontainer Setup] WARNING: mise is not installed."
    fi

    if [ -n "$Z_AI_API_KEY" ]; then
        npx -y @z_ai/coding-helper auth glm_coding_plan_global "$Z_AI_API_KEY"
        npx -y @z_ai/coding-helper auth reload claude
    fi

    echo "[Devcontainer Setup] Installing MCP tools..."
    curl -fsSL https://raw.githubusercontent.com/sonesuke/google-patent-cli/main/install.sh | bash
    curl -fsSL https://raw.githubusercontent.com/sonesuke/arxiv-cli/main/install.sh | bash

    echo "[Devcontainer Setup] Configuring google-patent-cli for Docker..."
    mkdir -p ~/.config/google-patent-cli
    cat > ~/.config/google-patent-cli/config.toml << 'EOF'
# Chrome arguments for Docker/DevContainer environment
chrome_args = [
    "--no-sandbox",
    "--disable-setuid-sandbox",
    "--disable-gpu"
]
EOF

    echo "[Devcontainer Setup] Complete!"
else
    echo "Running in CI environment, skipping development setup..."
fi
