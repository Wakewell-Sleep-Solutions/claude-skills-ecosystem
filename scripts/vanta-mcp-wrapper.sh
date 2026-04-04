#!/usr/bin/env bash
# vanta-mcp-wrapper.sh — Launches Vanta MCP server with credentials file
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

CRED_FILE="$HOME/.claude/vanta-credentials.json"

if [[ ! -f "$CRED_FILE" ]]; then
  echo "Error: $CRED_FILE not found." >&2
  echo "Create it with: {\"client_id\": \"...\", \"client_secret\": \"...\"}" >&2
  exit 1
fi

export VANTA_ENV_FILE="$CRED_FILE"
exec npx -y @vantasdk/vanta-mcp-server
