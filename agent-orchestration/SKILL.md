---
name: agent-orchestration
description: "Dispatch parallel agents for independent tasks and execute implementation plans via subagent-driven development. Use when facing 2+ independent tasks without shared state, executing plans with fresh subagents per task, or coordinating parallel workstreams. Triggers on: 'parallel agents', 'dispatch agents', 'subagents', 'independent tasks', 'parallel dispatch', 'subagent-driven', 'execute this plan', 'run tasks in parallel'."
---

# Agent Orchestration

Dispatch parallel agents for independent tasks + execute plans via subagent-driven development.

## When to Use

**Parallel Dispatch** — 3+ independent problems (different test files, different subsystems):
- Each problem can be understood without context from others
- No shared state between investigations
- Agents won't edit the same files

**Subagent-Driven Development** — Executing an implementation plan:
- Have a written plan with independent tasks
- Want fresh context per task (no pollution)
- Want two-stage review (spec compliance + code quality)

**Don't use when:** Failures are related, need full system state, agents would interfere, or task is too small.

## Parallel Dispatch Pattern

### 1. Identify Independent Domains
Group by what's broken — each domain is independent.

### 2. Create Focused Agent Prompts
Each agent gets:
- **Specific scope** — one test file or subsystem
- **Clear goal** — "make these tests pass"
- **Constraints** — "don't change other code"
- **Expected output** — "summary of root cause and changes"

### 3. Dispatch
```
Task("Fix agent-tool-abort.test.ts failures")
Task("Fix batch-completion-behavior.test.ts failures")
Task("Fix tool-approval-race-conditions.test.ts failures")
// All three run concurrently
```

### 4. Review and Integrate
- Read each summary, verify fixes don't conflict
- Run full test suite, integrate all changes

## Subagent-Driven Development

Execute plan by dispatching fresh subagent per task with two-stage review.

### Process
1. Read plan, extract all tasks with full text
2. Per task: dispatch implementer → spec review → code quality review → mark complete
3. After all tasks: final reviewer → finish branch

### Implementer Status Handling
- **DONE** → proceed to spec review
- **DONE_WITH_CONCERNS** → read concerns, address if correctness/scope related
- **NEEDS_CONTEXT** → provide missing info, re-dispatch
- **BLOCKED** → assess: more context? stronger model? break task down? escalate?

### Model Selection
- Touches 1-2 files with clear spec → fast/cheap model
- Multi-file integration → standard model
- Architecture/design/review → most capable model

## Agent Prompt Best Practices

**Good prompts are:**
1. **Focused** — one clear problem domain
2. **Self-contained** — all context needed to understand the problem
3. **Specific about output** — what should the agent return?

**Anti-patterns:**
- ❌ Too broad: "Fix all the tests"
- ✅ Specific: "Fix agent-tool-abort.test.ts"
- ❌ No context: "Fix the race condition"
- ✅ With context: paste error messages and test names
- ❌ No constraints: agent might refactor everything
- ✅ Constraints: "Do NOT change production code"

## Red Flags

- Never dispatch multiple implementation subagents editing same files
- Never skip reviews (spec compliance AND code quality)
- Never ignore subagent questions — answer before proceeding
- Never let subagent self-review replace actual review
- Start spec compliance review BEFORE code quality review
