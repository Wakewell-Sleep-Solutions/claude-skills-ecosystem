#!/usr/bin/env bash
# vanta-mcp-wrapper.sh — Launches Vanta MCP server with Infisical credentials
# Secrets: VANTA_CLIENT_ID + VANTA_CLIENT_SECRET from Infisical /shared
set -euo pipefail

# Cross-platform PATH
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Git Bash on Windows mangles /paths — disable MSYS path conversion for infisical
export MSYS_NO_PATHCONV=1

# Pull credentials from Infisical and write temp credentials file
CRED_FILE=$(mktemp)
trap 'rm -f "$CRED_FILE"' EXIT

if command -v infisical &>/dev/null; then
  CLIENT_ID=$(infisical secrets get VANTA_CLIENT_ID --env=prod --path=/shared --plain 2>/dev/null || true)
  CLIENT_SECRET=$(infisical secrets get VANTA_CLIENT_SECRET --env=prod --path=/shared --plain 2>/dev/null || true)
fi

# Fallback to env vars (for CI or manual override)
CLIENT_ID="${CLIENT_ID:-${VANTA_CLIENT_ID:-}}"
CLIENT_SECRET="${CLIENT_SECRET:-${VANTA_CLIENT_SECRET:-}}"

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]]; then
  echo "Error: Vanta credentials not found." >&2
  echo "Add VANTA_CLIENT_ID + VANTA_CLIENT_SECRET to Infisical /shared" >&2
  echo "Get credentials from: https://developer.vanta.com/docs/api-access-setup" >&2
  exit 1
fi

printf '{"client_id":"%s","client_secret":"%s"}' "$CLIENT_ID" "$CLIENT_SECRET" > "$CRED_FILE"
export VANTA_ENV_FILE="$CRED_FILE"
exec npx -y @vantasdk/vanta-mcp-server
