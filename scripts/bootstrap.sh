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
    echo "Paste your one-time Infisical token (get this from your admin — expires after one use):"
    echo "Type 'skip' to set up later."
    read -p "Token: " INFISICAL_TOKEN
    if [ -n "$INFISICAL_TOKEN" ] && [ "$INFISICAL_TOKEN" != "skip" ]; then
      infisical login --method=universal-auth --client-id="$INFISICAL_TOKEN" 2>/dev/null \
        || INFISICAL_TOKEN="$INFISICAL_TOKEN" infisical login 2>/dev/null \
        || echo "  ⚠️  Token didn't work — ask your admin for a new one"
    else
      echo "  ⏭️  Skipped — run 'infisical login' when you have your token"
    fi
  fi

  # Verify secrets (count only — NEVER show values)
  SECRET_COUNT=$(infisical secrets --env=prod --path=/shared --silent 2>/dev/null | grep -c "│" || echo "0")
  if [ "$SECRET_COUNT" -gt 1 ]; then
    echo "  ✅ Infisical: $SECRET_COUNT secrets accessible in /shared"
  else
    echo "  ⚠️  Infisical: can't read /shared secrets — check auth or ask admin"
  fi
fi

# ─── 7. Clone org repos ──────────────────────────────────
echo ""
echo "Setting up projects..."
mkdir -p "$PROJECTS"

gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null | while read repo; do
  TARGET="$PROJECTS/$repo"
  [ "$repo" = "aria-slack-bot" ] && TARGET="$PROJECTS/Claude"
  BASENAME=$(basename "$TARGET")

  if [ -d "$TARGET/.git" ]; then
    echo "  ✅ $BASENAME/ (pulling latest)"
    git -C "$TARGET" pull --ff-only 2>/dev/null || echo "    ⚠️  Pull skipped (local changes)"
  elif [ -d "$TARGET" ]; then
    # Folder exists but not a git repo — don't touch it
    echo "  ⏭️  $BASENAME/ (exists, not a git repo — skipping)"
  else
    gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null && echo "  ✅ $BASENAME/ (cloned)" || true
  fi
done

# ─── 8. Global config from skills repo ───────────────────
echo ""

# Find skills repo
if [ ! -d "$SKILLS_REPO" ]; then
  for d in "$HOME/.claude-skills" "$PROJECTS/claude-skills-ecosystem"; do
    [ -d "$d" ] && SKILLS_REPO="$d" && break
  done
fi

mkdir -p "$HOME/.claude/rules"

# Global CLAUDE.md
if [ -f "$SKILLS_REPO/config/global-claude.md" ]; then
  cp "$SKILLS_REPO/config/global-claude.md" "$HOME/.claude/CLAUDE.md"
  echo "✅ Global CLAUDE.md installed"
else
  echo "⚠️  Global CLAUDE.md not found in skills repo"
fi

# Rules
if [ -d "$SKILLS_REPO/config/rules" ]; then
  cp "$SKILLS_REPO/config/rules/"*.md "$HOME/.claude/rules/" 2>/dev/null
  echo "✅ Global rules installed"
fi

# ─── 9. Claude plugins ────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  # claude-mem (cross-session memory)
  claude plugin list 2>/dev/null | grep -q "claude-mem" && echo "  ✅ claude-mem" \
    || { echo "  📥 Installing claude-mem..."; claude install-plugin thedotmack/claude-mem 2>/dev/null || true; }

  # ralph-loop (autonomous iteration)
  claude plugin list 2>/dev/null | grep -q "ralph-loop" && echo "  ✅ ralph-loop" \
    || { echo "  📥 Installing ralph-loop..."; claude install-plugin claude-plugins-official/ralph-loop 2>/dev/null || true; }
fi

# ─── 10. Clean stale worktrees ────────────────────────────
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
