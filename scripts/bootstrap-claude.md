# Claude Bootstrap — Run At Every Session Start

Execute these steps in order. Do not skip steps. Do not install system tools — that's the human bootstrap's job (`scripts/bootstrap.sh`).

## Step 0: Detect environment

```bash
IN_WORKTREE=false
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  WORKTREE_ROOT=$(git rev-parse --show-toplevel)
  MAIN_ROOT=$(git -C "$WORKTREE_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/.git$||')
  if [ "$WORKTREE_ROOT" != "$MAIN_ROOT" ] 2>/dev/null; then
    IN_WORKTREE=true
  fi
fi
```

If `IN_WORKTREE=true`: skip Step 1 (sync). Go directly to Step 1.5.

## Step 1: Sync repos

Check prerequisites:
```bash
command -v gh >/dev/null 2>&1 && echo "gh: OK" || echo "gh: MISSING"
command -v git >/dev/null 2>&1 && echo "git: OK" || echo "git: MISSING"
command -v infisical >/dev/null 2>&1 && echo "infisical: OK" || echo "infisical: MISSING"
```

If gh or git is MISSING, tell the user:
> "Tools aren't installed. Run: `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`"

Then skip to Step 2.

If gh is available, sync all repos:
```bash
cd ~/Documents
gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' | while read repo; do
  TARGET="$repo"
  [ "$repo" = "aria-slack-bot" ] && TARGET="Claude"
  if [ -d "$TARGET/.git" ]; then
    git -C "$TARGET" pull --ff-only 2>/dev/null || true
  elif [ ! -d "$TARGET" ]; then
    gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null || true
  fi
done
```

Infisical: If installed but not authenticated, ASK:
> "Infisical isn't authenticated. Paste your one-time token, or type 'skip'."

If they give a token: `infisical login --method=universal-auth --client-id="<TOKEN>"`

Verify (count only — NEVER show values):
```bash
infisical secrets --env=prod --path=/shared --silent 2>/dev/null | grep -c "│"
```
Should return 85+. If 0, tell user to check with admin.

## Step 1.5: Plugins, skills, and global config (ALWAYS runs)

This step runs every session, even in worktrees.

### MCP plugins — install if missing

```bash
claude mcp list 2>/dev/null
```

Install everything. These are idempotent — safe to run every session:
```bash
# Ruflo CLI + MCP server
npm install -g ruflo 2>/dev/null || true
claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true

# Context7 (free library docs)
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true

# GitHub
claude mcp add github -s user -- npx -y @modelcontextprotocol/server-github 2>/dev/null || true
```

### First session only — service connections

If no Slack/Gmail/Notion/Stripe integrations are configured, ASK:
> "Which services should I connect? Slack, Gmail, Notion, Stripe, HubSpot, Google Drive, Railway, Supabase. Type the ones you want, or 'skip'."

Walk them through OAuth or API key setup for each.

### Skills — install gstack if missing

```bash
ls ~/.claude/skills/gstack/SKILL.md 2>/dev/null && echo "gstack: OK" || claude install-skill garrytan/gstack 2>/dev/null || true
```

Q Stack and all org skills load automatically from the repo's `.claude/skills/` directory.

### Plugins — install all

```bash
# claude-mem (cross-session memory)
claude install-plugin thedotmack/claude-mem 2>/dev/null || true

# ralph-loop (autonomous iteration)
claude install-plugin claude-plugins-official/ralph-loop 2>/dev/null || true
```

### Global CLAUDE.md — sync from skills repo

```bash
SKILLS_DIR=""
for d in ~/Documents/claude-skills-ecosystem ~/.claude-skills; do
  [ -d "$d" ] && SKILLS_DIR="$d" && break
done

if [ -n "$SKILLS_DIR" ] && [ -f "$SKILLS_DIR/config/global-claude.md" ]; then
  if [ ! -f ~/.claude/CLAUDE.md ] || ! diff -q "$SKILLS_DIR/config/global-claude.md" ~/.claude/CLAUDE.md >/dev/null 2>&1; then
    cp "$SKILLS_DIR/config/global-claude.md" ~/.claude/CLAUDE.md
    echo "Global CLAUDE.md updated"
  fi
fi
```

### Global rules — sync from skills repo

```bash
if [ -n "$SKILLS_DIR" ] && [ -d "$SKILLS_DIR/config/rules" ]; then
  mkdir -p ~/.claude/rules
  cp "$SKILLS_DIR/config/rules/"*.md ~/.claude/rules/ 2>/dev/null
fi
```

## Step 2: Read org context

Find key repos:
```bash
SKILLS_DIR=""
for d in ~/Documents/claude-skills-ecosystem ~/.claude-skills; do
  [ -d "$d" ] && SKILLS_DIR="$d" && break
done

ORG_DIR=""
for d in ~/Documents/Claude ~/Documents/Claud ~/Documents/aria-slack-bot; do
  [ -f "$d/CLAUDE.md" ] && ORG_DIR="$d" && break
done
```

Read these files (skip any that don't exist):
1. `./CLAUDE.md` — current project rules
2. Org repo `CLAUDE.md` — org identity, systems, behavior
3. Org repo `docs/SETUP-GUIDE.md` — sections 3-5 (business, systems, connections)
4. For aria-slack-bot: skim MEMORY.md topic index

Don't error on missing files — note what's missing and continue.

## Step 3: What changed (last 24 hours)

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

Summarize: "Since your last session, [X] had [N] commits: [brief description]."
No changes? Skip silently.

## Step 4: Experience level

Ask: "What's your experience level? (1) Expert (2) Intermediate (3) Learning"

- **Expert**: No guardrails. Execute directly. Only stop for genuinely irreversible actions.
- **Intermediate**: Confirm before deleting files, replacing working code, or rewriting modules.
- **Learning**: Restate the plan before starting. Explain what exists before changing it. Push back on "start fresh."

## Step 5: Project selection

If not obvious from the working directory, show the table:

| Project | Directory | What it is |
|---------|-----------|------------|
| Aria (org hub) | `~/Documents/Claude/` | Slack bot, org hub, n8n workflows |
| Super RCM | `~/Documents/super-rcm/` | Central data server, Open Dental sync, PHI-scrubbed APIs |
| 5D Smiles Dashboard | `~/Documents/5dsmiles-landing/` | Practice analytics dashboard |
| WakeWell Website | `~/Documents/WakewellWeb/` | WakeWell public website |
| Skills | `~/Documents/claude-skills-ecosystem/` | Shared skills, bootstrap, global config |

## Step 6: Begin

Read the selected project's CLAUDE.md. You now have:
- Org context and how systems connect
- Recent changes across all repos
- User's experience level and guardrails
- Project-specific rules and architecture

Start working. Note any skipped steps once, then move on.
