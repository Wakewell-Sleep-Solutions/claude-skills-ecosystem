#!/bin/bash
# WakeWell / 5D Smiles — New Machine Bootstrap (macOS + Windows)
# Source of truth: claude-skills-ecosystem repo
#
# Fresh machine:   bash <(curl -s https://raw.githubusercontent.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem/main/scripts/bootstrap.sh)
# Existing clone:  bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh

set -e

echo "========================================="
echo "  WakeWell AI Command Center — Setup"
echo "========================================="
echo ""

PROJECTS="$HOME/Documents"
SKILLS_REPO="$PROJECTS/claude-skills-ecosystem"

# ─── 0. Detect OS and source package managers ────────────
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

OS="unknown"
PKG_INSTALL=""
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]] || uname -r 2>/dev/null | grep -qi microsoft; then
  OS="windows"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
fi
echo "Detected OS: $OS"

# ─── 1. Package manager ─────────────────────────────────
if [ "$OS" = "macos" ]; then
  if command -v brew >/dev/null 2>&1; then
    : # already in PATH
  elif [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  if ! command -v brew >/dev/null 2>&1; then
    echo "📥 Installing Homebrew (you may need to enter your password)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
  else
    echo "✅ Homebrew: installed"
  fi
  PKG_INSTALL="brew install"
elif [ "$OS" = "windows" ]; then
  if command -v winget >/dev/null 2>&1; then
    echo "✅ winget: available"
    PKG_INSTALL="winget install --accept-package-agreements --accept-source-agreements -e --id"
  elif command -v choco >/dev/null 2>&1; then
    echo "✅ chocolatey: available"
    PKG_INSTALL="choco install -y"
  else
    echo "⚠️  No package manager found (winget or chocolatey). Using npm/pip for installs."
    PKG_INSTALL=""
  fi
fi

# Helper: install a tool cross-platform
install_tool() {
  local tool="$1"
  local brew_pkg="${2:-$tool}"
  local winget_id="${3:-}"
  local npm_pkg="${4:-}"
  local pip_pkg="${5:-}"

  if command -v "$tool" >/dev/null 2>&1; then
    echo "  ✅ $tool"
    return 0
  fi

  echo "  📥 Installing $tool..."
  if [ "$OS" = "macos" ]; then
    brew install "$brew_pkg" 2>/dev/null || echo "  ⚠️  brew install $brew_pkg failed"
  elif [ "$OS" = "windows" ]; then
    # Try winget first, then npm, then pip
    if [ -n "$winget_id" ] && command -v winget >/dev/null 2>&1; then
      winget install --accept-package-agreements --accept-source-agreements -e --id "$winget_id" 2>/dev/null || true
    fi
    # Check again — winget may have worked
    if ! command -v "$tool" >/dev/null 2>&1; then
      if [ -n "$npm_pkg" ] && command -v npm >/dev/null 2>&1; then
        npm install -g "$npm_pkg" 2>/dev/null || true
      fi
    fi
    if ! command -v "$tool" >/dev/null 2>&1; then
      if [ -n "$pip_pkg" ] && command -v pip >/dev/null 2>&1; then
        pip install "$pip_pkg" 2>/dev/null || pip3 install "$pip_pkg" 2>/dev/null || true
      fi
    fi
    command -v "$tool" >/dev/null 2>&1 || echo "  ⚠️  $tool install failed — install manually"
  else
    echo "  ⚠️  Manual install needed for $tool on $OS"
  fi
}

# ─── 2. Core tools ────────────────────────────────────────
echo ""
echo "Core tools:"
#                tool        brew_pkg        winget_id                       npm_pkg     pip_pkg
install_tool     git         git             "Git.Git"                       ""          ""
install_tool     node        node            "OpenJS.NodeJS.LTS"            ""          ""
install_tool     gh          gh              "GitHub.cli"                    ""          ""
if [ "$OS" = "macos" ]; then
  install_tool   tmux        tmux            ""                              ""          ""
fi
install_tool     az          azure-cli       "Microsoft.AzureCLI"           ""          ""

# ─── 3. Claude Code ───────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  echo "  ✅ claude ($(claude --version 2>/dev/null || echo 'installed'))"
else
  echo "  📥 Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || echo "  ⚠️  Claude Code install failed"
fi

# ─── 4. Ruflo ─────────────────────────────────────────────
if command -v ruflo >/dev/null 2>&1; then
  echo "  ✅ ruflo"
else
  echo "  📥 Installing Ruflo..."
  npm install -g ruflo 2>/dev/null || echo "  ⚠️  Ruflo install failed — install manually: npm install -g ruflo"
fi

# ─── 4b. Code Analysis & Security Tools ───────────────────
echo ""
echo "Code analysis & security tools (closed-loop audit pipeline):"

#                tool            brew_pkg        winget_id       npm_pkg                 pip_pkg
install_tool     semgrep         semgrep         ""              ""                      "semgrep"
install_tool     snyk            ""              ""              "snyk"                  ""
install_tool     eslint          ""              ""              "eslint"                ""
install_tool     tsc             ""              ""              "typescript"            ""
install_tool     sonar-scanner   sonar-scanner   ""              ""                      ""

# sonar-scanner on Windows — special handling (no npm/pip package)
if [ "$OS" = "windows" ] && ! command -v sonar-scanner >/dev/null 2>&1; then
  echo "  ⚠️  sonar-scanner: Install manually from https://docs.sonarsource.com/sonarcloud/advanced-setup/ci-based-analysis/sonarscanner-cli/"
  echo "     Or download: https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/"
fi

# npm global packages that work cross-platform
if ! command -v eslint >/dev/null 2>&1; then
  echo "  📥 Installing ESLint + TypeScript ESLint plugins..."
  npm install -g eslint typescript @typescript-eslint/parser @typescript-eslint/eslint-plugin 2>/dev/null || true
fi

# ─── 4c. Snyk Authentication ─────────────────────────────
if command -v snyk >/dev/null 2>&1; then
  if snyk whoami >/dev/null 2>&1; then
    echo "  ✅ Snyk: authenticated"
  else
    echo ""
    echo "  ⚠️  Snyk needs authentication. Run after bootstrap:"
    echo "     snyk auth"
    echo "  (Opens browser — sign up free with GitHub)"
  fi
fi

# ─── 4d. Code Analyzer Scripts ────────────────────────────
echo ""
echo "Closed-loop analyzer scripts:"
SCRIPTS_DIR="$PROJECTS/scripts"
mkdir -p "$SCRIPTS_DIR"

for script in code-analyzer.sh claude-hook-analyze.sh vanta-mcp-wrapper.sh; do
  if [ -x "$SCRIPTS_DIR/$script" ]; then
    echo "  ✅ $script"
  elif [ -f "$SKILLS_REPO/scripts/$script" ]; then
    cp "$SKILLS_REPO/scripts/$script" "$SCRIPTS_DIR/$script"
    chmod +x "$SCRIPTS_DIR/$script"
    echo "  ✅ $script (installed from skills repo)"
  else
    echo "  ⚠️  $script missing — not in ~/Documents/scripts/ or skills repo"
  fi
done

# ─── 4e. Vanta Credentials ───────────────────────────────
if [ -f "$HOME/.claude/vanta-credentials.json" ]; then
  echo "  ✅ Vanta credentials file exists"
else
  echo "  ⚠️  Vanta credentials missing. Create ~/.claude/vanta-credentials.json with:"
  echo '     {"client_id": "...", "client_secret": "..."}'
  echo "  Get credentials from: https://developer.vanta.com/docs/api-access-setup"
fi

echo ""
echo "✅ All tools installed"

# ─── 5. GitHub auth ───────────────────────────────────────
echo ""
if gh auth status >/dev/null 2>&1; then
  echo "✅ GitHub: logged in as $(gh api user -q .login 2>/dev/null)"
else
  echo "⚠️  GitHub not authenticated. Run: gh auth login"
fi

# ─── 6. Infisical ─────────────────────────────────────────
if ! command -v infisical >/dev/null 2>&1; then
  echo "  📥 Installing Infisical..."
  if [ "$OS" = "macos" ]; then
    brew install infisical/get-cli/infisical 2>/dev/null || echo "  ⚠️  Infisical install failed"
  else
    npm install -g @infisical/cli 2>/dev/null || echo "  ⚠️  Infisical install failed — try: npm install -g @infisical/cli"
  fi
else
  echo "  ✅ infisical"
fi

if command -v infisical >/dev/null 2>&1; then
  INFISICAL_AUTHED=false
  infisical user get >/dev/null 2>&1 && INFISICAL_AUTHED=true
  [ "$INFISICAL_AUTHED" = "false" ] && infisical whoami >/dev/null 2>&1 && INFISICAL_AUTHED=true

  if [ "$INFISICAL_AUTHED" = "true" ]; then
    echo "  ✅ Infisical: already authenticated"
  else
    echo ""
    echo "  ⚠️  Infisical not authenticated. Run manually in Terminal:"
    echo "     infisical login"
    echo "  (Opens browser for SSO login — select Infisical Cloud US)"
  fi

  if infisical secrets --env=prod --path=/shared --silent >/dev/null 2>&1; then
    echo "  ✅ Infisical: secrets accessible in /shared"
  else
    echo "  ⚠️  Infisical: can't read /shared secrets — check auth or ask admin"
  fi
fi

# ─── 7. Clone/sync org repos ─────────────────────────────
echo ""
echo "Setting up projects..."
mkdir -p "$PROJECTS"

REPO_MAP=$(mktemp)
find "$PROJECTS" -maxdepth 2 -name ".git" -type d 2>/dev/null | while read gitdir; do
  REPO_DIR=$(dirname "$gitdir")
  REMOTE=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)
  if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
    REPO_NAME=$(echo "$REMOTE" | sed 's|.*/||' | sed 's|\.git$||')
    echo "$REPO_NAME|$REPO_DIR" >> "$REPO_MAP"
  fi
done

SKIP_REPOS="WakewellRailway ODGHLSync opendentalsynctool SmartCoach salescoach"

REPO_LIST=$(gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null)

echo "$REPO_LIST" | while read repo; do
  [ -z "$repo" ] && continue
  if echo "$SKIP_REPOS" | grep -qw "$repo"; then
    echo "  ⏭️  $repo (skipped — dead/duplicate)"
    continue
  fi

  EXISTING=$(grep "^${repo}|" "$REPO_MAP" 2>/dev/null | head -1 | cut -d'|' -f2)

  if [ -n "$EXISTING" ]; then
    echo "  ✅ $(basename $EXISTING)/ (pulling latest)"
    git -C "$EXISTING" pull --ff-only 2>/dev/null || echo "    ⚠️  Pull skipped (local changes or worktree)"
  else
    TARGET="$PROJECTS/$repo"
    [ "$repo" = "aria-slack-bot" ] && TARGET="$PROJECTS/Claude"
    if [ -d "$TARGET" ]; then
      echo "  ⏭️  $(basename $TARGET)/ (exists, not this repo — skipping)"
    else
      gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null && echo "  ✅ $(basename $TARGET)/ (cloned)" || true
    fi
  fi
done

rm -f "$REPO_MAP"

# ─── 8. Global config from skills repo ───────────────────
echo ""

if [ ! -d "$SKILLS_REPO" ]; then
  for d in "$HOME/.claude-skills" "$PROJECTS/claude-skills-ecosystem"; do
    [ -d "$d" ] && SKILLS_REPO="$d" && break
  done
fi

mkdir -p "$HOME/.claude/rules"

# Global CLAUDE.md — only install if missing, never overwrite user's version
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  echo "✅ Global CLAUDE.md exists (not overwriting — user-managed)"
elif [ -f "$SKILLS_REPO/config/global-claude.md" ]; then
  cp "$SKILLS_REPO/config/global-claude.md" "$HOME/.claude/CLAUDE.md"
  echo "✅ Global CLAUDE.md installed from repo"
else
  echo "⚠️  Global CLAUDE.md not found — create ~/.claude/CLAUDE.md manually"
fi

if [ -d "$SKILLS_REPO/config/rules" ]; then
  for f in "$SKILLS_REPO/config/rules/"*.md; do
    [ -f "$f" ] && cp "$f" "$HOME/.claude/rules/$(basename "$f")"
  done
  echo "✅ Global rules synced"
fi

# ─── 9. MCP servers ───────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  echo ""
  echo "Setting up MCP servers (8 total)..."
  MCP_LIST=$(claude mcp list 2>/dev/null)

  echo "$MCP_LIST" | grep -q "ruflo" && echo "  ✅ ruflo MCP" \
    || { echo "  📥 Adding ruflo MCP..."; claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "context7" && echo "  ✅ context7 MCP" \
    || { echo "  📥 Adding context7 MCP..."; claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "vanta" && echo "  ✅ vanta MCP" \
    || { echo "  📥 Adding vanta MCP..."; claude mcp add vanta -s user -- bash "$PROJECTS/scripts/vanta-mcp-wrapper.sh" 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "obsidian" && echo "  ✅ obsidian MCP" \
    || { echo "  📥 Adding obsidian MCP..."; claude mcp add obsidian -s user -- npx -y @bitbonsai/mcpvault@latest "$PROJECTS/company-brain" 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "claude-flow" && echo "  ✅ claude-flow MCP" \
    || { echo "  📥 Adding claude-flow MCP..."; claude mcp add claude-flow -s user -- npx -y @claude-flow/cli@latest mcp start 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "kapture" && echo "  ✅ kapture MCP" \
    || { echo "  📥 Adding kapture MCP..."; claude mcp add kapture -s user -- npx -y kapture-mcp@latest bridge 2>/dev/null || true; }

  # Stitch — Google AI design canvas → code pipeline
  echo "$MCP_LIST" | grep -q "stitch" && echo "  ✅ stitch MCP" \
    || { echo "  📥 Adding stitch MCP..."; claude mcp add stitch -s user -- npx -y stitch-mcp 2>/dev/null || true; }

  # Aceternity UI — 200+ animated React/Tailwind components
  echo "$MCP_LIST" | grep -q "aceternity" && echo "  ✅ aceternity MCP" \
    || { echo "  📥 Adding aceternity MCP..."; claude mcp add aceternity -s user -- npx -y aceternityui-mcp 2>/dev/null || true; }
fi

# ─── 9b. Verify PostToolUse analyzer hook ─────────────────
echo ""
echo "Verifying Claude Code hooks..."
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "claude-hook-analyze" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  ✅ Code analyzer hook active in settings.json"
  else
    echo "  ⚠️  Code analyzer hook NOT in settings.json"
    echo "  The closed-loop scanner won't fire on edits."
    echo "  Add to PostToolUse hooks in ~/.claude/settings.json:"
    echo '    {"type": "command", "command": "bash $HOME/Documents/scripts/claude-hook-analyze.sh"}'
  fi
else
  echo "  ⚠️  ~/.claude/settings.json not found"
fi

# ─── 10. Skills & plugins ────────────────────────────────
echo ""
echo "Setting up skills & plugins..."

SKILLS_DIR="$HOME/.claude/skills"
PLUGINS_DIR="$HOME/.claude/plugins/marketplaces"
mkdir -p "$SKILLS_DIR" "$PLUGINS_DIR"

if [ -d "$SKILLS_DIR/.git" ]; then
  echo "  ✅ skills (pulling latest)"
  git -C "$SKILLS_DIR" pull --ff-only 2>/dev/null || echo "    ⚠️  Pull skipped"
elif [ -d "$SKILLS_DIR/gstack" ]; then
  echo "  ✅ gstack (already present)"
else
  echo "  📥 Installing skills (gstack + all org skills)..."
  TEMP_SKILLS=$(mktemp -d)
  git clone https://github.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem.git "$TEMP_SKILLS" 2>/dev/null
  if [ $? -eq 0 ]; then
    rm -rf "$SKILLS_DIR/.git" 2>/dev/null
    cp -r "$TEMP_SKILLS/." "$SKILLS_DIR/"
    echo "  ✅ skills installed"
  else
    echo "  ⚠️  Skills clone failed — need GitHub access"
  fi
  rm -rf "$TEMP_SKILLS"
fi

if [ -d "$PLUGINS_DIR/thedotmack" ]; then
  echo "  ✅ claude-mem (pulling latest)"
  git -C "$PLUGINS_DIR/thedotmack" pull --ff-only 2>/dev/null || true
else
  echo "  📥 Installing claude-mem..."
  git clone https://github.com/thedotmack/claude-mem.git "$PLUGINS_DIR/thedotmack" 2>/dev/null \
    && echo "  ✅ claude-mem installed" \
    || echo "  ⚠️  claude-mem clone failed"
fi

if [ -d "$PLUGINS_DIR/claude-plugins-official" ]; then
  echo "  ✅ ralph-loop (pulling latest)"
  git -C "$PLUGINS_DIR/claude-plugins-official" pull --ff-only 2>/dev/null || true
else
  echo "  📥 Installing ralph-loop..."
  git clone https://github.com/claude-plugins-official/ralph-loop.git "$PLUGINS_DIR/claude-plugins-official" 2>/dev/null \
    && echo "  ✅ ralph-loop installed" \
    || echo "  ⚠️  ralph-loop clone failed"
fi

# ─── 11. Clean stale worktrees ────────────────────────────
for d in "$PROJECTS"/Claude "$PROJECTS"/super-rcm "$PROJECTS"/5dsmiles-landing "$PROJECTS"/WakewellWeb "$PROJECTS"/ClaimMDGHL-Sync-Machine "$PROJECTS"/wakewell-b2b-dashboard "$PROJECTS"/claude-skills-ecosystem; do
  [ -d "$d/.git" ] && git -C "$d" worktree prune 2>/dev/null
done

# ─── Done ─────────────────────────────────────────────────
echo ""
echo "========================================="
echo "  ✅ Setup Complete! ($OS)"
echo "========================================="
echo ""
echo "Your projects:"
echo "  aria (org hub)      → cd ~/Documents/Claude && claude"
echo "  rcm (data server)   → cd ~/Documents/super-rcm && claude"
echo "  dashboard (5D)      → cd ~/Documents/5dsmiles-landing && claude"
echo "  wakewellweb (Azure) → cd ~/Documents/WakewellWeb && claude"
echo "  claims bridge       → cd ~/Documents/ClaimMDGHL-Sync-Machine && claude"
echo "  b2b dashboard       → cd ~/Documents/wakewell-b2b-dashboard && claude"
echo "  sleep scheduler     → cd ~/Documents/sleep_test_scheduler && claude"
echo "  pegasus             → cd ~/Documents/Pegasus && claude"
echo "  skills              → cd ~/Documents/claude-skills-ecosystem && claude"
echo ""
echo "Code analysis:"
echo "  Full scan:  irun bash ~/Documents/scripts/code-analyzer.sh --all <project>"
echo "  Security:   bash ~/Documents/scripts/code-analyzer.sh --tier 2 <project>"
echo "  Deep (SC):  irun bash ~/Documents/scripts/code-analyzer.sh --tier 3 <project>"
echo ""
echo "MCP servers (6): ruflo, context7, vanta, obsidian, claude-flow, kapture"
echo ""
echo "Start:     cd ~/Documents/Claude && claude"
echo ""
