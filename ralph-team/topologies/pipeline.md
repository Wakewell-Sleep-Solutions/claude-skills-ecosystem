# Pipeline Topology (Builder-Auditor)

**Axes:** star + audit + iterative
**When:** Concrete artifact with correctness risk. Code, configs, migrations, security-sensitive changes.

## Key Research

- Maps to Anthropic's "Evaluator-Optimizer" pattern
- Maps to Google ADK's LoopAgent(Builder, Auditor)
- Builder.io's Micro Agent: write → test → iterate until green
- Martin Fowler: "Pushing AI Autonomy" — maker-checker for production code

## Protocol

### The Lockstep Loop

```
BUILDER (Agent A) writes/modifies code
  ↓
AUDITOR (Agent B) reviews ONLY the diff
  ↓
Findings? ──YES──→ BUILDER fixes → AUDITOR re-reviews
  │                                      ↓
  NO                              Still findings? → loop (max 3)
  ↓
APPROVED → commit → next task
```

### Agent Roles

**Builder** (Claude subagent or Codex):
- Receives task spec with exact file paths
- Writes code following TDD (test first, then implement)
- Commits after each green test run
- Reports: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED

**Auditor** (different model family — Codex if Builder is Claude, or vice versa):
- Reviews ONLY the diff (not entire codebase)
- Checks: correctness, security, edge cases, spec compliance
- Reports: APPROVED | FINDINGS (with specific issues)
- Cap: 3 audit rounds max, then escalate to human

**Orchestrator** (Claude lead):
- Routes builder output to auditor
- Routes auditor findings back to builder
- Decides when to escalate vs continue
- Never builds or audits directly (separation of concerns)

### Dispatch Templates

**Builder:**
```
You are the BUILDER. Write code to implement:
TASK: [specific task from plan]
FILES: [exact paths]
CONSTRAINTS: [from Intent Anchor]
Follow TDD: test first, implement, verify green.
Report status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
```

**Auditor:**
```
You are the AUDITOR. Review this diff:
[paste diff]
Check for: correctness, security, edge cases, spec compliance.
Report: APPROVED or FINDINGS with specific issues and fix suggestions.
Do NOT rewrite the code — only identify issues.
```

### Quality Gates

- Builder must run tests before submitting for audit
- Auditor must cite specific lines/issues (no vague "looks good")
- After 3 audit rounds without approval → escalate to human
- Never skip audit for "simple" changes

## When to Use Pipeline vs Hub-Spoke

| Signal | Use Pipeline | Use Hub-Spoke |
|--------|-------------|---------------|
| Writing production code | ✅ | |
| Security-sensitive changes | ✅ | |
| Database migrations | ✅ | |
| Research synthesis | | ✅ |
| Creative content | | ✅ |
| Quick analysis | | ✅ |
