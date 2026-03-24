# Claude Bootstrap — Run At Every Session Start

Read this file and follow these steps. You are reading context and asking questions — NOT installing software.

## Step 1: Check tools are installed

Run this single command:
```bash
echo "gh:$(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING) ruflo:$(command -v ruflo >/dev/null 2>&1 && echo OK || echo MISSING) infisical:$(command -v infisical >/dev/null 2>&1 && echo OK || echo MISSING) node:$(command -v node >/dev/null 2>&1 && echo OK || echo MISSING)"
```

If ANYTHING is MISSING, tell the user:
> "Some tools aren't installed. Run this in Terminal first, then start a new Claude session:"
> `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`

Then STOP. Don't continue the bootstrap — the human bootstrap needs to run first.

If everything is OK, continue.

## Step 2: Check MCP servers

```bash
claude mcp list 2>/dev/null | grep -E "ruflo|context7|github" || echo "MCP_MISSING"
```

If MCP_MISSING, tell the user:
> "MCP servers need setup. Run this in Terminal:"
> `claude mcp add ruflo -s user -- ruflo mcp start`
> `claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest`
> `claude mcp add github -s user -- npx -y @modelcontextprotocol/server-github`
> "Then restart Claude."

Then STOP. MCP servers can't be added mid-session.

## Step 3: Check plugins

```bash
claude plugin list 2>/dev/null | grep -E "claude-mem|ralph" || echo "PLUGINS_MISSING"
```

If PLUGINS_MISSING, tell the user:
> "Plugins need setup. Run these in a fresh Claude session:"
> `/install-plugin thedotmack/claude-mem`
> `/install-plugin claude-plugins-official/ralph-loop`

Note the missing plugins but continue — they're not blocking.

## Step 4: Sync repos (skip in worktrees)

```bash
# Detect worktree
WORKTREE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
MAIN_ROOT=$(git -C "$WORKTREE_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/.git$||' 2>/dev/null)
[ "$WORKTREE_ROOT" != "$MAIN_ROOT" ] 2>/dev/null && echo "IN_WORKTREE" || echo "MAIN_REPO"
```

If IN_WORKTREE: skip this step entirely.

If MAIN_REPO and gh is available:
```bash
# Pull all org repos that exist locally
for d in ~/Documents/*/; do
  [ -d "$d/.git" ] || continue
  REMOTE=$(git -C "$d" remote get-url origin 2>/dev/null || true)
  if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
    echo "Pulling: $(basename $d)"
    git -C "$d" pull --ff-only 2>/dev/null || echo "  skip (local changes)"
  fi
done

# Clone any new org repos
gh repo list Wakewell-Sleep-Solutions --limit 50 --json name -q '.[].name' 2>/dev/null | while read repo; do
  FOUND=false
  for d in ~/Documents/*/; do
    REMOTE=$(git -C "$d" remote get-url origin 2>/dev/null || true)
    echo "$REMOTE" | grep -qi "$repo" && FOUND=true && break
  done
  if [ "$FOUND" = "false" ]; then
    TARGET=~/Documents/"$repo"
    [ "$repo" = "aria-slack-bot" ] && TARGET=~/Documents/Claude
    [ ! -d "$TARGET" ] && gh repo clone "Wakewell-Sleep-Solutions/$repo" "$TARGET" 2>/dev/null && echo "Cloned: $(basename $TARGET)" || true
  fi
done
```

## Step 5: Read org context

Read these files (skip any that don't exist — don't error):
1. `./CLAUDE.md` (current project rules)
2. `~/Documents/Claude/CLAUDE.md` (org hub rules — skip if same as #1)
3. `~/Documents/Claude/docs/SETUP-GUIDE.md` sections 3-5 only (business, systems, connections)

## Step 6: What changed recently

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

Summarize briefly: "Since last session, [repo] had [N] commits: [what changed]."
No changes? Say nothing.

## Step 7: Ask two questions

**Question 1:** "What's your experience level? (1) Expert (2) Intermediate (3) Learning"
- **Expert**: No guardrails. Execute directly.
- **Intermediate**: Confirm before destructive actions.
- **Learning**: Explain everything, confirm before changes.

**Question 2:** If not obvious from the working directory, show the project picker:

| Project | Directory | What it is |
|---------|-----------|------------|
| Aria (org hub) | `~/Documents/Claude/` | Slack bot, org hub, n8n workflows |
| Super RCM | `~/Documents/super-rcm/` | Central data server, Open Dental sync |
| 5D Smiles Dashboard | `~/Documents/5dsmiles-landing/` | Practice analytics dashboard |
| WakeWell Website | `~/Documents/WakewellWeb/` | WakeWell public website |
| Skills | `~/Documents/claude-skills-ecosystem/` | Shared skills, bootstrap, config |

## Step 8: Begin

Read the selected project's CLAUDE.md. Start working.
