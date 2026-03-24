# Claude Bootstrap — Execute This At Session Start

This is the machine-readable bootstrap. Execute these steps in order every session. Do not skip any step.

**IMPORTANT:** This bootstrap does NOT install system tools (brew, gh, node, infisical). That's the human bootstrap's job (`scripts/bootstrap.sh`). If tools are missing, tell the user to run the human bootstrap first.

## Step 0: Detect environment

```bash
# Are we in a worktree? If so, skip sync — just read context.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  WORKTREE_ROOT=$(git rev-parse --show-toplevel)
  MAIN_ROOT=$(git -C "$WORKTREE_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/.git$||')
  if [ "$WORKTREE_ROOT" != "$MAIN_ROOT" ] 2>/dev/null; then
    echo "Worktree detected: $(basename $WORKTREE_ROOT) — skipping sync, reading context only"
    # SKIP to Step 2
  fi
fi
```

If in a worktree: **skip Step 1 (sync)** → go to Step 1.5 (plugins always run).

## Step 1: Sync repos (requires gh CLI)

**First, check if prerequisites exist:**
```bash
command -v gh >/dev/null 2>&1 && echo "gh: OK" || echo "gh: MISSING"
command -v git >/dev/null 2>&1 && echo "git: OK" || echo "git: MISSING"
command -v infisical >/dev/null 2>&1 && echo "infisical: OK" || echo "infisical: MISSING"
```

If gh or git is MISSING, tell the user:
> "Some tools aren't installed yet. Run the setup script first: `bash ~/Documents/Claude/scripts/bootstrap.sh` — or if this is a brand new machine: `bash <(curl -s https://raw.githubusercontent.com/Wakewell-Sleep-Solutions/aria-slack-bot/main/scripts/bootstrap.sh)`"

Then **skip to Step 2** — work with whatever repos are already cloned locally.

**If gh is available**, sync all repos:
```bash
cd ~/Documents
gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' | while read repo; do
  if [ "$repo" = "aria-slack-bot" ]; then
    if [ ! -d ~/Documents/Claude ]; then
      gh repo clone Wakewell-Sleep-Solutions/aria-slack-bot Claude
    else
      git -C ~/Documents/Claude pull --ff-only 2>/dev/null || true
    fi
  elif [ -d "$repo" ]; then
    git -C "$repo" pull --ff-only 2>/dev/null || true
  else
    gh repo clone "Wakewell-Sleep-Solutions/$repo" 2>/dev/null || true
  fi
done
```

**Infisical:** If `infisical` is installed but not authenticated, ASK THE USER:
> "Infisical isn't authenticated. Paste your one-time token, or type 'skip'."

If they provide a token, run: `infisical login --token="<TOKEN>"`

## Step 1.5: Install plugins and skills (ALWAYS runs — even in worktrees)

**MCP plugins** — check if configured, install if missing:
```bash
# Check what's already installed
claude mcp list 2>/dev/null || echo "Can't check MCP list"
```

Install only what's missing:
```bash
# Ruflo (core orchestration — always-on, replaces claude-flow)
claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true

# Context7 (free library docs)
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true

# GitHub (needs GITHUB_PERSONAL_ACCESS_TOKEN in env)
if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ]; then
  claude mcp add github -s user -- npx -y @modelcontextprotocol/server-github 2>/dev/null || true
fi
```

**On first session only** — ASK THE USER if they want to connect additional services:
> "Which services do you use? I can connect them: Slack, Gmail, Notion, Stripe, HubSpot, Google Drive, Railway, Supabase. Type the ones you want, or 'skip'."

For each one they choose, walk them through the OAuth connection or API key setup.

**Skills** — install gstack if missing:
```bash
ls ~/.claude/skills/gstack/SKILL.md 2>/dev/null && echo "gstack: OK" || claude install-skill garrytan/gstack 2>/dev/null || true
```

Q Stack and all org skills come from the repo's `.claude/skills/` directory — available automatically once cloned.

**Global CLAUDE.md** — sync from skills repo to user config:
```bash
SKILLS_DIR=""
for d in ~/Documents/claude-skills-ecosystem ~/.claude-skills; do
  [ -d "$d" ] && SKILLS_DIR="$d" && break
done

if [ -n "$SKILLS_DIR" ] && [ -f "$SKILLS_DIR/config/global-claude.md" ]; then
  # Only update if skills repo version is newer
  if [ ! -f ~/.claude/CLAUDE.md ] || ! diff -q "$SKILLS_DIR/config/global-claude.md" ~/.claude/CLAUDE.md >/dev/null 2>&1; then
    cp "$SKILLS_DIR/config/global-claude.md" ~/.claude/CLAUDE.md
    echo "Global CLAUDE.md updated from skills repo"
  else
    echo "Global CLAUDE.md: up to date"
  fi
else
  echo "Global CLAUDE.md: skills repo not found — skipping sync"
fi
```

**Rules** — sync from skills repo:
```bash
if [ -n "$SKILLS_DIR" ] && [ -d "$SKILLS_DIR/config/rules" ]; then
  mkdir -p ~/.claude/rules
  cp "$SKILLS_DIR/config/rules/"*.md ~/.claude/rules/ 2>/dev/null
  echo "Global rules synced"
fi
```

## Step 2: Read org context

**Find key repos** — check standard locations:
```bash
# Skills ecosystem (source of truth for config/bootstrap)
SKILLS_DIR=""
for d in ~/Documents/claude-skills-ecosystem ~/.claude-skills; do
  [ -d "$d" ] && SKILLS_DIR="$d" && break
done
echo "Skills repo: ${SKILLS_DIR:-NOT FOUND}"

# Org hub (aria-slack-bot)
ORG_DIR=""
for d in ~/Documents/Claude ~/Documents/Claud ~/Documents/aria-slack-bot; do
  [ -f "$d/CLAUDE.md" ] && ORG_DIR="$d" && break
done
echo "Org repo: ${ORG_DIR:-NOT FOUND}"
```

Read these files (skip any that don't exist):
1. `./CLAUDE.md` — the project you're in right now
2. The org repo's `CLAUDE.md` — org identity, key systems, behavior rules
3. The org repo's `docs/SETUP-GUIDE.md` — sections 3-5 only (business, what we've built, connections)
4. For aria-slack-bot: also skim MEMORY.md topic index for accumulated project knowledge

If files are missing, work with what's available. Don't error out — just note what's missing.

## Step 3: Check what changed recently

```bash
for d in ~/Documents/*/; do
  if [ -d "$d/.git" ]; then
    CHANGES=$(git -C "$d" log --oneline --since="24 hours ago" 2>/dev/null | head -5)
    if [ -n "$CHANGES" ]; then
      echo "=== $(basename $d) ==="
      echo "$CHANGES"
    fi
  fi
done
```

If there are recent changes, briefly summarize: "Since your last session, [X] was updated in [project]."
If git isn't available or no changes, skip this step silently.

## Step 4: Ask experience level

Ask: "What's your experience level? (1) Expert (2) Intermediate (3) Learning"

Apply guardrails per the global CLAUDE.md:
- **Expert**: No guardrails. Execute directly.
- **Intermediate**: Confirm before destructive actions.
- **Learning**: Explain everything, confirm before every change.

## Step 5: Confirm project

If not obvious from the working directory, ask which project. Show the table:

| Project | Directory |
|---------|-----------|
| Aria (org hub) | `~/Documents/Claude/` |
| Super RCM (data server) | `~/Documents/super-rcm/` |
| 5D Smiles Dashboard | `~/Documents/5dsmiles-landing/` |
| WakeWell Website | `~/Documents/WakewellWeb/` |
| Skills | `~/Documents/claude-skills-ecosystem/` |

## Step 6: Orient and begin

Read the selected project's CLAUDE.md. You now have:
- What the organization does and how systems connect
- What changed in the last 24 hours (if available)
- The user's experience level and guardrail preferences
- The specific project context and rules

Begin working. If any bootstrap steps were skipped due to missing tools, note it once and move on — don't block the session.
