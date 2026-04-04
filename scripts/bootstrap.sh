#!/bin/bash
# WakeWell / 5D Smiles — New Machine Bootstrap (macOS + Windows + Linux)
# Source of truth: claude-skills-ecosystem repo
#
# Fresh machine:   bash <(curl -s https://raw.githubusercontent.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem/main/scripts/bootstrap.sh)
# Existing clone:  bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh

# Use -eE with trap instead of bare set -e — allows cleanup on failure
set -eE
trap 'echo ""; echo "⚠️  Bootstrap failed at line $LINENO. Check output above."; cleanup' ERR

echo "========================================="
echo "  WakeWell AI Command Center — Setup"
echo "========================================="
echo ""

PROJECTS="$HOME/Documents"
SKILLS_REPO="$PROJECTS/claude-skills-ecosystem"
LOG_FILE="$PROJECTS/bootstrap-$(date +%Y%m%d-%H%M%S).log"

# Tee output to log file for debugging
exec > >(tee -a "$LOG_FILE") 2>&1
echo "Log: $LOG_FILE"

# Temp file tracking for cleanup
TEMP_FILES=()
cleanup() {
  for f in "${TEMP_FILES[@]}"; do
    rm -f "$f" 2>/dev/null
  done
}
trap cleanup EXIT

# ─── 0. Detect OS and source package managers ────────────
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"

OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]] || uname -r 2>/dev/null | grep -qi microsoft; then
  OS="windows"
  # Add Python Scripts to PATH (semgrep installs here via pip)
  for pydir in "$LOCALAPPDATA"/Programs/Python/Python*/Scripts "$HOME"/AppData/Local/Programs/Python/Python*/Scripts; do
    [ -d "$pydir" ] && export PATH="$pydir:$PATH"
  done
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
    echo "Installing Homebrew (you may need to enter your password)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
      grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    fi
  else
    echo "Homebrew: installed"
  fi
elif [ "$OS" = "windows" ]; then
  if command -v winget >/dev/null 2>&1; then
    echo "winget: available"
  else
    echo "No winget found. Using npm/pip for installs."
  fi
elif [ "$OS" = "linux" ]; then
  echo "Linux detected. Using npm/pip for installs (apt/dnf for system packages if needed)."
fi

# Helper: install a tool cross-platform
install_tool() {
  local tool="$1"
  local brew_pkg="${2:-$tool}"
  local winget_id="${3:-}"
  local npm_pkg="${4:-}"
  local pip_pkg="${5:-}"

  if command -v "$tool" >/dev/null 2>&1; then
    echo "  [OK] $tool"
    return 0
  fi

  echo "  [INSTALL] $tool..."
  if [ "$OS" = "macos" ]; then
    brew install "$brew_pkg" 2>/dev/null || echo "  [WARN] brew install $brew_pkg failed"
  elif [ "$OS" = "windows" ]; then
    # Try winget, then npm, then pip — cascading fallback
    local installed=false
    if [ -n "$winget_id" ] && command -v winget >/dev/null 2>&1; then
      winget install --accept-package-agreements --accept-source-agreements -e --id "$winget_id" 2>/dev/null && installed=true || true
      # Refresh PATH after winget (Windows doesn't update current shell)
      if [ "$installed" = "true" ]; then
        hash -r 2>/dev/null  # bash cache clear
      fi
    fi
    if ! command -v "$tool" >/dev/null 2>&1 && [ -n "$npm_pkg" ] && command -v npm >/dev/null 2>&1; then
      npm install -g "$npm_pkg" 2>/dev/null && installed=true || true
    fi
    if ! command -v "$tool" >/dev/null 2>&1 && [ -n "$pip_pkg" ]; then
      (command -v pip >/dev/null 2>&1 && pip install "$pip_pkg" 2>/dev/null) \
        || (command -v pip3 >/dev/null 2>&1 && pip3 install "$pip_pkg" 2>/dev/null) \
        || true
    fi
    command -v "$tool" >/dev/null 2>&1 || echo "  [WARN] $tool install failed -- install manually"
  elif [ "$OS" = "linux" ]; then
    # Try npm first, then pip
    if [ -n "$npm_pkg" ] && command -v npm >/dev/null 2>&1; then
      npm install -g "$npm_pkg" 2>/dev/null || true
    fi
    if ! command -v "$tool" >/dev/null 2>&1 && [ -n "$pip_pkg" ]; then
      (command -v pip3 >/dev/null 2>&1 && pip3 install "$pip_pkg" 2>/dev/null) || true
    fi
    command -v "$tool" >/dev/null 2>&1 || echo "  [WARN] $tool: install manually (apt install $brew_pkg or equivalent)"
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
  echo "  [OK] claude ($(claude --version 2>/dev/null || echo 'installed'))"
else
  echo "  [INSTALL] Claude Code..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || echo "  [WARN] Claude Code install failed"
fi

# ─── 4. Ruflo ─────────────────────────────────────────────
if command -v ruflo >/dev/null 2>&1; then
  echo "  [OK] ruflo"
else
  echo "  [INSTALL] Ruflo..."
  npm install -g ruflo 2>/dev/null || echo "  [WARN] Ruflo install failed"
fi

# ─── 4b. Code Analysis & Security Tools ───────────────────
echo ""
echo "Code analysis & security tools:"

#                tool            brew_pkg        winget_id       npm_pkg                 pip_pkg
install_tool     semgrep         semgrep         ""              ""                      "semgrep"
install_tool     snyk            ""              ""              "snyk"                  ""
install_tool     eslint          ""              ""              "eslint"                ""
install_tool     tsc             ""              ""              "typescript"            ""
install_tool     sonar-scanner   sonar-scanner   ""              ""                      ""

# sonar-scanner on Windows/Linux — no npm/pip package
if [ "$OS" != "macos" ] && ! command -v sonar-scanner >/dev/null 2>&1; then
  echo "  [WARN] sonar-scanner: download from https://docs.sonarsource.com/sonarcloud/advanced-setup/ci-based-analysis/sonarscanner-cli/"
fi

# Ensure ESLint plugins are installed
if command -v npm >/dev/null 2>&1; then
  npm list -g @typescript-eslint/parser >/dev/null 2>&1 \
    || npm install -g @typescript-eslint/parser @typescript-eslint/eslint-plugin 2>/dev/null || true
fi

# ─── 4c. Snyk Authentication ─────────────────────────────
if command -v snyk >/dev/null 2>&1; then
  if snyk whoami >/dev/null 2>&1; then
    echo "  [OK] Snyk: authenticated"
  else
    echo "  [WARN] Snyk needs auth. Run after bootstrap: snyk auth"
  fi
fi

# ─── 4d. Code Analyzer Scripts ────────────────────────────
echo ""
echo "Closed-loop analyzer scripts:"
SCRIPTS_DIR="$PROJECTS/scripts"
mkdir -p "$SCRIPTS_DIR"

for script in code-analyzer.sh claude-hook-analyze.sh vanta-mcp-wrapper.sh; do
  if [ -x "$SCRIPTS_DIR/$script" ]; then
    echo "  [OK] $script"
  else
    FOUND=$(find "$PROJECTS" -maxdepth 3 -name "$script" -type f 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
      cp "$FOUND" "$SCRIPTS_DIR/$script"
      chmod +x "$SCRIPTS_DIR/$script"
      echo "  [OK] $script (copied from $(dirname "$FOUND"))"
    else
      echo "  [WARN] $script not found"
    fi
  fi
done

# ─── 4e. Vanta Credentials ───────────────────────────────
if [ -f "$HOME/.claude/vanta-credentials.json" ]; then
  echo "  [OK] Vanta credentials file exists"
else
  echo "  [WARN] Vanta credentials missing. Create ~/.claude/vanta-credentials.json with:"
  echo '     {"client_id": "...", "client_secret": "..."}'
fi

echo ""
echo "All tools checked."

# ─── 5. GitHub auth ───────────────────────────────────────
echo ""
if command -v gh >/dev/null 2>&1; then
  if gh auth status >/dev/null 2>&1; then
    echo "[OK] GitHub: logged in as $(gh api user -q .login 2>/dev/null || echo 'authenticated')"
  else
    echo "[WARN] GitHub not authenticated. Run: gh auth login"
  fi
else
  echo "[WARN] gh not installed — repo sync will be skipped"
fi

# ─── 6. Infisical ─────────────────────────────────────────
if ! command -v infisical >/dev/null 2>&1; then
  echo "  [INSTALL] Infisical..."
  if [ "$OS" = "macos" ]; then
    brew install infisical/get-cli/infisical 2>/dev/null || echo "  [WARN] Infisical install failed"
  else
    npm install -g @infisical/cli 2>/dev/null || echo "  [WARN] Infisical install failed"
  fi
else
  echo "  [OK] infisical"
fi

if command -v infisical >/dev/null 2>&1; then
  INFISICAL_AUTHED=false
  infisical user get >/dev/null 2>&1 && INFISICAL_AUTHED=true
  [ "$INFISICAL_AUTHED" = "false" ] && infisical whoami >/dev/null 2>&1 && INFISICAL_AUTHED=true

  if [ "$INFISICAL_AUTHED" = "true" ]; then
    echo "  [OK] Infisical: authenticated"
  else
    echo "  [WARN] Infisical not authenticated. Run: infisical login"
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

# Guard: skip if gh isn't authed
if ! command -v gh >/dev/null 2>&1 || ! gh auth status >/dev/null 2>&1; then
  echo "  [SKIP] GitHub not available/authed — skipping repo sync"
else
  REPO_MAP=$(mktemp)
  trap 'rm -f "$REPO_MAP"' EXIT
  TEMP_FILES+=("$REPO_MAP")

  find "$PROJECTS" -maxdepth 2 -name ".git" -type d 2>/dev/null | while read -r gitdir; do
    REPO_DIR=$(dirname "$gitdir")
    REMOTE=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)
    if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
      REPO_NAME=$(echo "$REMOTE" | sed 's|.*/||' | sed 's|\.git$||')
      echo "$REPO_NAME|$REPO_DIR" >> "$REPO_MAP"
    fi
  done

  SKIP_REPOS="WakewellRailway ODGHLSync opendentalsynctool SmartCoach salescoach"

  REPO_LIST=$(gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null || echo "")

  if [ -n "$REPO_LIST" ]; then
    while IFS= read -r repo; do
      [ -z "$repo" ] && continue
      if echo "$SKIP_REPOS" | grep -qFw "$repo"; then
        continue
      fi

      EXISTING=$(grep "^${repo}|" "$REPO_MAP" 2>/dev/null | head -1 | cut -d'|' -f2)

      if [ -n "$EXISTING" ]; then
        echo "  [OK] $(basename "$EXISTING")/ (pulling)"
        git -C "$EXISTING" pull --ff-only 2>/dev/null || echo "    [WARN] Pull failed"
      else
        TARGET="$PROJECTS/$repo"
        [ "$repo" = "aria-slack-bot" ] && TARGET="$PROJECTS/Claude"
        if [ -d "$TARGET" ]; then
          echo "  [SKIP] $(basename "$TARGET")/ (exists)"
        else
          if gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null; then
            echo "  [OK] $(basename "$TARGET")/ (cloned)"
          else
            echo "  [WARN] Failed to clone $repo"
          fi
        fi
      fi
    done <<< "$REPO_LIST"
  fi
fi

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
  echo "[OK] Global CLAUDE.md exists (not overwriting)"
elif [ -f "$SKILLS_REPO/config/global-claude.md" ]; then
  cp "$SKILLS_REPO/config/global-claude.md" "$HOME/.claude/CLAUDE.md"
  echo "[OK] Global CLAUDE.md installed from repo"
else
  echo "[WARN] Global CLAUDE.md not found"
fi

if [ -d "$SKILLS_REPO/config/rules" ]; then
  for f in "$SKILLS_REPO/config/rules/"*.md; do
    [ -f "$f" ] && cp "$f" "$HOME/.claude/rules/$(basename "$f")"
  done
  echo "[OK] Global rules synced"
fi

# ─── 9. MCP servers ───────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  echo ""
  echo "Setting up MCP servers (7 total)..."
  MCP_LIST=$(claude mcp list 2>/dev/null || echo "")

  echo "$MCP_LIST" | grep -q "ruflo" && echo "  [OK] ruflo MCP" \
    || { echo "  [ADD] ruflo MCP..."; claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "context7" && echo "  [OK] context7 MCP" \
    || { echo "  [ADD] context7 MCP..."; claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true; }

  # Vanta MCP
  echo "$MCP_LIST" | grep -q "vanta" && echo "  [OK] vanta MCP" \
    || {
      VANTA_WRAPPER="$PROJECTS/claude-skills-ecosystem/scripts/vanta-mcp-wrapper.sh"
      if [ -f "$VANTA_WRAPPER" ]; then
        echo "  [ADD] vanta MCP..."
        claude mcp add vanta -s user -- bash "$VANTA_WRAPPER" 2>/dev/null || true
      else
        echo "  [WARN] vanta-mcp-wrapper.sh not found at $VANTA_WRAPPER"
      fi
    }

  echo "$MCP_LIST" | grep -q "obsidian" && echo "  [OK] obsidian MCP" \
    || { echo "  [ADD] obsidian MCP..."; claude mcp add obsidian -s user -- npx -y @bitbonsai/mcpvault@latest "$PROJECTS/company-brain" 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "kapture" && echo "  [OK] kapture MCP" \
    || { echo "  [ADD] kapture MCP..."; claude mcp add kapture -s user -- npx -y kapture-mcp@latest bridge 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "stitch" && echo "  [OK] stitch MCP" \
    || { echo "  [ADD] stitch MCP..."; claude mcp add stitch -s user -- npx -y stitch-mcp 2>/dev/null || true; }

  echo "$MCP_LIST" | grep -q "aceternity" && echo "  [OK] aceternity MCP" \
    || { echo "  [ADD] aceternity MCP..."; claude mcp add aceternity -s user -- npx -y aceternityui-mcp 2>/dev/null || true; }
fi

# ─── 9b. Register PostToolUse analyzer hook ───────────────
echo ""
echo "Checking Claude Code hooks..."
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ -f "$SETTINGS_FILE" ]; then
  if grep -q "claude-hook-analyze\|codex-audit" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  [OK] Code analyzer hook active"
  else
    HOOK_PATH=$(find "$PROJECTS" -maxdepth 3 -name "claude-hook-analyze.sh" -type f 2>/dev/null | head -1)
    if [ -n "$HOOK_PATH" ] && command -v python3 >/dev/null 2>&1; then
      echo "  [ADD] Registering code analyzer hook..."
      python3 << PYEOF
import json
try:
    with open('$SETTINGS_FILE', 'r') as f:
        cfg = json.load(f)
    hooks = cfg.setdefault('hooks', {})
    post = hooks.setdefault('PostToolUse', [])
    matcher = next((e for e in post if e.get('matcher') == 'Write|Edit'), None)
    if not matcher:
        matcher = {'matcher': 'Write|Edit', 'hooks': []}
        post.append(matcher)
    hook_list = matcher.setdefault('hooks', [])
    if not any('claude-hook-analyze' in h.get('command', '') for h in hook_list):
        hook_list.append({'type': 'command', 'command': 'bash $HOOK_PATH'})
    with open('$SETTINGS_FILE', 'w') as f:
        json.dump(cfg, f, indent=2)
    print('  [OK] Hook registered')
except Exception as e:
    print(f'  [WARN] Hook registration failed: {e}')
PYEOF
    elif [ -n "$HOOK_PATH" ]; then
      echo "  [WARN] python3 not found. Add hook manually to settings.json:"
      echo "    bash $HOOK_PATH"
    else
      echo "  [WARN] claude-hook-analyze.sh not found"
    fi
  fi
else
  echo "  [WARN] ~/.claude/settings.json not found"
fi

# ─── 10. Skills & plugins ────────────────────────────────
echo ""
echo "Setting up skills & plugins..."

SKILLS_DIR="$HOME/.claude/skills"
PLUGINS_DIR="$HOME/.claude/plugins/marketplaces"
mkdir -p "$SKILLS_DIR" "$PLUGINS_DIR"

if [ -d "$SKILLS_DIR/.git" ]; then
  echo "  [OK] skills (pulling latest)"
  git -C "$SKILLS_DIR" pull --ff-only 2>/dev/null || echo "    [WARN] Pull skipped"
elif [ -d "$SKILLS_DIR/gstack" ]; then
  echo "  [OK] gstack (already present)"
else
  echo "  [INSTALL] skills..."
  TEMP_SKILLS=$(mktemp -d)
  TEMP_FILES+=("$TEMP_SKILLS")
  gh repo clone Wakewell-Sleep-Solutions/claude-skills-ecosystem "$TEMP_SKILLS" 2>/dev/null
  if [ -d "$TEMP_SKILLS/.git" ]; then
    # Copy contents but NOT .git dir (don't make skills dir a separate repo)
    rsync -a --exclude='.git' "$TEMP_SKILLS/" "$SKILLS_DIR/" 2>/dev/null \
      || cp -r "$TEMP_SKILLS"/* "$SKILLS_DIR/" 2>/dev/null
    echo "  [OK] skills installed"
  else
    echo "  [WARN] Skills clone failed -- need GitHub access"
  fi
  rm -rf "$TEMP_SKILLS"
fi

if [ -d "$PLUGINS_DIR/thedotmack" ]; then
  echo "  [OK] claude-mem (pulling)"
  git -C "$PLUGINS_DIR/thedotmack" pull --ff-only 2>/dev/null || true
else
  echo "  [INSTALL] claude-mem..."
  git clone https://github.com/thedotmack/claude-mem.git "$PLUGINS_DIR/thedotmack" 2>/dev/null \
    && echo "  [OK] claude-mem installed" \
    || echo "  [WARN] claude-mem clone failed"
fi

if [ -d "$PLUGINS_DIR/claude-plugins-official" ]; then
  echo "  [OK] ralph-loop (pulling)"
  git -C "$PLUGINS_DIR/claude-plugins-official" pull --ff-only 2>/dev/null || true
else
  echo "  [INSTALL] ralph-loop..."
  git clone https://github.com/claude-plugins-official/ralph-loop.git "$PLUGINS_DIR/claude-plugins-official" 2>/dev/null \
    && echo "  [OK] ralph-loop installed" \
    || echo "  [WARN] ralph-loop clone failed"
fi

# ─── 11. Clean stale worktrees ────────────────────────────
for d in "$PROJECTS"/Claude "$PROJECTS"/super-rcm "$PROJECTS"/5dsmiles-landing "$PROJECTS"/WakewellWeb "$PROJECTS"/ClaimMDGHL-Sync-Machine "$PROJECTS"/wakewell-b2b-dashboard "$PROJECTS"/claude-skills-ecosystem; do
  [ -d "$d/.git" ] && git -C "$d" worktree prune 2>/dev/null
done

# ─── Done ─────────────────────────────────────────────────
echo ""
echo "========================================="
echo "  Setup Complete! ($OS)"
echo "========================================="
echo ""
echo "Your projects:"
echo "  aria (org hub)      -> cd ~/Documents/Claude && claude"
echo "  rcm (data server)   -> cd ~/Documents/super-rcm && claude"
echo "  dashboard (5D)      -> cd ~/Documents/5dsmiles-landing && claude"
echo "  wakewellweb (Azure) -> cd ~/Documents/WakewellWeb && claude"
echo "  claims bridge       -> cd ~/Documents/ClaimMDGHL-Sync-Machine && claude"
echo "  b2b dashboard       -> cd ~/Documents/wakewell-b2b-dashboard && claude"
echo "  sleep scheduler     -> cd ~/Documents/sleep_test_scheduler && claude"
echo "  pegasus             -> cd ~/Documents/Pegasus && claude"
echo "  skills              -> cd ~/Documents/claude-skills-ecosystem && claude"
echo ""
echo "Code analysis:"
echo "  Full scan:  irun bash ~/Documents/claude-skills-ecosystem/scripts/code-analyzer.sh --all <project>"
echo "  Security:   bash ~/Documents/claude-skills-ecosystem/scripts/code-analyzer.sh --tier 2 <project>"
echo ""
echo "MCP servers (7): ruflo, context7, vanta, obsidian, kapture, stitch, aceternity"
echo ""
echo "Log saved: $LOG_FILE"
echo "Start:     cd ~/Documents/Claude && claude"
echo ""
