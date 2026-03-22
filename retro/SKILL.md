---
name: retro
description: "Post-task reflection that captures lessons to memory. Run after completing significant work to record what worked, what didn't, and what to do differently. Use when user says 'retro', 'retrospective', 'what did we learn', 'lessons learned', or after completing a major feature/task."
origin: ECC
---

# Retro: Post-Task Reflection

After completing significant work, capture what you learned so future sessions benefit. This is how the system gets smarter over time — not just within a session, but across sessions.

## When to Run Retro

| Trigger | Run retro? |
|---------|-----------|
| Completed a major feature | Yes |
| Fixed a tricky bug (non-obvious root cause) | Yes |
| Made a significant design decision | Yes |
| Discovered a gotcha or constraint the hard way | Yes |
| User says "retro" or "what did we learn" | Yes |
| Trivial task completed normally | No |
| Task failed / was abandoned | Yes — capture WHY it failed |

## The Retro Template

```
## Retro: [Task Name] — [Date]

### What worked
- [Specific thing that went well and WHY]

### What didn't work
- [Specific thing that failed/was slow and WHY]

### Surprises / Gotchas
- [Things we discovered that weren't obvious upfront]

### Decisions made (and reasoning)
- [Key decision]: [why we chose this over alternatives]

### For next time
- [Specific actionable lesson — not vague "do better"]
```

## Where Lessons Go

### Pattern-level lessons (reusable across projects)
Write to: `~/.claude/projects/[current-project]/memory/`
Example: "WordPress wpautop breaks CSS inside style tags — never use blank lines in style blocks"

### Project-specific lessons
Write to: `memory/[project]_lessons.md` (append, don't overwrite)
Example: "ARIA's voice UI needs 200ms debounce on speech-to-text to avoid double-triggers"

### Design intent updates
If the task changed the project's direction, principles, or constraints:
Update: `memory/[project]_design_intent.md`
Example: "Switched from REST to WebSocket for real-time updates — latency constraint added"

## Integration with Other Skills

- **claude-mem:** Claude-mem auto-captures observations. Retro adds structured LESSONS on top — the "so what" that claude-mem's raw observations don't provide.
- **team skill:** After a team task, retro captures which team formation worked, which agents added value, and which were overhead.
- **pre-flight:** Pre-flight reads what retro wrote. Retro writes, pre-flight reads. They form a learning loop.
- **GSD:** GSD phase verification is about "did we build what we planned?" Retro is about "what did we LEARN while building it?" Different questions.

## Reflection Bank (Structured Learning Tuples)

Beyond free-form retro notes, capture lessons as structured tuples that pre-flight can load mechanically:

```
## Reflection Bank
### [Project] — [Date]
- ERROR: [what went wrong — specific, not vague]
  CORRECTION: [what we did to fix it]
  PRINCIPLE: [the general rule this teaches — transferable to other projects]
  APPLIES WHEN: [trigger condition — when should future sessions check this?]
```

**Examples:**
```
- ERROR: WordPress wpautop injected <p> tags inside <style> blocks, silently breaking CSS
  CORRECTION: Removed all blank lines inside style blocks
  PRINCIPLE: Never put blank lines inside HTML elements that WordPress processes
  APPLIES WHEN: Writing any wp:html content with embedded CSS

- ERROR: Codex agent pruned 7 discoveries without showing them; 3 were HIGH value
  CORRECTION: Added multi-model consensus requirement for all pruning decisions
  PRINCIPLE: Never prune divergent research in a black box — show everything, let user decide
  APPLIES WHEN: Any divergent/research thread produces findings that might be discarded

- ERROR: Used TBT instead of INP for Core Web Vitals — metric was deprecated March 2024
  CORRECTION: Updated all references to INP with correct thresholds (200ms good, 500ms poor)
  PRINCIPLE: Verify metric currency before citing — web standards change faster than training data
  APPLIES WHEN: Referencing any web performance metric or standard version
```

**How pre-flight uses this:** At session start, pre-flight scans the reflection bank for entries where APPLIES WHEN matches the current task context. It injects matching PRINCIPLE entries into the session — preventing the same class of error from recurring.

**How retro writes this:** After every retro, check if any "What didn't work" items generalize into a transferable principle. If yes, add a tuple. If the lesson is too project-specific to transfer, skip it — not everything needs a tuple.

## Rules

1. **Be specific, not vague.** "Communication could improve" = useless. "Codex agent's security findings caught an auth bypass Claude missed" = useful.
2. **Include the WHY.** Not just what happened, but why. The why is what transfers to future tasks.
3. **Append, don't overwrite.** Lessons accumulate. A project's lesson file should grow over time.
4. **Don't retro trivial work.** Match effort to significance (Principle 6).
5. **Capture failures.** Failed approaches are often MORE valuable than successes — they prevent repeating mistakes.

## Related Skills
- **pre-flight:** Reads retro lessons in future sessions
- **continuous-learning-v2:** Mid-session learning complements end-of-task retro
- **team:** Retro captures which agents/models added most value
- **ralph-team:** Retro required before declaring convergence
