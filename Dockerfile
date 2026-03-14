FROM node:22-bookworm-slim

# System deps + Chromium dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates openssh-client jq procps \
    # Chromium and its dependencies for headless browser
    chromium \
    fonts-liberation fonts-noto-color-emoji \
    libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
    libpango-1.0-0 libasound2 \
    && rm -rf /var/lib/apt/lists/*

# Set Chromium env vars for OpenClaw/Playwright
ENV CHROME_BIN=/usr/bin/chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium

# Install OpenClaw globally
RUN npm install -g openclaw@2026.3.8

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
CMD ["openclaw", "gateway"]
