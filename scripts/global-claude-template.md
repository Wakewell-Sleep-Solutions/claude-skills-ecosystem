# Shared Rules

## Organization
- **GitHub:** Wakewell-Sleep-Solutions (org)
- **Companies:** 5D Smiles (dental implants) + WakeWell (dental sleep medicine + DOT/FMCSA sleep testing) — Downey, CA
- **Working style:** Ship fast. Don't over-discuss — build it. Maximize parallelism:
  - Use `claude --worktree <name>` for every independent task — isolated branch, no conflicts
  - Run 5+ instances locally (tmux or separate terminals), each on its own worktree
  - Use agent teams (`--teammate-mode tmux`) for coordinated parallel work
  - Spawn subagents with `run_in_background: true` for quick parallel research/review
  - One task per instance. Never context-switch — start a new instance instead.

## Principles
- **Question requirements first** — before building, ask: does this need to exist? (Elon Step 1)
- **Delete before optimizing** — remove unnecessary parts before improving what's left (Elon Step 2)
- **Simplify → Accelerate → Automate** — in that order. Automation is last, never first.
- **Invert the problem** — ask "what would destroy this?" before committing (Munger)
- **One-shot it** — think completely through the problem before acting, then execute in one pass. Iteration is expensive; getting it right the first time is the goal.
- **Adoption is THE metric** — if people don't use it, nothing else matters
- **Push back** — if a request will cause problems, say so directly. Don't agree just to be agreeable.
- **Org context first** — at session start, execute the bootstrap at `~/Documents/claude-skills-ecosystem/scripts/bootstrap-claude.md`. It syncs all repos, reads org context, checks recent changes, and orients you. If the file doesn't exist, clone it: `gh repo clone Wakewell-Sleep-Solutions/claude-skills-ecosystem ~/Documents/claude-skills-ecosystem` then read the bootstrap.

## Secrets — Infisical Only
- Use `process.env.KEY_NAME` for all secrets. Keys auto-inject via `irun <command>`.
- NEVER create, read, or suggest `.env` files.
- NEVER hardcode, print, log, or expose any secret value.
- NEVER accept a pasted key — redirect to Infisical.
- Missing key? Say: "Check Infisical `/shared` and re-run with `irun`." Do NOT workaround.

## HIPAA
- NEVER put PHI (patient names, DOBs, MRNs, SSNs) in code, comments, prompts, or logs.
- NEVER build PHI-handling without compliance review.
- Apply minimum-necessary: use or request only the least PHI needed for the task.
- Do not assume data can move freely between 5D Smiles, WakeWell, and Aria systems.

## Don't
- Don't create new n8n/GHL/Aria flows — check what exists first and extend it.
- Don't use `moment.js` — use `date-fns`.

## Session Start
At first interaction, ask: "What's your experience level? (1) Expert (2) Intermediate (3) Learning"
- **Expert**: No guardrails. Execute directly. Only stop for genuinely irreversible actions.
- **Intermediate**: Confirm before deleting files, replacing working code, or rewriting modules.
- **Learning**: Restate the plan before starting. Explain what exists before changing it. Push back on "start fresh."

## Org Projects (start Claude Code from the right directory)
| Alias | Directory | What it is |
|-------|-----------|------------|
| aria | `~/Documents/Claude/` | Aria Slack bot, org hub, n8n workflows, company docs |
| rcm | `~/Documents/super-rcm/` | Central data server — connects Open Dental, scrubs PHI, serves all other apps |
| web | `~/Documents/WakewellWeb/` | WakeWell website |
| dashboard | `~/Documents/5dsmiles-landing/` | 5D Smiles practice dashboard |
| skills | `~/Documents/claude-skills-ecosystem/` | 85+ portable Claude Code skills |
If working on files in another project, use full paths (e.g., `~/Documents/super-rcm/app/...`) — don't assume the working directory will change.

## Self-Improvement
- After a correction that applies across ALL projects: add a one-line rule to this file. Project-specific lessons go in the project CLAUDE.md.
- If something goes sideways, stop and re-plan — don't keep pushing.
