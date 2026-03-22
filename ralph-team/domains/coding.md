# Domain Adapter: Coding

**Success rubric:** Tests pass, no security issues, clean diff, spec compliance
**Tool preferences:** Read, Edit, Write, Bash, Grep, Glob
**Artifact type:** Code commits with passing tests
**Evidence mode:** verify (run tests, check output)

## Domain-Specific Rules

- TDD: test first, implement, verify green
- Every change must have a passing test
- Security review on auth, input handling, secrets, API endpoints
- No direct commits to main without review
- Exact file paths in all instructions

## Recommended Topology: Pipeline (Builder-Auditor)

Coding tasks almost always benefit from the pipeline topology:
- Builder writes code + tests
- Auditor reviews the diff for correctness, security, edge cases
- Loop until clean audit (max 3 rounds)

## Agent Lens Assignments (if using Socratic for architecture decisions)

- **Agent A (Simplicity):** What's the simplest implementation that satisfies the spec?
- **Agent B (Robustness):** What edge cases, error paths, and failure modes exist?
- **Agent C (Security):** What's the attack surface? What could an adversary exploit?

## Builder Status Handling

| Status | Action |
|--------|--------|
| DONE | Proceed to audit |
| DONE_WITH_CONCERNS | Read concerns, address if correctness-related |
| NEEDS_CONTEXT | Provide missing info, re-dispatch |
| BLOCKED | Assess: more context? stronger model? break task? escalate? |

## Model Selection for Coding

- 1-2 files, clear spec → fast/cheap model
- Multi-file integration → standard model
- Architecture/design decisions → most capable model
