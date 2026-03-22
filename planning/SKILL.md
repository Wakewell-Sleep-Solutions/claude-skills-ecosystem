---
name: planning
description: "Turn objectives into step-by-step implementation plans for multi-session engineering projects. Use when user requests a plan, blueprint, roadmap, or implementation strategy for a multi-step task, or has a spec/requirements before touching code. Includes adversarial review gate, dependency graph, parallel step detection, and cold-start execution briefs. TRIGGER when: user says 'plan', 'blueprint', 'roadmap', 'implementation plan', 'break this down', or describes work needing multiple sessions/PRs. DO NOT TRIGGER when: task completable in a single PR or fewer than 3 tool calls."
---

# Planning

Write comprehensive implementation plans and multi-session blueprints.

## When to Use

- Breaking a large feature into multiple PRs with dependency order
- Planning a refactor or migration spanning multiple sessions
- Coordinating parallel workstreams across sub-agents
- User has a spec/requirements before touching code
- Any task where context loss between sessions would cause rework

**Do not use** for tasks completable in a single PR or when user says "just do it."

## The Pipeline

1. **Research** — Pre-flight checks, read project structure, existing plans, memory files
2. **Design** — Break objective into one-PR-sized steps (3-12 typical). Assign dependencies, parallel/serial ordering, model tier, rollback strategy
3. **Draft** — Write self-contained Markdown plan. Every step includes context brief, task list, verification commands, exit criteria
4. **Review** — Adversarial review against anti-pattern catalog. Fix all critical findings
5. **Register** — Save plan, update memory index, present to user

## Plan Document Format

```markdown
# [Feature] Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]
---

### Task N: [Component Name]
**Files:** Create: `path/file.py` | Modify: `path/existing.py:123-145` | Test: `tests/test.py`

- [ ] **Step 1: Write failing test** [code block]
- [ ] **Step 2: Run test to verify failure** [exact command + expected output]
- [ ] **Step 3: Write minimal implementation** [code block]
- [ ] **Step 4: Run test to verify pass** [exact command]
- [ ] **Step 5: Commit** [exact git command]
```

## Task Granularity

Each step is one action (2-5 minutes):
- "Write the failing test" — step
- "Run it to verify failure" — step
- "Implement minimal code to pass" — step
- "Run tests, verify pass" — step
- "Commit" — step

## Key Features

- **Cold-start execution** — Every step includes self-contained context brief. No prior context needed.
- **Adversarial review gate** — Plan reviewed against checklist: completeness, dependency correctness, anti-patterns
- **Parallel step detection** — Dependency graph identifies steps with no shared files
- **Plan mutation protocol** — Steps can be split, inserted, skipped, reordered with audit trail
- **Scope check** — If spec covers multiple independent subsystems, suggest separate plans

## Plan Review Loop

After each chunk: dispatch reviewer subagent → fix issues → re-review → until approved. Cap at 5 iterations, then escalate to human.

## Execution Handoff

After saving plan: "Plan complete. Ready to execute?"

- **With subagents:** Use superpowers:subagent-driven-development (standard approach)
- **Without subagents:** Use superpowers:executing-plans (batch with checkpoints)

## Remember

- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
- Save to `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
