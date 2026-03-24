#!/bin/bash
# WakeWell / 5D Smiles — New Machine Bootstrap
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

# ─── 1. Homebrew ───────────────────────────────────────────
# Check every known install location before attempting install
if command -v brew >/dev/null 2>&1; then
  : # already in PATH
elif [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [ -x "$HOME/.homebrew/bin/brew" ]; then
  eval "$("$HOME/.homebrew/bin/brew" shellenv)"
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "📥 Installing Homebrew (you may need to enter your password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Load into current session + persist
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    grep -q 'brew shellenv' ~/.zprofile 2>/dev/null || echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "✅ Homebrew: already installed"
fi

# ─── 2. Core tools ────────────────────────────────────────
for tool in git node gh tmux; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "  ✅ $tool"
  else
    echo "  📥 Installing $tool..."
    brew install "$tool"
  fi
done

# ─── 3. Claude Code ───────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  echo "  ✅ claude ($(claude --version 2>/dev/null || echo 'installed'))"
else
  echo "  📥 Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# ─── 4. Ruflo ─────────────────────────────────────────────
if command -v ruflo >/dev/null 2>&1; then
  echo "  ✅ ruflo"
else
  echo "  📥 Installing Ruflo..."
  npm install -g ruflo 2>/dev/null || echo "  ⚠️  Ruflo install failed — install manually: npm install -g ruflo"
fi

echo ""
echo "✅ All tools installed"

# ─── 5. GitHub auth ───────────────────────────────────────
echo ""
if gh auth status >/dev/null 2>&1; then
  echo "✅ GitHub: logged in as $(gh api user -q .login 2>/dev/null)"
else
  echo "Log in to GitHub (this gives access to the private repos):"
  gh auth login
fi

# ─── 6. Infisical ─────────────────────────────────────────
if ! command -v infisical >/dev/null 2>&1; then
  echo "  📥 Installing Infisical..."
  brew install infisical/get-cli/infisical 2>/dev/null || echo "  ⚠️  Infisical install failed"
else
  echo "  ✅ infisical"
fi

if command -v infisical >/dev/null 2>&1; then
  # Check if already authenticated (try multiple commands since versions differ)
  INFISICAL_AUTHED=false
  infisical user get >/dev/null 2>&1 && INFISICAL_AUTHED=true
  [ "$INFISICAL_AUTHED" = "false" ] && infisical whoami >/dev/null 2>&1 && INFISICAL_AUTHED=true

  if [ "$INFISICAL_AUTHED" = "true" ]; then
    echo "  ✅ Infisical: already authenticated"
  else
    echo ""
    echo "Log in to Infisical (this opens a browser window):"
    echo "Type 'skip' to set up later."
    read -p "Press Enter to log in (or type 'skip'): " INFISICAL_CHOICE
    if [ "$INFISICAL_CHOICE" != "skip" ]; then
      infisical login
      if [ $? -ne 0 ]; then
        echo "  ⚠️  Login failed — try 'infisical login -i' for interactive mode"
      fi
    else
      echo "  ⏭️  Skipped — run 'infisical login' when ready"
    fi
  fi

  # Verify secrets (count only — NEVER show values)
  # Team members only get /shared — /server and /henry-only are admin-only
  SECRET_COUNT=$(infisical secrets --env=prod --path=/shared --silent 2>/dev/null | grep -c "│" || echo "0")
  if [ "$SECRET_COUNT" -gt 0 ]; then
    echo "  ✅ Infisical: $SECRET_COUNT secrets accessible in /shared"
  else
    echo "  ⚠️  Infisical: can't read /shared secrets — check auth or ask admin"
  fi
fi

# ─── 7. Clone/sync org repos ─────────────────────────────
# Strategy: find repos by git remote URL, not folder name.
# Scans ~/Documents/ recursively (2 levels deep) to find existing clones.
# If found anywhere, pull there. Only clone to default location if not found.
echo ""
echo "Setting up projects..."
mkdir -p "$PROJECTS"

# Build a map file of org repos already cloned locally (avoids subshell variable issues)
REPO_MAP=$(mktemp)
find "$PROJECTS" -maxdepth 2 -name ".git" -type d 2>/dev/null | while read gitdir; do
  REPO_DIR=$(dirname "$gitdir")
  REMOTE=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)
  if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
    REPO_NAME=$(echo "$REMOTE" | sed 's|.*/||' | sed 's|\.git$||')
    echo "$REPO_NAME|$REPO_DIR" >> "$REPO_MAP"
  fi
done

# Get list of all org repos from GitHub
REPO_LIST=$(gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null)

echo "$REPO_LIST" | while read repo; do
  [ -z "$repo" ] && continue

  # Check if already cloned somewhere (any folder name, any depth)
  EXISTING=$(grep "^${repo}|" "$REPO_MAP" 2>/dev/null | head -1 | cut -d'|' -f2)

  if [ -n "$EXISTING" ]; then
    echo "  ✅ $(basename $EXISTING)/ (pulling latest)"
    git -C "$EXISTING" pull --ff-only 2>/dev/null || echo "    ⚠️  Pull skipped (local changes or worktree)"
  else
    # Not found anywhere — clone to default location
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

# Find skills repo
if [ ! -d "$SKILLS_REPO" ]; then
  for d in "$HOME/.claude-skills" "$PROJECTS/claude-skills-ecosystem"; do
    [ -d "$d" ] && SKILLS_REPO="$d" && break
  done
fi

mkdir -p "$HOME/.claude/rules"

# Global CLAUDE.md (repo is source of truth — always overwrite)
if [ -f "$SKILLS_REPO/config/global-claude.md" ]; then
  cp "$SKILLS_REPO/config/global-claude.md" "$HOME/.claude/CLAUDE.md"
  echo "✅ Global CLAUDE.md installed"
else
  echo "⚠️  Global CLAUDE.md not found in skills repo"
fi

# Rules (add new, never delete existing local rules)
if [ -d "$SKILLS_REPO/config/rules" ]; then
  for f in "$SKILLS_REPO/config/rules/"*.md; do
    [ -f "$f" ] && cp "$f" "$HOME/.claude/rules/$(basename "$f")"
  done
  echo "✅ Global rules synced"
fi

# ─── 9. MCP servers ───────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  echo ""
  echo "Setting up MCP servers..."

  # Ruflo (core orchestration)
  claude mcp list 2>/dev/null | grep -q "ruflo" && echo "  ✅ ruflo MCP" \
    || { echo "  📥 Adding ruflo MCP..."; claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true; }

  # Context7 (free library docs)
  claude mcp list 2>/dev/null | grep -q "context7" && echo "  ✅ context7 MCP" \
    || { echo "  📥 Adding context7 MCP..."; claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true; }

  # GitHub
  claude mcp list 2>/dev/null | grep -q "github" && echo "  ✅ github MCP" \
    || { echo "  📥 Adding github MCP..."; claude mcp add github -s user -- npx -y @modelcontextprotocol/server-github 2>/dev/null || true; }
fi

# ─── 10. Skills & plugins (git clone — not interactive commands) ──
echo ""
echo "Setting up skills & plugins..."

SKILLS_DIR="$HOME/.claude/skills"
PLUGINS_DIR="$HOME/.claude/plugins/marketplaces"
mkdir -p "$SKILLS_DIR" "$PLUGINS_DIR"

# gstack + all org skills (entire skills ecosystem repo IS the skills dir)
if [ -d "$SKILLS_DIR/.git" ]; then
  echo "  ✅ skills (pulling latest)"
  git -C "$SKILLS_DIR" pull --ff-only 2>/dev/null || echo "    ⚠️  Pull skipped"
elif [ -d "$SKILLS_DIR/gstack" ]; then
  echo "  ✅ gstack (already present)"
else
  echo "  📥 Installing skills (gstack + all org skills)..."
  # Clone into temp, move contents to skills dir (preserving existing files)
  TEMP_SKILLS=$(mktemp -d)
  git clone https://github.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem.git "$TEMP_SKILLS" 2>/dev/null
  if [ $? -eq 0 ]; then
    # Move git repo into skills dir
    rm -rf "$SKILLS_DIR/.git" 2>/dev/null
    cp -r "$TEMP_SKILLS/." "$SKILLS_DIR/"
    echo "  ✅ skills installed"
  else
    echo "  ⚠️  Skills clone failed — need GitHub access"
  fi
  rm -rf "$TEMP_SKILLS"
fi

# claude-mem (cross-session memory)
if [ -d "$PLUGINS_DIR/thedotmack" ]; then
  echo "  ✅ claude-mem (pulling latest)"
  git -C "$PLUGINS_DIR/thedotmack" pull --ff-only 2>/dev/null || true
else
  echo "  📥 Installing claude-mem..."
  git clone https://github.com/thedotmack/claude-mem.git "$PLUGINS_DIR/thedotmack" 2>/dev/null \
    && echo "  ✅ claude-mem installed" \
    || echo "  ⚠️  claude-mem clone failed"
fi

# ralph-loop (autonomous iteration)
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
for d in "$PROJECTS"/Claude "$PROJECTS"/super-rcm "$PROJECTS"/5dsmiles-landing "$PROJECTS"/WakewellWeb "$PROJECTS"/claude-skills-ecosystem; do
  [ -d "$d/.git" ] && git -C "$d" worktree prune 2>/dev/null
done

# ─── Done ─────────────────────────────────────────────────
echo ""
echo "========================================="
echo "  ✅ Setup Complete!"
echo "========================================="
echo ""
echo "Your projects:"
echo "  aria (org hub)     → cd ~/Documents/Claude && claude"
echo "  rcm (data server)  → cd ~/Documents/super-rcm && claude"
echo "  dashboard          → cd ~/Documents/5dsmiles-landing && claude"
echo "  wakewellweb        → cd ~/Documents/WakewellWeb && claude"
echo "  skills             → cd ~/Documents/claude-skills-ecosystem && claude"
echo ""
echo "Parallel:  bash ~/Documents/claude-skills-ecosystem/scripts/parallel.sh 5"
echo "Manual:    ~/Documents/Claude/docs/SETUP-GUIDE.md"
echo ""
echo "Start:     cd ~/Documents/Claude && claude"
echo ""
