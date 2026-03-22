---
name: code-review
description: Use when completing tasks, implementing major features, before merging to verify work meets requirements, OR when receiving code review feedback — covers both requesting reviews and handling feedback with technical rigor
origin: ECC
---

# Code Review (Request & Receive)

## Part 1: Requesting Code Review

Dispatch superpowers:code-reviewer subagent to catch issues before they cascade.

### When to Request

**Mandatory:** After each task in subagent-driven development, after completing major feature, before merge to main.
**Optional:** When stuck, before refactoring, after fixing complex bug.

### How to Request

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

Dispatch code-reviewer subagent with:
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` / `{HEAD_SHA}` - Commit range
- `{DESCRIPTION}` - Brief summary

### Acting on Feedback
- Fix **Critical** issues immediately
- Fix **Important** issues before proceeding
- Note **Minor** issues for later
- Push back if reviewer is wrong (with reasoning)

### Integration with Workflows
- **Subagent-Driven:** Review after EACH task
- **Executing Plans:** Review after each batch (3 tasks)
- **Ad-Hoc:** Review before merge

---

## Part 2: Receiving Code Review

**Core principle:** Verify before implementing. Technical correctness over social comfort.

### The Response Pattern

1. **READ** - Complete feedback without reacting
2. **UNDERSTAND** - Restate requirement in own words (or ask)
3. **VERIFY** - Check against codebase reality
4. **EVALUATE** - Technically sound for THIS codebase?
5. **RESPOND** - Technical acknowledgment or reasoned pushback
6. **IMPLEMENT** - One item at a time, test each

### Forbidden Responses

**NEVER:** "You're absolutely right!", "Great point!", "Let me implement that now" (before verification)
**INSTEAD:** Restate the technical requirement, ask clarifying questions, push back with reasoning, or just start working.

### Handling Unclear Feedback

If ANY item is unclear: STOP. Do not implement anything yet. Ask for clarification on ALL unclear items first.

### Source-Specific Handling

**From your human partner:** Trusted — implement after understanding. Still ask if scope unclear. No performative agreement.

**From external reviewers:**
1. Technically correct for THIS codebase?
2. Breaks existing functionality?
3. Reason for current implementation?
4. Works on all platforms/versions?
5. Does reviewer understand full context?

If suggestion seems wrong → push back with technical reasoning.
If conflicts with partner's prior decisions → stop and discuss with partner first.

### YAGNI Check
If reviewer suggests "implementing properly": grep codebase for actual usage. If unused → "This isn't called. Remove it (YAGNI)?"

### Implementation Order (multi-item)
1. Clarify anything unclear FIRST
2. Blocking issues → Simple fixes → Complex fixes
3. Test each fix individually
4. Verify no regressions

### When to Push Back
- Breaks existing functionality
- Reviewer lacks full context
- Violates YAGNI
- Technically incorrect for this stack
- Conflicts with architectural decisions

### Acknowledging Correct Feedback
```
✅ "Fixed. [Brief description]"
✅ "Good catch - [issue]. Fixed in [location]."
✅ [Just fix it and show in the code]
❌ Any gratitude expressions or performative agreement
```

### GitHub Thread Replies
Reply in comment threads (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not top-level.

See template at: requesting-code-review/code-reviewer.md
