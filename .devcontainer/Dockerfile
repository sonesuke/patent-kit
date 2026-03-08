FROM debian:bookworm-slim

# Set UTF-8 locale
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install Node.js and other dependencies as root
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    git \
    pkg-config \
    libssl-dev \
    ripgrep \
    tmux \
    vim \
    jq \
    sudo \
    ca-certificates \
    sqlite3 \
    python3 \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Note: mise is installed in post-create.sh to allow user-specific configuration

# Install Node.js LTS manually
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Chromium and dependencies for browser-based MCP
RUN apt-get update && apt-get install -y \
    chromium \
    chromium-common \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
