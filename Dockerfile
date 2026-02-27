FROM node:22-bookworm-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates openssh-client jq procps \
    && rm -rf /var/lib/apt/lists/*

# Install OpenClaw globally
RUN npm install -g openclaw@latest

# Install Claude Code CLI (for coding sub-agents)
RUN npm install -g @anthropic-ai/claude-code@latest 2>/dev/null || true

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*

# Workspace and config dirs (will be PVC-mounted)
RUN mkdir -p /root/.openclaw/workspace /root/.openclaw/skills

# Default port for gateway
EXPOSE 18789

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
    CMD curl -sf http://localhost:18789/health || exit 1

# Start OpenClaw gateway
# OpenClaw gateway runs in foreground by default when started directly
CMD ["openclaw", "gateway", "--bind", "lan"]
