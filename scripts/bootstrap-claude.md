# Claude Bootstrap — Run At Every Session Start

Read this file and follow these steps. You are reading context and asking questions — NOT installing software.

## Step 1: Check tools are installed

Run these checks:
```bash
# Source nvm if present (many machines use nvm for node/npm/npx)
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
# macOS Homebrew paths
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Windows Python Scripts (semgrep installs here via pip)
[ -d "$HOME/AppData/Local/Programs/Python" ] && export PATH="$HOME/AppData/Local/Programs/Python/Python*/Scripts:$PATH"
[ -d "$LOCALAPPDATA/Programs/Python" ] && export PATH="$(ls -d "$LOCALAPPDATA"/Programs/Python/Python*/Scripts 2>/dev/null | head -1):$PATH"
# Required — blocks bootstrap if missing
echo "REQUIRED gh:$(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING) node:$(command -v node >/dev/null 2>&1 && echo OK || echo MISSING) infisical:$(command -v infisical >/dev/null 2>&1 && echo OK || echo MISSING)"
# Optional — warn but continue if missing
echo "OPTIONAL ruflo:$(command -v ruflo >/dev/null 2>&1 && echo OK || echo MISSING) az:$(command -v az >/dev/null 2>&1 && echo OK || echo MISSING)"
# Audit tools checked in Step 6 — not here
```

**If any REQUIRED tool is MISSING** → STOP. Tell the user:
> "Core tools missing. Run this in Terminal first, then start a new Claude session:"
> `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`

**If only OPTIONAL tools are MISSING** → warn and continue.

Continue to Step 2.

## Step 2: Check MCP servers

Do NOT run `claude mcp list` — it may not be in PATH. Instead, check which MCP tools are available to you by looking at your own tool list. You (the agent) can see what MCP servers are connected by checking if tools with the `mcp__<server>__` prefix exist.

**All 8 MCP servers are required (STOP if any missing — can't be added mid-session):**

| Server | Tool prefix to check | Purpose |
|--------|---------------------|---------|
| **context7** | `mcp__context7__` | Up-to-date library/framework docs |
| **obsidian** | `mcp__obsidian__` | Company brain vault |
| **vanta** | `mcp__vanta__` | SOC 2 / HIPAA compliance |
| **ruflo** | `mcp__ruflo__` | Workflow automation |
| **claude-flow** | `mcp__claude-flow__` | Multi-agent swarm orchestration |
| **kapture** | `mcp__kapture__` or `mcp__Kapture__` | Browser automation |
| **stitch** | `mcp__stitch__` | Google Stitch AI design → code |
| **aceternity** | `mcp__aceternity__` | 200+ animated React/Tailwind components |

Note: GitHub MCP is not required — the `gh` CLI covers PRs, issues, and API calls natively.

If ANY server is missing, tell the user to run these commands in a separate terminal, then restart Claude:
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add obsidian -- npx -y @bitbonsai/mcpvault@latest ~/Documents/company-brain
claude mcp add vanta -s user -- bash ~/Documents/claude-skills-ecosystem/scripts/vanta-mcp-wrapper.sh
claude mcp add ruflo -s user -- ruflo mcp start
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest mcp start
claude mcp add kapture -- npx -y kapture-mcp@latest bridge
claude mcp add stitch -- npx -y stitch-mcp
claude mcp add aceternity -- npx -y aceternityui-mcp
```

Then STOP — MCP servers can't be added mid-session. All 8 are required.

## Step 3: Check auth (Infisical + Azure)

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Infisical — exit-code based
infisical secrets --env=prod --path=/shared --silent >/dev/null 2>&1 && echo "infisical:OK" || echo "infisical:NOT_AUTHED"
# Azure — verify logged in, not just installed
az account show --query name -o tsv 2>/dev/null && echo "az:OK" || echo "az:NOT_LOGGED_IN"
```

If infisical NOT_AUTHED: tell user "Infisical isn't connected. Run `infisical login` in Terminal (opens browser for SSO)."
If az NOT_LOGGED_IN: tell user "Azure CLI isn't authenticated. Run `az login` in Terminal."
If both OK: say nothing.

## Step 4: Sync repos (skip in worktrees)

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

CWD=$(pwd)
# Only attempt git operations if we're actually in a git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  WORKTREE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
  MAIN_ROOT=$(git -C "$WORKTREE_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/.git$||' 2>/dev/null)
  if [ "$WORKTREE_ROOT" != "$MAIN_ROOT" ]; then
    echo "IN_WORKTREE — skipping sync"
  else
    REMOTE=$(git remote get-url origin 2>/dev/null || true)
    if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
      echo "Pulling: $(basename "$CWD")"
      git pull --ff-only 2>/dev/null || echo "  ⚠️ Pull failed (local changes or network issue)"
    fi
  fi
else
  echo "Not in a git repo — skipping project sync."
fi
# Always pull company-brain + skills ecosystem (needed for Steps 5-7)
for repo in ~/Documents/company-brain ~/Documents/claude-skills-ecosystem; do
  if [ -d "$repo/.git" ]; then
    git -C "$repo" pull --ff-only 2>/dev/null || echo "  ⚠️ $(basename "$repo") pull failed"
  fi
done
```

## Step 5: Verify skills are installed

```bash
echo "skills-dir:$([ -d ~/.claude/skills ] && echo OK || echo MISSING)"
echo "skill-count:$(ls -d ~/.claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ') skills"
```

If skills-dir is MISSING or skill-count is 0:
> "Skills not installed. Run `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh` — Section 10 installs them."

If skills exist but seem outdated, pull latest:
```bash
[ -d ~/.claude/skills/.git ] && git -C ~/.claude/skills pull --ff-only 2>/dev/null
```

## Step 6: Verify code analysis stack

The closed-loop code analysis system runs automatically via PostToolUse hooks. Verify:

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
[ -d "$HOME/AppData/Local/Programs/Python" ] && export PATH="$(ls -d "$LOCALAPPDATA"/Programs/Python/Python*/Scripts 2>/dev/null | head -1):$PATH"
# Scripts live in the skills ecosystem repo
SCRIPTS="$HOME/Documents/claude-skills-ecosystem/scripts"
echo "analyzer:$([ -f $SCRIPTS/code-analyzer.sh ] && echo OK || echo MISSING)"
echo "hook:$([ -f $SCRIPTS/claude-hook-analyze.sh ] && echo OK || echo MISSING)"
echo "hook-active:$(grep -q 'claude-hook-analyze\|codex-audit' ~/.claude/settings.json 2>/dev/null && echo OK || echo MISSING)"
echo "semgrep:$(semgrep --version 2>/dev/null || echo MISSING)"
echo "snyk:$(snyk --version 2>/dev/null || echo MISSING)"
echo "eslint:$(npx eslint --version 2>/dev/null || eslint --version 2>/dev/null || echo MISSING)"
echo "tsc:$(command -v tsc >/dev/null 2>&1 && echo OK || (npx tsc --version >/dev/null 2>&1 && echo "OK (npx)" || echo MISSING))"
echo "sonar:$(command -v sonar-scanner >/dev/null 2>&1 && echo OK || echo MISSING)"
```

**Closed-loop stack:**
| Tool | Trigger | What it catches |
|------|---------|-----------------|
| ESLint + TypeScript | Every edit (PostToolUse hook) | Code quality, type errors |
| Semgrep | Every edit (PostToolUse hook) | OWASP Top 10, secrets, HIPAA |
| Snyk | Manual / pre-commit | Dependency CVEs, code vulns |
| SonarCloud (org: `everestsleep`) | `irun code-analyzer.sh --tier 3` | Code smells, complexity, duplication |
| Vanta MCP | Always connected | SOC 2 / HIPAA compliance controls |

If hook-active is MISSING: warn user and provide fix:
> "The code analyzer hook is not registered. Run `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh` — it auto-registers the hook. Or add manually to `~/.claude/settings.json` under `hooks.PostToolUse`:"
> ```json
> {"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "bash ~/Documents/claude-skills-ecosystem/scripts/claude-hook-analyze.sh"}]}
> ```

If any tool is MISSING:
- macOS: `brew install semgrep sonar-scanner && npm install -g snyk eslint typescript`
- Windows: `pip install semgrep && npm install -g snyk eslint typescript` (sonar-scanner: download from sonarsource.com)

## Step 7: Read org context from Company Brain

The Company Brain vault (`~/Documents/company-brain/`) is the single source of truth for all org context.

**First, verify it exists:**
```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
[ -d ~/Documents/company-brain ] && echo "company-brain:OK" || echo "company-brain:MISSING"
```

If MISSING: tell user "Company Brain vault not found. Clone it: `gh repo clone Wakewell-Sleep-Solutions/company-brain ~/Documents/company-brain`"
Then skip to Step 8 — org context is unavailable without it.

If present, load context:

1. Read `~/Documents/company-brain/CLAUDE.md` (context router — tells you what to load)
2. Read `./CLAUDE.md` (current project rules)
3. Based on the current working directory, load the relevant project files from Company Brain.
   **Skip any file that doesn't exist** — the vault grows over time, not all projects have entries yet.
   - `~/Documents/Claude/` → `company-brain/projects/aria/overview.md`
   - `~/Documents/super-rcm/` → `company-brain/projects/super-rcm/overview.md` + `company-brain/systems/data-flows.md`
   - `~/Documents/5dsmiles-landing/` → `company-brain/projects/dashboard/overview.md`
   - `~/Documents/WakewellWeb/` → `company-brain/projects/wakewell/overview.md`
   - `~/Documents/claude-skills-ecosystem/` → `company-brain/projects/skills/overview.md`
   - `~/Documents/ClaimMDGHL-Sync-Machine/` → `company-brain/projects/wakewell/overview.md` (claims subsystem)
   - `~/Documents/wakewell-b2b-dashboard/` → `company-brain/projects/wakewell/overview.md` (B2B subsystem)
   - `~/Documents/sleep_test_scheduler/` → `company-brain/projects/wakewell/overview.md` (scheduling subsystem)
   - WordPress/5dsmiles.com → `company-brain/projects/5dsmiles/overview.md`
4. Always load (if they exist): `company-brain/org/entities.md` + `company-brain/lessons/feedback.md`
5. Scan recent decisions (if any exist):
   ```bash
   ls -t ~/Documents/company-brain/decisions/*.md 2>/dev/null | head -5
   ```
   Read any decisions relevant to your current project. These override default patterns.
6. For HIPAA-sensitive work → also load `company-brain/operations/compliance.md` + `company-brain/systems/data-flows.md`

## Step 8: What changed recently

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Use 3 days to cover weekends (Fri 5pm → Mon 9am)
for d in ~/Documents/*/; do
  if [ -d "$d/.git" ]; then
    CHANGES=$(git -C "$d" log --oneline --since="3 days ago" 2>/dev/null | head -5)
    if [ -n "$CHANGES" ]; then
      echo "=== $(basename "$d") ==="
      echo "$CHANGES"
    fi
  fi
done
```

Summarize briefly: "Recently, [repo] had [N] commits: [what changed]."
No changes? Say nothing.

## Step 9: Project picker

Dr. Qiu is always Expert mode — skip the experience level question. Execute directly, no guardrails.

If not obvious from the working directory, show the project picker:

| Project | Directory | What it is |
|---------|-----------|------------|
| Aria (org hub) | `~/Documents/Claude/` | Slack bot, org hub, n8n workflows |
| Super RCM | `~/Documents/super-rcm/` | Central data server, Open Dental sync |
| 5D Smiles Dashboard | `~/Documents/5dsmiles-landing/` | Practice analytics, 67 API routes |
| WakeWell Website | `~/Documents/WakewellWeb/` | WakeWell public website (Azure) |
| Claims Bridge | `~/Documents/ClaimMDGHL-Sync-Machine/` | ClaimMD API, eligibility, claims |
| B2B Dashboard | `~/Documents/wakewell-b2b-dashboard/` | Physician outreach, Lemlist, fax |
| Sleep Scheduler | `~/Documents/sleep_test_scheduler/` | HST booking, Stripe, GHL pipeline |
| Pegasus | `~/Documents/Pegasus/` | App with lint + test |
| Skills | `~/Documents/claude-skills-ecosystem/` | 48+ portable Claude Code skills |

## Step 10: Begin

Read the selected project's CLAUDE.md. Start working.

**Quick reference:**
- Full scan: `irun bash ~/Documents/claude-skills-ecosystem/scripts/code-analyzer.sh --all <project>`
- Security only: `bash ~/Documents/claude-skills-ecosystem/scripts/code-analyzer.sh --tier 2 <project>`
- Cloud: Azure exclusively (`az` CLI). Never AWS/GCP.
- Secrets: Infisical (local dev, inject via `irun <cmd>`) + Azure Key Vault (production). Never `.env` files.
