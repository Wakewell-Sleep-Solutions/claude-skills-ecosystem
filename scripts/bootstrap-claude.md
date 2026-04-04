# Claude Bootstrap — Run At Every Session Start

Read this file and follow these steps. You are reading context and asking questions — NOT installing software.

## Step 1: Check tools are installed

Run these checks:
```bash
# Source nvm if present (many machines use nvm for node/npm/npx)
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
# macOS Homebrew paths
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Required — blocks bootstrap if missing
echo "REQUIRED gh:$(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING) node:$(command -v node >/dev/null 2>&1 && echo OK || echo MISSING) infisical:$(command -v infisical >/dev/null 2>&1 && echo OK || echo MISSING)"
# Optional — warn but continue if missing (audit pipeline + tooling)
echo "OPTIONAL ruflo:$(command -v ruflo >/dev/null 2>&1 && echo OK || echo MISSING) az:$(command -v az >/dev/null 2>&1 && echo OK || echo MISSING)"
# Audit tools (semgrep, snyk, eslint, tsc, sonar-scanner) are checked in Step 5 — not here
```

**If any REQUIRED tool is MISSING** → STOP. Tell the user:
> "Core tools missing. Run this in Terminal first, then start a new Claude session:"
> `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`

**If only OPTIONAL tools are MISSING** → warn and continue:
> "Note: [tool names] not installed. The closed-loop audit pipeline (Waves 1-3) won't run. Install later with `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh`"

Continue to Step 2.

## Step 2: Check MCP servers

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
claude mcp list 2>/dev/null
```

**All 8 MCP servers are required (STOP if any missing — can't be added mid-session):**

| Server | Command | Purpose |
|--------|---------|---------|
| **context7** | `npx -y @upstash/context7-mcp@latest` | Up-to-date library/framework docs |
| **obsidian** | `npx -y @bitbonsai/mcpvault@latest ~/Documents/company-brain` | Company brain vault |
| **vanta** | `bash ~/Documents/scripts/vanta-mcp-wrapper.sh` | SOC 2 / HIPAA compliance |
| **ruflo** | `ruflo mcp start` | Workflow automation |
| **claude-flow** | `npx -y @claude-flow/cli@latest mcp start` | Multi-agent swarm orchestration |
| **kapture** | `npx -y kapture-mcp@latest bridge` | Browser automation |
| **stitch** | `npx -y stitch-mcp` | Google Stitch AI design canvas → code |
| **aceternity** | `npx -y aceternityui-mcp` | 200+ animated React/Tailwind components |

Note: GitHub MCP is not required — the `gh` CLI covers PRs, issues, and API calls natively.

If ANY are MISSING or FAILED, tell the user which ones and provide the add commands:
```bash
claude mcp add context7 -- npx -y @upstash/context7-mcp@latest
claude mcp add obsidian -- npx -y @bitbonsai/mcpvault@latest ~/Documents/company-brain
# Vanta: use whichever path has the wrapper
claude mcp add vanta -s user -- bash ~/Documents/scripts/vanta-mcp-wrapper.sh
# OR if scripts/ doesn't exist: bash ~/Documents/claude-skills-ecosystem/scripts/vanta-mcp-wrapper.sh
claude mcp add ruflo -s user -- ruflo mcp start
claude mcp add claude-flow -- npx -y @claude-flow/cli@latest mcp start
claude mcp add kapture -- npx -y kapture-mcp@latest bridge
claude mcp add stitch -- npx -y stitch-mcp
claude mcp add aceternity -- npx -y aceternityui-mcp
```
> "Then restart Claude."

Then STOP — MCP servers can't be added mid-session.

## Step 3: Check auth (Infisical + Azure)

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Infisical — exit-code based (no fragile pipe parsing)
infisical secrets --env=prod --path=/shared --silent >/dev/null 2>&1 && echo "infisical:OK" || echo "infisical:NOT_AUTHED"
# Azure — verify logged in, not just installed
az account show --query name -o tsv 2>/dev/null && echo "az:OK" || echo "az:NOT_LOGGED_IN"
```

If infisical NOT_AUTHED: tell user "Infisical isn't connected. Run `infisical login` in Terminal (opens browser for SSO)."
If az NOT_LOGGED_IN: tell user "Azure CLI isn't authenticated. Run `az login` in Terminal."
If both OK: say nothing.

## Step 4: Sync repos (skip in worktrees)

```bash
# Detect worktree
WORKTREE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
MAIN_ROOT=$(git -C "$WORKTREE_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's|/.git$||' 2>/dev/null)
[ "$WORKTREE_ROOT" != "$MAIN_ROOT" ] 2>/dev/null && echo "IN_WORKTREE" || echo "MAIN_REPO"
```

If IN_WORKTREE: skip this step entirely.

If MAIN_REPO: only pull the **current project** (fast, no latency from scanning all repos):
```bash
# Pull current project only
CWD=$(pwd)
if [ -d "$CWD/.git" ]; then
  REMOTE=$(git -C "$CWD" remote get-url origin 2>/dev/null || true)
  if echo "$REMOTE" | grep -qi "Wakewell-Sleep-Solutions"; then
    echo "Pulling: $(basename $CWD)"
    git -C "$CWD" pull --ff-only 2>/dev/null || echo "  skip (local changes)"
  fi
else
  echo "Not in a git repo — skipping project sync. cd into a project first, or pull manually."
fi
# Also pull company-brain (needed for Step 6) and skills ecosystem (this bootstrap)
[ -d ~/Documents/company-brain/.git ] && git -C ~/Documents/company-brain pull --ff-only 2>/dev/null
[ -d ~/Documents/claude-skills-ecosystem/.git ] && git -C ~/Documents/claude-skills-ecosystem pull --ff-only 2>/dev/null
```

## Step 5: Verify skills are installed

```bash
echo "skills-dir:$([ -d ~/.claude/skills ] && echo OK || echo MISSING)"
echo "skill-count:$(ls -d ~/.claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ') skills"
echo "gstack:$([ -d ~/.claude/skills/gstack ] && echo OK || echo MISSING)"
```

If skills-dir is MISSING or skill-count is 0:
> "Skills not installed. Run `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh` — Section 10 installs them."

If only gstack is MISSING but other skills exist: that's fine, gstack is optional.

If skills exist but seem outdated, pull latest:
```bash
[ -d ~/.claude/skills/.git ] && git -C ~/.claude/skills pull --ff-only 2>/dev/null
```

## Step 6: Verify code analysis stack

The closed-loop code analysis system runs automatically via PostToolUse hooks. Verify:

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Scripts can be at ~/Documents/scripts/ OR ~/Documents/claude-skills-ecosystem/scripts/
SCRIPTS="$HOME/Documents/scripts"
SKILLS_SCRIPTS="$HOME/Documents/claude-skills-ecosystem/scripts"
echo "analyzer:$([ -x $SCRIPTS/code-analyzer.sh ] || [ -x $SKILLS_SCRIPTS/code-analyzer.sh ] && echo OK || echo MISSING)"
echo "hook:$([ -x $SCRIPTS/claude-hook-analyze.sh ] || [ -x $SKILLS_SCRIPTS/claude-hook-analyze.sh ] && echo OK || echo MISSING)"
echo "hook-active:$(grep -q 'claude-hook-analyze' ~/.claude/settings.json 2>/dev/null && echo OK || echo MISSING)"
echo "semgrep:$(semgrep --version 2>/dev/null || echo MISSING)"
echo "snyk:$(snyk --version 2>/dev/null || echo MISSING)"
echo "eslint:$(npx eslint --version 2>/dev/null || eslint --version 2>/dev/null || echo MISSING)"
echo "tsc:$(command -v tsc >/dev/null 2>&1 && echo OK || echo "OK (project-scoped via npx)")"
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

If hook-active is MISSING: warn user that the analyzer won't fire automatically.
If any tool is MISSING: `brew install semgrep sonar-scanner && npm install -g snyk eslint typescript`

## Step 7: Read org context from Company Brain

The Company Brain vault (`~/Documents/company-brain/`) is the single source of truth for all org context.

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
# Use 3 days to cover weekends (Fri 5pm → Mon 9am)
for d in ~/Documents/*/; do
  if [ -d "$d/.git" ]; then
    CHANGES=$(git -C "$d" log --oneline --since="3 days ago" 2>/dev/null | head -5)
    if [ -n "$CHANGES" ]; then
      echo "=== $(basename $d) ==="
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
- Full scan: `irun bash ~/Documents/scripts/code-analyzer.sh --all <project>`
- Security only: `bash ~/Documents/scripts/code-analyzer.sh --tier 2 <project>`
- Cloud: Azure exclusively (`az` CLI). Never AWS/GCP.
- Secrets: Infisical (local dev) + Azure Key Vault (production). Never `.env` files.
