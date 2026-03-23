#!/bin/bash
# 5D Smiles / WakeWell — New Machine Bootstrap
# Lives in the public claude-skills-ecosystem repo
#
# Fresh machine (no files):
#   bash <(curl -s https://raw.githubusercontent.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem/main/scripts/bootstrap.sh)
#
# Already have the skills repo:
#   bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh

echo "========================================="
echo "  5D Smiles AI Command Center — Setup"
echo "========================================="
echo ""

# --- 1. Homebrew ---
# Check every possible location before trying to install
BREW_BIN=""
if command -v brew >/dev/null 2>&1; then
  BREW_BIN="brew"
elif [ -x /opt/homebrew/bin/brew ]; then
  BREW_BIN="/opt/homebrew/bin/brew"
  eval "$($BREW_BIN shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  BREW_BIN="/usr/local/bin/brew"
  eval "$($BREW_BIN shellenv)"
elif [ -x "$HOME/.homebrew/bin/brew" ]; then
  BREW_BIN="$HOME/.homebrew/bin/brew"
  eval "$($BREW_BIN shellenv)"
fi

if [ -z "$BREW_BIN" ]; then
  echo "📥 Installing Homebrew (you may need to enter your password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "✅ Homebrew: already installed"
fi

# --- 2. Core tools ---
command -v git >/dev/null 2>&1 || brew install git
command -v node >/dev/null 2>&1 || brew install node
command -v gh >/dev/null 2>&1 || brew install gh
command -v tmux >/dev/null 2>&1 || brew install tmux
echo "✅ git, node, gh, tmux installed"

# --- 3. Claude Code ---
if ! command -v claude >/dev/null 2>&1; then
  echo "📥 Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi
echo "✅ Claude Code: $(claude --version 2>/dev/null || echo 'installed')"

# --- 4. GitHub auth ---
if ! gh auth status >/dev/null 2>&1; then
  echo ""
  echo "Log in to GitHub (this gives access to the private repos):"
  gh auth login
fi
echo "✅ GitHub: logged in as $(gh api user -q .login 2>/dev/null || echo 'authenticated')"

# --- 5. Infisical (optional) ---
if ! command -v infisical >/dev/null 2>&1; then
  brew install infisical/get-cli/infisical 2>/dev/null || true
fi
if command -v infisical >/dev/null 2>&1; then
  echo "✅ Infisical installed (run 'infisical login' to authenticate)"
else
  echo "⏭️  Infisical skipped — install later: brew install infisical/get-cli/infisical"
fi

# --- 6. Clone all org repos ---
echo ""
echo "Setting up projects..."
PROJECTS="$HOME/Documents"
mkdir -p "$PROJECTS"
cd "$PROJECTS"

# NEVER move or delete existing folders. Clone to temp, merge in what's missing.
TEMP_DIR=$(mktemp -d)
echo "  Using temp: $TEMP_DIR"

gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null | while read repo; do
  TARGET="$PROJECTS/$repo"
  [ "$repo" = "aria-slack-bot" ] && TARGET="$PROJECTS/Claude"
  BASENAME=$(basename "$TARGET")

  if [ -d "$TARGET/.git" ]; then
    # Already a git repo — just pull latest
    echo "  ⏭️  $BASENAME/ (git repo — pulling latest)"
    git -C "$TARGET" pull --ff-only 2>/dev/null || echo "  ⚠️  Pull failed (local changes — that's fine)"
  elif [ -d "$TARGET" ]; then
    # Folder exists but not a git repo — clone to temp, merge missing files
    echo "  🔀 $BASENAME/ (exists, not git — merging new files in)"
    gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TEMP_DIR/$repo" 2>/dev/null || continue
    # Copy only files that DON'T already exist locally
    cd "$TEMP_DIR/$repo"
    find . -type f | while read f; do
      if [ ! -f "$TARGET/$f" ]; then
        mkdir -p "$TARGET/$(dirname $f)"
        cp "$f" "$TARGET/$f"
        echo "    + $f"
      fi
    done
    # Always update CLAUDE.md and scripts (these should stay current)
    [ -f "$TEMP_DIR/$repo/CLAUDE.md" ] && cp "$TEMP_DIR/$repo/CLAUDE.md" "$TARGET/CLAUDE.md"
    [ -d "$TEMP_DIR/$repo/scripts" ] && cp -r "$TEMP_DIR/$repo/scripts/" "$TARGET/scripts/" 2>/dev/null
    [ -d "$TEMP_DIR/$repo/.claude" ] && cp -rn "$TEMP_DIR/$repo/.claude/" "$TARGET/.claude/" 2>/dev/null
  else
    # Doesn't exist at all — fresh clone
    gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null
    echo "  ✅ $BASENAME/ (cloned)"
  fi
done

# Clean up temp
rm -rf "$TEMP_DIR"

# --- 7. Global Claude config ---
echo ""
mkdir -p "$HOME/.claude/rules" "$HOME/.claude/templates"

if [ ! -f "$HOME/.claude/CLAUDE.md" ] && [ -f "$PROJECTS/Claude/scripts/global-claude-template.md" ]; then
  cp "$PROJECTS/Claude/scripts/global-claude-template.md" "$HOME/.claude/CLAUDE.md"
  echo "✅ Global CLAUDE.md installed"
else
  echo "⏭️  Global CLAUDE.md already exists"
fi

cat > "$HOME/.claude/rules/verification.md" << 'EOF'
# Verification (applies to all projects)
- After completing any task, verify the result works before reporting done
- For code: run tests. For sites: take a screenshot. For data: spot-check output.
- Never say "done" without evidence it works.
EOF
echo "✅ Rules installed"

# --- 8. Clean stale worktrees ---
for d in "$PROJECTS"/Claude "$PROJECTS"/super-rcm "$PROJECTS"/5dsmiles-landing "$PROJECTS"/WakewellWeb "$PROJECTS"/claude-skills-ecosystem; do
  [ -d "$d/.git" ] && git -C "$d" worktree prune 2>/dev/null
done
echo "✅ Worktrees cleaned"

# --- Done ---
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
echo "Parallel:  bash ~/Documents/Claude/scripts/parallel.sh 5"
echo "Manual:    ~/Documents/Claude/docs/SETUP-GUIDE.md"
echo ""
echo "Start here:  cd ~/Documents/Claude && claude"
echo ""
