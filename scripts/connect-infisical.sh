#!/bin/bash
# Connect a project to its Infisical folder
# Usage: bash connect-infisical.sh [project-name]
#
# Maps each project to the right Infisical path so `irun` injects
# the correct secrets for that project.

# Organization: henry-qiu-os
WORKSPACE_ID="1f135b54-94e2-4869-84bc-5f792b8d150f"

# Auto-detect project from current directory
if [ -n "$1" ]; then
  PROJECT="$1"
else
  DIR_NAME=$(basename "$(pwd)")
  case "$DIR_NAME" in
    Claude|aria-slack-bot)   PROJECT="aria" ;;
    super-rcm)               PROJECT="rcm" ;;
    5dsmiles-landing)        PROJECT="dashboard" ;;
    WakewellWeb)             PROJECT="web" ;;
    claude-skills-ecosystem) PROJECT="skills" ;;
    *)                       PROJECT="" ;;
  esac
fi

# Map project to Infisical path
case "$PROJECT" in
  aria|rcm|super-rcm|dashboard|5dsmiles)
    INFISICAL_PATH="/server"
    ;;
  web|wakewellweb|skills)
    INFISICAL_PATH="/shared"
    ;;
  henry|admin)
    INFISICAL_PATH="/henry-only"
    ;;
  *)
    echo "Which Infisical folder does this project use?"
    echo ""
    echo "  1) /shared      — team-wide secrets (default)"
    echo "  2) /server      — server-side API keys (Aria, RCM, Dashboard)"
    echo "  3) /henry-only  — admin-only keys"
    echo ""
    read -p "Choice [1]: " CHOICE
    case "$CHOICE" in
      2) INFISICAL_PATH="/server" ;;
      3) INFISICAL_PATH="/henry-only" ;;
      *) INFISICAL_PATH="/shared" ;;
    esac
    ;;
esac

echo ""
echo "Connecting $(basename "$(pwd)") → Infisical $INFISICAL_PATH"

# Write .infisical.json in current project
cat > .infisical.json <<EOF
{
    "workspaceId": "$WORKSPACE_ID",
    "defaultEnvironment": "prod",
    "gitBranchToEnvironmentMapping": null,
    "defaultSecretPath": "$INFISICAL_PATH"
}
EOF

echo "✅ .infisical.json written"

# Verify secrets are accessible (count only — NEVER show values)
SECRET_COUNT=$(infisical secrets --env=prod --path="$INFISICAL_PATH" --silent 2>/dev/null | grep -c "│" || echo "0")
if [ "$SECRET_COUNT" -gt 0 ]; then
  echo "✅ $SECRET_COUNT secrets accessible at $INFISICAL_PATH"
else
  echo "⚠️  No secrets found at $INFISICAL_PATH — check Infisical auth"
fi

echo ""
echo "Usage: irun <command>  — runs command with secrets injected"
echo "Example: irun python aria/main.py"
