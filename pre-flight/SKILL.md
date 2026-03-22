---
name: pre-flight
description: "Auto-loads relevant context before any task to prevent context drift and repeated mistakes. Scans memory files, design intent docs, project constraints, and prior retro lessons. Use at the start of any non-trivial task, when resuming work from a prior session, or when user says 'load context', 'pre-flight', 'what do we know', 'check memory', 'where did we leave off', 'catch me up', 'refresh context', 'what was decided', or 'what are the constraints'. Should auto-trigger when starting significant implementation work."
origin: ECC
---

# Pre-Flight: Context Loading Protocol

Before starting any non-trivial task, load the relevant context so you don't repeat work, violate constraints, or drift from original intent.

## When to Run Pre-Flight

| Trigger | Action |
|---------|--------|
| Starting a new feature or task | Full pre-flight |
| Resuming work from a previous session | Full pre-flight |
| User says "load context" or "pre-flight" | Full pre-flight |
| Simple question or trivial fix | Skip (don't over-process) |

## The Pre-Flight Checklist

### 1. Scan Memory Files
Look for relevant memory in these locations (in order):

```
~/.claude/projects/[current-project]/memory/   # Project-specific memory (retro writes here)
~/.claude/memory/                               # Cross-project memory (claude-mem)
memory/                                         # Project-root memory (retro lessons land here)
.planning/                                      # GSD project planning docs
.team/brief.md                                  # Active team task context
```

**Search strategy:** Grep memory files for keywords related to the current task. Look for:
- Design intent files (`*_design_intent.md`, `*_principles.md`)
- Lesson files (`*_lessons.md`) — written by retro skill after previous tasks
- Security rules, constraints, things to avoid
- Previous decisions about similar work
- Known gotchas or bugs related to this area

### 2. Load Design Intent (If Exists)
If a `memory/[project]_design_intent.md` exists, read it. This contains the WHY behind the project — the original purpose, principles, and non-negotiable constraints.

**Surface to the user:** "I found design intent for [project]. Key constraints: [list]. Should I proceed within these, or have things changed?"

### 3. Check Active Context
- Is there an active `.team/` workspace? Read `brief.md` for current task context.
- Is there a `.planning/` directory? Check `PROJECT.md` and current phase status.
- Is there a `CLAUDE.md` in the project root? Load project-specific instructions.

### 4. Constraint Summary
After scanning, produce a brief constraint summary:

```
PRE-FLIGHT COMPLETE:
- Project: [name]
- Design intent: [one-line summary or "none found"]
- Active constraints: [list key constraints — HIPAA, perf targets, etc.]
- Relevant memory: [list files found with 1-line summary each]
- Previous lessons: [from *_lessons.md files if any]
- Previous decisions: [any relevant past decisions about this area]
- Proceed: [ready / blocked on X]
```

**Durable output:** If running as part of the team skill pipeline, also write this summary to `.team/pre-flight.md` so agents can read it. This persists the context beyond the conversation's immediate memory.

## Integration with Other Skills

- **team skill:** Pre-flight runs BEFORE the Intent Anchor is written. Intent Anchor can reference pre-flight findings.
- **think skill:** Pre-flight provides the context that think structures reasoning around.
- **GSD:** Pre-flight reads `.planning/PROJECT.md` and phase status.
- **claude-mem:** Pre-flight reads what claude-mem has captured. They don't duplicate — pre-flight reads, claude-mem writes.

## Rules

1. **Don't overload context.** Only load what's relevant to THIS task. Reading every memory file wastes tokens.
2. **Surface conflicts.** If memory says one thing but the user is asking for something different, flag it. Don't silently override.
3. **Fast by default.** Pre-flight should take seconds, not minutes. Scan file names first, only read files that match.
4. **Skip for trivial tasks.** "Fix this typo" doesn't need pre-flight. Match effort to complexity (Principle 6).

## Related Skills
- **retro:** Captures lessons that pre-flight loads in future sessions
- **team:** Pre-flight runs BEFORE team dispatch to load context
- **think:** For reasoning through loaded context before acting
- **continuous-learning-v2:** Instincts loaded alongside memory files
