# Claude Bootstrap — Run At Every Session Start

Read this file and follow these steps. You are reading context and asking questions — NOT installing software.

## Step 1: Check tools are installed

Run this single command:
```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
echo "gh:$(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING) ruflo:$(command -v ruflo >/dev/null 2>&1 && echo OK || echo MISSING) infisical:$(command -v infisical >/dev/null 2>&1 && echo OK || echo MISSING) node:$(command -v node >/dev/null 2>&1 && echo OK || echo MISSING) semgrep:$(command -v semgrep >/dev/null 2>&1 && echo OK || echo MISSING) snyk:$(command -v snyk >/dev/null 2>&1 && echo OK || echo MISSING) eslint:$(command -v eslint >/dev/null 2>&1 && echo OK || echo MISSING) sonar-scanner:$(command -v sonar-scanner >/dev/null 2>&1 && echo OK || echo MISSING)"
```

If ANYTHING is MISSING, tell the user:
> "Some tools aren't installed. Run this in Terminal first, then start a new Claude session:"
> `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`

Then STOP. Don't continue the bootstrap — the human bootstrap needs to run first.

If everything is OK, continue.

## Step 2: Check MCP servers

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
claude mcp list 2>/dev/null | grep -E "ruflo|context7|vanta|obsidian|claude-flow|kapture" || echo "MCP_MISSING"
```

Expected MCP servers (all 6 must be connected):
- **ruflo** — workflow automation
- **context7** — up-to-date library/framework docs
- **vanta** — SOC 2 / HIPAA compliance (via `~/Documents/scripts/vanta-mcp-wrapper.sh`)
- **obsidian** — company brain vault
- **claude-flow** — multi-agent swarm orchestration
- **kapture** — browser automation

If ANY are MISSING, tell the user which ones and provide the add commands:
> `claude mcp add ruflo -s user -- ruflo mcp start`
> `claude mcp add context7 -- npx -y @upstash/context7-mcp@latest`
> `claude mcp add vanta -s user -- bash ~/Documents/scripts/vanta-mcp-wrapper.sh`
> `claude mcp add obsidian -- npx -y @bitbonsai/mcpvault@latest ~/Documents/company-brain`
> `claude mcp add claude-flow -- npx -y @claude-flow/cli@latest mcp start`
> `claude mcp add kapture -- npx -y kapture-mcp@latest bridge`
> "Then restart Claude."

Then STOP. MCP servers can't be added mid-session.

## Step 3: Check skills and plugins

```bash
echo "gstack:$([ -d ~/.claude/skills/gstack ] && echo OK || echo MISSING)"
echo "claude-mem:$([ -d ~/.claude/plugins/marketplaces/thedotmack ] && echo OK || echo MISSING)"
echo "ralph-loop:$([ -d ~/.claude/plugins/marketplaces/claude-plugins-official ] && echo OK || echo MISSING)"
```

If ANY are MISSING, you are inside a Claude session so use the interactive install commands:

- gstack missing → tell user: "I need to install gstack. Type: `/install-skill garrytan/gstack`"
- claude-mem missing → tell user: "I need to install claude-mem. Type: `/install-plugin thedotmack/claude-mem`"
- ralph-loop missing → tell user: "I need to install ralph-loop. Type: `/install-plugin claude-plugins-official/ralph-loop`"

Wait for user to run each one. If they fail, fall back to git clone:
```bash
git clone https://github.com/Wakewell-Sleep-Solutions/claude-skills-ecosystem.git ~/.claude/skills 2>/dev/null
git clone https://github.com/thedotmack/claude-mem.git ~/.claude/plugins/marketplaces/thedotmack 2>/dev/null
git clone https://github.com/claude-plugins-official/ralph-loop.git ~/.claude/plugins/marketplaces/claude-plugins-official 2>/dev/null
```

## Step 3b: Verify Infisical secrets

```bash
infisical secrets --env=prod --path=/shared --silent 2>/dev/null | grep -c "│" || echo "0"
```

If count is 0 or errors: tell user "Infisical isn't connected. Run `infisical login` in Terminal."
If count > 0: say nothing (it's working).

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

## Step 5: Verify code analysis stack

The closed-loop code analysis system runs automatically via PostToolUse hooks. Verify it's operational:

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
echo "analyzer:$([ -x ~/Documents/scripts/code-analyzer.sh ] && echo OK || echo MISSING)"
echo "hook:$([ -x ~/Documents/scripts/claude-hook-analyze.sh ] && echo OK || echo MISSING)"
echo "semgrep:$(semgrep --version 2>/dev/null || echo MISSING)"
echo "snyk:$(snyk --version 2>/dev/null || echo MISSING)"
echo "eslint:$(eslint --version 2>/dev/null || echo MISSING)"
echo "sonar:$(sonar-scanner --version 2>&1 | grep CLI | awk '{print $NF}' || echo MISSING)"
```

**Stack summary (all should be installed):**
- **ESLint + TypeScript** — every edit (PostToolUse hook)
- **Semgrep** — every edit (OWASP, secrets, HIPAA)
- **Snyk** — dependency + code vuln scanning
- **SonarCloud** — deep analysis, org: `everestsleep`
- **Vanta MCP** — SOC 2 / HIPAA compliance controls

If MISSING: `brew install semgrep sonar-scanner && npm install -g snyk eslint typescript`

**Full scan command:** `irun bash ~/Documents/scripts/code-analyzer.sh --all <project-dir>`

## Step 6: Read org context from Company Brain

The Company Brain vault (`~/Documents/company-brain/`) is the single source of truth for all org context.

1. Read `~/Documents/company-brain/CLAUDE.md` (context router — tells you what to load)
2. Read `./CLAUDE.md` (current project rules)
3. Based on the current working directory, load the relevant project files from Company Brain:
   - Working in `~/Documents/Claude/` → read `company-brain/projects/aria/overview.md`
   - Working in `~/Documents/super-rcm/` → read `company-brain/projects/super-rcm/overview.md` + `company-brain/systems/data-flows.md`
   - Working in `~/Documents/5dsmiles-landing/` → read `company-brain/projects/dashboard/overview.md`
   - Working in `~/Documents/WakewellWeb/` → read `company-brain/projects/wakewell/overview.md`
   - Working in `~/Documents/claude-skills-ecosystem/` → read `company-brain/projects/skills/overview.md`
   - WordPress/5dsmiles.com work → read `company-brain/projects/5dsmiles/overview.md`
4. Always load `company-brain/org/entities.md` + `company-brain/lessons/feedback.md` (applies to all work)
5. For HIPAA-sensitive work → also load `company-brain/operations/compliance.md` + `company-brain/systems/data-flows.md`

## Step 7: What changed recently

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

## Step 8: Ask two questions

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
| WakeWell Website | `~/Documents/WakewellWeb/` | WakeWell public website (Azure) |
| Claims Bridge | `~/Documents/ClaimMDGHL-Sync-Machine/` | ClaimMD API, eligibility, claims |
| B2B Dashboard | `~/Documents/wakewell-b2b-dashboard/` | Physician outreach, Lemlist, fax |
| Sleep Scheduler | `~/Documents/sleep_test_scheduler/` | HST booking, Stripe, GHL pipeline |
| Pegasus | `~/Documents/Pegasus/` | App with lint + test |
| Skills | `~/Documents/claude-skills-ecosystem/` | Shared skills, bootstrap, config |

## Step 9: Begin

Read the selected project's CLAUDE.md. Start working.
