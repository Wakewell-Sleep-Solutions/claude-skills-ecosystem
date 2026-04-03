# Shared Rules

## Org
- **GitHub:** Wakewell-Sleep-Solutions | **Companies:** 5D Smiles + WakeWell — Downey, CA
- **Ship fast.** Maximize parallelism: worktrees, 5+ instances, `run_in_background: true`. One task per instance.
- **Bootstrap:** At session start, run `~/Documents/claude-skills-ecosystem/scripts/bootstrap-claude.md`. If missing: `gh repo clone Wakewell-Sleep-Solutions/claude-skills-ecosystem ~/Documents/claude-skills-ecosystem`

## Principles
- Elon's 5 steps: Question requirements → Delete → Simplify → Accelerate → Automate
- Invert the problem (Munger). One-shot it. Push back if a request will cause problems.
- **Search before building.** Before designing any solution involving concurrency, unfamiliar patterns, or infrastructure: (1) search for built-ins, (2) search best practices for current year, (3) check official docs. Three knowledge layers: Layer 1 (tried-and-true) — battle-tested patterns in wide distribution. Layer 2 (new-and-popular) — current best practices, but scrutinize rather than accept uncritically. Layer 3 (first-principles) — original observations specific to the problem. Prize Layer 3 above all — superior projects recognize when conventional wisdom is wrong.

## Boil the Lake — Completeness Principle
- AI has made completeness nearly free. When the complete implementation costs minutes more than the shortcut — do the complete thing. Every time.
- **Lake** (boilable — do it): 100% test coverage for a module, full feature implementation, all edge cases, complete error paths.
- **Ocean** (not boilable — flag it): System rewrites, multi-quarter platform migrations, adding features to dependencies you don't control.
- Choosing the 90% solution when the complete version adds only 70 lines? Those 70 lines cost seconds with AI. Always choose 100%.
- Testing is the cheapest completeness to add — never defer tests to a follow-up PR.
- Incompleteness is now a choice, not a constraint.

## Effort Compression
- AI compression ratios: boilerplate ~100x, tests ~50x, features ~30x, bug fix + regression ~20x, architecture ~5x, research ~3x.
- Never skip tests, types, error handling, or edge cases to "save time." The last 10% of completeness that teams used to skip costs seconds now.

## User Sovereignty
- AI recommends. Users decide. This overrides all other rules.
- When you and a subagent agree on something that changes the user's stated direction — present the recommendation, explain why, state what context you might be missing, and ask. Never act unilaterally.
- Users possess context models lack: domain knowledge, business relationships, strategic timing, personal taste, undisclosed future plans.

## Secrets — Infisical + Azure Key Vault (NO EXCEPTIONS)
- **Local dev / CI:** ALL secrets live in Infisical. Access via `process.env.KEY_NAME` injected by `irun <command>`.
- **Production / Azure-hosted services:** Secrets live in Azure Key Vault. Access via `az keyvault secret show` or Azure SDK's `DefaultAzureCredential`. Reference in app config with Key Vault references, not hardcoded values.
- NEVER create `.env` files. NEVER hardcode, print, log, or expose any secret. NEVER accept a pasted key.
- NEVER suggest environment variables, dotenv, or any other secret management approach. Infisical + Azure Key Vault are the only answers.
- If code needs a secret locally: wrap the run command with `irun`. Example: `irun npm run dev`, `irun node server.js`.
- If code needs a secret in production: use Azure Key Vault references in App Service/Function config, or `DefaultAzureCredential` in code.
- Missing key? → "This needs a secret. For local dev: check Infisical `/shared` or `/production` and re-run with `irun`. For Azure: check Key Vault via `az keyvault secret list --vault-name <vault>`."
- When writing new code that needs secrets: use `process.env.KEY_NAME` and document which Infisical path AND which Azure Key Vault it expects in a comment.

## HIPAA
- NEVER put PHI in code/comments/prompts/logs. NEVER build PHI-handling without compliance review.

## Don't
- Cloud is Azure exclusively. Use `az` CLI. Never suggest AWS/GCP alternatives.

## Company Brain — Obsidian Vault
- **Location:** `~/Documents/company-brain/` — Obsidian vault, git-backed.
- **Sync:** Instant on every Write/Edit (PostToolUse hook), periodic every 10 min (cron safety net), and PostSession. All parallel sessions see each other's knowledge within seconds.
- **Search first:** Before making any architectural decision, designing a new system, or choosing a pattern — search the vault via `obsidian` MCP for prior decisions, lessons, and context. This is Layer 0 of "Search before building."
- **Check decisions:** Before making a decision that affects more than today's task, search `decisions/` for prior decisions in that area. Follow them unless new information invalidates the reasoning.
- **Write when you learn:** When you discover something a FUTURE session would need (infra details, API patterns, business context, vendor info, bugs, decisions made) — write it to the vault.
- **Where to write:** Match the vault structure: `org/`, `systems/`, `projects/<name>/`, `operations/`, `lessons/`, `decisions/`.
- **Decision journal:** For significant decisions, write to `decisions/YYYY-MM-DD-{topic}.md` with: what you decided, context, alternatives considered, reasoning, trade-offs accepted, and what prior decision it supersedes (if any).
- **Rule:** If you save to per-project memory AND it's org-wide useful, ALSO write to company-brain.

## Platform-Agnostic Design
- NEVER hardcode framework-specific commands, file patterns, or directory structures in reusable code or scripts.
- Instead: (1) Read the project's CLAUDE.md for project-specific config (test commands, build commands, deploy commands). (2) If missing, ask the user. (3) Persist the answer to CLAUDE.md so we never have to ask again.
- The project owns its config; shared tools read it.

## Testing
- Run tests before every commit — fast, free, non-negotiable.
- Run full test suite before shipping — paid evals, E2E, integration.
- Both must pass before creating a PR.

## Commit Style
- **Always bisect commits.** Every commit = one logical change. Each commit independently understandable and revertable.
- When staging files, use specific filenames (`git add file1 file2`) — never `git add .` or `git add -A`.
- Examples of good bisection:
  - Rename/move separate from behavior changes
  - Test infrastructure separate from test implementations
  - Mechanical refactors separate from new features
  - Cleanup commits separate from feature commits

## Blame Protocol
- When a test or build fails, **never claim "not related to our changes" without proving it.**
- Required before attributing a failure to "pre-existing": (1) Run the same test on main and show it fails there too. (2) If it passes on main but fails on the branch — it IS your change. Trace the blame. (3) If you can't run on main, say "unverified — may or may not be related" and flag it as a risk.
- "Pre-existing" without receipts is a lazy claim. Prove it or don't say it.

## Long-Running Tasks
- When running tests, builds, deploys, or any long-running task — **poll until completion**. Use `sleep 180 && echo "ready"` + check in a loop every 3 minutes. Never switch to blocking mode and give up when the poll times out. Never say "I'll be notified when it completes" and stop checking — keep the loop going until the task finishes or the user tells you to stop.
- Report progress at each check (which tests passed, which are running, any failures so far). The user wants to see the run complete, not a promise that you'll check later.

## Self-Improvement
- Cross-project corrections → add rule here AND `~/Documents/company-brain/lessons/`. If stuck, stop and re-plan.
- When Claude does something wrong, add it to this file so it doesn't repeat. Compounding engineering — each correction becomes permanent context.

## Closed-Loop Security Audit Pipeline
After any swarm completes work or any multi-file task (>3 files changed), run this pipeline automatically. Each wave must pass before the next starts. Any fix from a later wave reruns all prior waves.

### Automatic Hook Loop (every Write/Edit — always active)
A PostToolUse hook (`~/Documents/scripts/claude-hook-analyze.sh`) fires on every code file Write/Edit:
1. ESLint → code quality errors
2. Semgrep (auto rules) → security vulnerabilities
3. HIPAA regex check → PHI in logs/comments
4. Secrets regex check → hardcoded credentials
Findings are reported back to you automatically. Fix them immediately, which triggers the hook again. Loop until clean. The hook always exits 0 (non-blocking) — it reports, you fix.

### Continuous Compliance (Vanta MCP — always active)
Vanta is not just a pre-ship gate — it is a continuous development companion:
- **On session start:** Check `tests` for any currently failing controls. Fix or flag before writing new code.
- **When touching auth, encryption, logging, access control, or data handling:** Query `list_framework_controls` for SOC 2 and HIPAA to understand which controls your changes affect. Design with compliance in mind, not as an afterthought.
- **When adding new endpoints, services, or data flows:** Check `risks` and `vulnerabilities` for the area you're extending. New surface area = new compliance risk.
- **When adding dependencies:** Check `vulnerabilities` filtered by integration to ensure new packages don't introduce CVEs that affect compliance posture.
- **Goal:** Ship code that is compliant by construction, not compliant by remediation. Build alongside HIPAA and SOC 2 — don't bolt them on after.

### Wave 1 — Instant Feedback (blocking, <30s)
- `npx tsc --noEmit` — type-check (catches 80% of issues immediately)
- `npx eslint . --quiet` — lint (if configured)
- `npm test` — unit/integration tests
- Fix ALL errors before proceeding. Do not report partial success.

### Wave 2 — SAST & Custom Rules (parallel, blocking)
- `npx semgrep --config auto .` — fast SAST scan with auto-detected rules
- `npx semgrep --config p/hipaa .` — HIPAA-specific rules (PHI in logs, unencrypted PII, missing audit trails)
- `npx semgrep --config p/secrets .` — secret detection (API keys, tokens, credentials in code)
- Custom Semgrep rules for our org: no `.env` files, no hardcoded Azure connection strings, no PHI field names in logging, Infisical/Key Vault patterns enforced
- If any secrets or PHI found — fix immediately, do not ask. This is never optional.

### Wave 3 — Supply Chain & Deep Analysis (parallel)
- `npx snyk test` — dependency vulnerability scan (CVEs, license issues)
- `npx snyk code test` — Snyk code analysis (data flow, taint tracking)
- `npm audit --audit-level=moderate` — npm native audit as backup
- Flag any dependency with a known CVE. If a patch version exists, upgrade it. If no patch, flag for user decision with severity and exploit risk.

### Wave 4 — Quality Gates & Architecture (parallel agents)
- SonarQube analysis (if configured): `sonar-scanner` — code smells, cognitive complexity, duplication, security hotspots. Quality gate must pass.
- Spawn an architecture agent: review all changed files for pattern consistency, state duplication, dead code, coupling. Ask: "What would a senior dev reject in code review?"
- Spawn a completeness agent: missing error handling, untested edge cases, missing types. Apply Boil the Lake — if the complete version adds <100 lines, do it.
- Spawn a "does this need to exist?" agent: challenge changes against Elon Step 1. Flag code that duplicates existing functionality.

### Wave 5 — Compliance Verification (Vanta MCP)
- Query Vanta via MCP for current compliance posture: `tests` tool to check for failing controls related to changed code areas.
- Cross-reference changes against active frameworks (SOC 2, HIPAA): `list_framework_controls` → `list_control_tests` for any control our changes touch.
- If changes affect auth, encryption, logging, access control, or data handling — verify the relevant Vanta controls still pass.
- Check `vulnerabilities` for any new findings that correlate with our changes.
- If a Vanta control is failing or at risk due to our changes — fix it or escalate with the specific control ID, framework, and remediation guidance.

### Wave 6 — Closed Loop
- All fixes from Waves 2-5 rerun Wave 1 (type-check + lint + test).
- If Wave 1 passes, rerun Semgrep on changed files only (`--include` flag) to confirm fixes didn't introduce new issues.
- Recheck any Vanta controls that were failing in Wave 5 to confirm remediation.
- Report a final summary: findings by severity, what was auto-fixed, what needs user decision, pass/fail per tool, and Vanta compliance status.
- If any CRITICAL or HIGH severity finding remains unfixed — do NOT report task as complete. Escalate to user.

## Agent Directives: Mechanical Overrides

### Pre-Work
1. **Step 0 Rule:** Dead code accelerates context compaction. Before ANY structural refactor on a file >300 LOC, first remove all dead props, unused exports, unused imports, and debug logs. Commit this cleanup separately before starting the real work.
2. **Phased Execution:** Never attempt multi-file refactors in a single response. Break work into explicit phases. Complete Phase 1, run verification, and wait for explicit approval before Phase 2. Each phase must touch no more than 5 files.

### Code Quality
3. **Senior Dev Override:** If architecture is flawed, state is duplicated, or patterns are inconsistent — propose and implement structural fixes. Ask: "What would a senior, experienced, perfectionist dev reject in code review?" Fix all of it.
4. **Forced Verification:** FORBIDDEN from reporting a task as complete until you have run `npx tsc --noEmit` (or project equivalent type-check) and `npx eslint . --quiet` (if configured) and fixed ALL resulting errors. If no type-checker is configured, state that explicitly.

### Context Management
5. **Sub-Agent Swarming:** For tasks touching >5 independent files, MUST launch parallel sub-agents (5-8 files per agent). Each agent gets its own context window. Sequential processing of large tasks guarantees context decay.
6. **Context Decay Awareness:** After 10+ messages in a conversation, MUST re-read any file before editing it. Do not trust memory of file contents — auto-compaction may have silently destroyed that context.
7. **File Read Budget:** Each file read is capped at 2,000 lines. For files over 500 LOC, MUST use offset and limit parameters to read in sequential chunks. Never assume you have seen a complete file from a single read.
8. **Tool Result Blindness:** Tool results over 50,000 characters are silently truncated to a 2,000-byte preview. If any search or command returns suspiciously few results, re-run with narrower scope. State when you suspect truncation occurred.

### Edit Safety
9. **Edit Integrity:** Before EVERY file edit, re-read the file. After editing, read it again to confirm the change applied correctly. The Edit tool fails silently when old_string doesn't match due to stale context. Never batch more than 3 edits to the same file without a verification read.
10. **No Semantic Search:** You have grep, not an AST. When renaming or changing any function/type/variable, MUST search separately for: direct calls and references, type-level references (interfaces, generics), string literals containing the name, dynamic imports and require() calls, re-exports and barrel file entries, test files and mocks. Do not assume a single grep caught everything.
