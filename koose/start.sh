#!/usr/bin/env bash
# Koose AI — Zero-prompt startup script
# Reads all config from environment variables. No interactive wizard needed.
set -euo pipefail

KOOSE_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$KOOSE_DIR")"
STATE_DIR="${OPENCLAW_STATE_DIR:-$HOME/.openclaw}"
WORKSPACE_DIR="$STATE_DIR/workspace"
PORT="${PORT:-3000}"

# ---------------------------------------------------------------------------
# 1. Validate required env vars
# ---------------------------------------------------------------------------
if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "ERROR: ANTHROPIC_API_KEY is not set."
  echo "Set it in your .env file or export it before running this script."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Create directory structure
# ---------------------------------------------------------------------------
mkdir -p "$STATE_DIR/credentials" "$WORKSPACE_DIR" "$STATE_DIR/sessions" "$STATE_DIR/logs"

# ---------------------------------------------------------------------------
# 3. Copy Koose personality (SOUL.md) into workspace
# ---------------------------------------------------------------------------
if [ -f "$KOOSE_DIR/SOUL.md" ]; then
  cp "$KOOSE_DIR/SOUL.md" "$WORKSPACE_DIR/SOUL.md"
  echo "Copied Koose personality to $WORKSPACE_DIR/SOUL.md"
fi

# ---------------------------------------------------------------------------
# 4. Run non-interactive onboarding (sets up config + stores API key)
# ---------------------------------------------------------------------------
echo "Setting up Koose (non-interactive)..."
cd "$REPO_DIR"

node openclaw.mjs onboard \
  --non-interactive \
  --accept-risk \
  --anthropic-api-key "$ANTHROPIC_API_KEY" \
  --gateway-port "$PORT" \
  --gateway-bind "${GATEWAY_BIND:-lan}" \
  --skip-health \
  --skip-channels \
  --json 2>&1 || true

echo "Koose setup complete."

# ---------------------------------------------------------------------------
# 5. Start the gateway (web UI auto-available at http://host:PORT)
# ---------------------------------------------------------------------------
echo "Starting Koose on port $PORT..."
exec node openclaw.mjs gateway run \
  --allow-unconfigured \
  --port "$PORT" \
  --bind "${GATEWAY_BIND:-lan}" \
  --verbose
