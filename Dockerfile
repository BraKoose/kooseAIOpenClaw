# =============================================================================
# Koose AI — Dockerfile
# Zero-prompt deployment. All config via environment variables.
# =============================================================================
FROM node:22-bookworm@sha256:cd7bcd2e7a1e6f72052feb023c7f6b722205d3fcab7bbcbd2d1bfdab10b1e935

# Install Bun (required for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app
RUN chown node:node /app

# -- Install dependencies (cached layer) --
COPY --chown=node:node package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY --chown=node:node ui/package.json ./ui/package.json
COPY --chown=node:node patches ./patches
COPY --chown=node:node scripts ./scripts

USER node
RUN pnpm install --frozen-lockfile

# -- Copy source and build --
USER node
COPY --chown=node:node . .
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm build && pnpm ui:build

# -- Koose personality is baked into the image --
# koose/SOUL.md is copied to the workspace at startup by koose/start.sh

ENV NODE_ENV=production

# Security: run as non-root
USER node

# -- Startup --
# koose/start.sh handles:
#   1. Validates ANTHROPIC_API_KEY from env
#   2. Runs non-interactive onboarding (no prompts)
#   3. Copies SOUL.md personality into workspace
#   4. Starts the gateway with WebChat on $PORT
#
# Required env vars (set via fly secrets or docker run -e):
#   ANTHROPIC_API_KEY  — your Anthropic API key
#
# Optional env vars:
#   PORT               — server port (default: 3000)
#   GATEWAY_BIND       — bind mode (default: lan)
#   OPENCLAW_STATE_DIR — state directory (default: ~/.openclaw)
CMD ["bash", "koose/start.sh"]
