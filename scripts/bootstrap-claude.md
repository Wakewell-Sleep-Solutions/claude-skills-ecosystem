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
# Check both common Python install locations; convert Windows paths to Unix-style for Git Bash
for pydir in "$HOME/AppData/Local/Python" "$HOME/AppData/Local/Programs/Python"; do
  PYBIN=$(ls -d "$pydir"/Python*/Scripts 2>/dev/null "$pydir"/pythoncore*/Scripts 2>/dev/null | head -1)
  [ -n "$PYBIN" ] && export PATH="$PYBIN:$PATH" && break
done
# Required — blocks bootstrap if missing
echo "REQUIRED gh:$(command -v gh >/dev/null 2>&1 && echo OK || echo MISSING) node:$(command -v node >/dev/null 2>&1 && echo OK || echo MISSING) infisical:$(command -v infisical >/dev/null 2>&1 && echo OK || echo MISSING)"
# Optional — warn but continue if missing
echo "OPTIONAL ruflo:$(command -v ruflo >/dev/null 2>&1 && echo OK || echo MISSING) az:$(command -v az >/dev/null 2>&1 && echo OK || echo MISSING)"
# Audit tools checked in Step 6 — not here
```

**If any REQUIRED tool is MISSING** → try to install it via Bash before stopping:
```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Install missing required tools:
# gh: brew install gh (macOS) or winget install GitHub.cli (Windows)
# node: brew install node (macOS) or winget install OpenJS.NodeJS.LTS (Windows)
# infisical:
#   macOS: brew install infisical/get-cli/infisical
#   Windows: winget install Infisical.CLI || npm install -g @infisical/cli
#   Linux: npm install -g @infisical/cli
```

If install fails or the tool still isn't found after installing, tell the user:
> "Could not install [tool]. Run `bash ~/Documents/claude-skills-ecosystem/scripts/bootstrap.sh` in Terminal."

**If only OPTIONAL tools are MISSING** → warn and continue.

Continue to Step 2.

## Step 2: Check MCP servers

Check which MCP tools are available by looking at your own tool list for `mcp__<server>__` prefixes.

**All 8 MCP servers are required:**

| Server | Tool prefix to check | Purpose |
|--------|---------------------|---------|
| **context7** | `mcp__context7__` | Up-to-date library/framework docs |
| **obsidian** | `mcp__obsidian__` | Company brain vault |
| **vanta** | `mcp__vanta__` | SOC 2 / HIPAA compliance |
| **ruflo** | `mcp__ruflo__` | Workflow automation |
| **kapture** | `mcp__kapture__` or `mcp__Kapture__` | Browser automation |
| **stitch** | `mcp__stitch__` | Google Stitch AI design → code |
| **aceternity** | `mcp__aceternity__` | 200+ animated React/Tailwind components |
| **wordpress** | `mcp__wordpress__` | 5dsmiles.com WordPress management |

Note: GitHub MCP is not required — the `gh` CLI covers PRs, issues, and API calls natively.

**If ANY server is missing, install it now using Bash.** You CAN run `claude mcp add` from inside a session — it writes to config files on disk. The server won't connect until the next session, but the registration is permanent.

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Run only the ones that are missing:
claude mcp add context7 -s user -- npx -y @upstash/context7-mcp@latest 2>/dev/null || true
claude mcp add obsidian -s user -- npx -y @bitbonsai/mcpvault@latest ~/Documents/company-brain 2>/dev/null || true
claude mcp add vanta -s user -e MSYS_NO_PATHCONV=1 -- bash ~/Documents/claude-skills-ecosystem/scripts/vanta-mcp-wrapper.sh 2>/dev/null || true
claude mcp add ruflo -s user -- ruflo mcp start 2>/dev/null || true
claude mcp add kapture -s user -- npx -y kapture-mcp@latest bridge 2>/dev/null || true
claude mcp add stitch -s user -- npx -y stitch-mcp 2>/dev/null || true
claude mcp add aceternity -s user -- npx -y aceternityui-mcp 2>/dev/null || true
# WordPress MCP — uses npx proxy to bridge STDIO to Streamable HTTP
# Requires: Node.js, WP plugins already installed on 5dsmiles.com (MCP Adapter + Enable Abilities for MCP)
# Auth: WordPress Application Password (NOT regular login password)
# Get creds from Infisical: /shared/wordpress-mcp
claude mcp add wordpress -s user -- /usr/local/bin/npx -y @automattic/mcp-wordpress-remote@latest 2>/dev/null || true
```

**WordPress MCP extra setup (first time on a new machine only):**

The WordPress MCP server needs env vars for auth. These go in `claude_desktop_config.json` (Desktop app) or `~/.claude/settings.json` (CLI). The `claude mcp add` command above registers the server, but you must manually add the `env` block with credentials from Infisical (`/shared/wordpress-mcp`):

```json
"wordpress": {
  "command": "/usr/local/bin/npx",
  "args": ["-y", "@automattic/mcp-wordpress-remote@latest"],
  "env": {
    "PATH": "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin",
    "WP_API_URL": "https://5dsmiles.com/wp-json/mcp/mcp-adapter-default-server",
    "WP_API_USERNAME": "<from Infisical /shared/wordpress-mcp>",
    "WP_API_PASSWORD": "<from Infisical /shared/wordpress-mcp>"
  }
}
```

**Config file location depends on your app:**
- Claude Desktop app: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Claude Code CLI: `~/.claude/settings.json`

**WP plugins (already installed on 5dsmiles.com — no action needed):**
- MCP Adapter (from github.com/WordPress/mcp-adapter, manual ZIP install)
- Enable Abilities for MCP (from WP plugin directory, abilities toggled on at Settings > WP Abilities)

After running the add commands, tell the user: "I've registered the missing MCP servers. They'll connect on your next Claude session. Restart Claude to activate them."

**Do NOT stop the bootstrap** — continue with the remaining steps. The MCP servers are registered and will work next session.

## Step 3: Check auth (Infisical + Azure)

```bash
[ -s "$HOME/.nvm/nvm.sh" ] && . "$HOME/.nvm/nvm.sh"
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
# Git Bash on Windows mangles /paths — must disable MSYS path conversion for infisical
export MSYS_NO_PATHCONV=1
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
for pydir in "$HOME/AppData/Local/Python" "$HOME/AppData/Local/Programs/Python"; do
  PYBIN=$(ls -d "$pydir"/Python*/Scripts 2>/dev/null "$pydir"/pythoncore*/Scripts 2>/dev/null | head -1)
  [ -n "$PYBIN" ] && export PATH="$PYBIN:$PATH" && break
done
# Scripts live in the skills ecosystem repo
SCRIPTS="$HOME/Documents/claude-skills-ecosystem/scripts"
echo "analyzer:$([ -f $SCRIPTS/code-analyzer.sh ] && echo OK || echo MISSING)"
echo "hook:$([ -f $SCRIPTS/claude-hook-analyze.sh ] && echo OK || echo MISSING)"
echo "hook-active:$(grep -q 'claude-hook-analyze\|codex-audit\|claude-skills-ecosystem' ~/.claude/settings.json 2>/dev/null && echo OK || echo MISSING)"
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
- **macOS:** `brew install semgrep sonar-scanner && npm install -g snyk eslint typescript`
- **Windows:** `pip install semgrep && npm install -g snyk eslint typescript` (sonar-scanner: download from sonarsource.com)

## Step 6b: Verify global CLAUDE.md sync

The global CLAUDE.md is git-backed via company-brain. A bidirectional sync runs every 5 min via cron.

```bash
[[ "$OSTYPE" == "darwin"* ]] && export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
echo "canonical:$([ -f $HOME/Documents/company-brain/claude-config/global-claude.md ] && echo OK || echo MISSING)"
echo "sync-script:$([ -x $HOME/Documents/company-brain/scripts/sync-global-claude.sh ] && echo OK || echo MISSING)"
echo "cron-active:$(crontab -l 2>/dev/null | grep -q 'sync-global-claude' && echo OK || echo MISSING)"
# Check if live and canonical are in sync
if [ -f "$HOME/Documents/company-brain/claude-config/global-claude.md" ]; then
  diff -q "$HOME/.claude/CLAUDE.md" "$HOME/Documents/company-brain/claude-config/global-claude.md" >/dev/null 2>&1 && echo "sync-status:IN_SYNC" || echo "sync-status:DIVERGED"
fi
```

**If canonical is MISSING:** Seed it from live:
```bash
mkdir -p ~/Documents/company-brain/claude-config
cp ~/.claude/CLAUDE.md ~/Documents/company-brain/claude-config/global-claude.md
```

**If sync-script is MISSING:** The script should exist at `~/Documents/company-brain/scripts/sync-global-claude.sh`. Pull company-brain: `cd ~/Documents/company-brain && git pull`

**If cron-active is MISSING:** Register it:
```bash
(crontab -l 2>/dev/null | grep -v "sync-global-claude"; echo "*/5 * * * * $HOME/Documents/company-brain/scripts/sync-global-claude.sh") | crontab -
```

**If sync-status is DIVERGED:** Run the sync now to resolve:
```bash
bash ~/Documents/company-brain/scripts/sync-global-claude.sh
```

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
