---
name: using-superpowers
description: Use when starting any conversation - establishes how to find and use skills, requiring Skill tool invocation before ANY response including clarifying questions
origin: ECC
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a specific task, skip this skill.
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction Priority

Superpowers skills override default system prompt behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (CLAUDE.md, GEMINI.md, AGENTS.md, direct requests) — highest priority
2. **Superpowers skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If CLAUDE.md, GEMINI.md, or AGENTS.md says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to Access Skills

**In Claude Code:** Use the `Skill` tool. When you invoke a skill, its content is loaded and presented to you—follow it directly. Never use the Read tool on skill files.

**In Gemini CLI:** Skills activate via the `activate_skill` tool. Gemini loads skill metadata at session start and activates the full content on demand.

**In other environments:** Check your platform's documentation for how skills are loaded.

## Platform Adaptation

Skills use Claude Code tool names. Non-CC platforms: see `references/codex-tools.md` (Codex) for tool equivalents. Gemini CLI users get the tool mapping loaded automatically via GEMINI.md.

# Using Skills

## The Rule

**Invoke relevant or requested skills BEFORE any response or action.** Even a 1% chance a skill might apply means that you should invoke the skill to check. If an invoked skill turns out to be wrong for the situation, you don't need to use it.

```dot
digraph skill_flow {
    "User message received" [shape=doublecircle];
    "About to EnterPlanMode?" [shape=doublecircle];
    "Already brainstormed?" [shape=diamond];
    "Invoke brainstorming skill" [shape=box];
    "Might any skill apply?" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce: 'Using [skill] to [purpose]'" [shape=box];
    "Has checklist?" [shape=diamond];
    "Create TodoWrite todo per item" [shape=box];
    "Follow skill exactly" [shape=box];
    "Respond (including clarifications)" [shape=doublecircle];

    "About to EnterPlanMode?" -> "Already brainstormed?";
    "Already brainstormed?" -> "Invoke brainstorming skill" [label="no"];
    "Already brainstormed?" -> "Might any skill apply?" [label="yes"];
    "Invoke brainstorming skill" -> "Might any skill apply?";

    "User message received" -> "Might any skill apply?";
    "Might any skill apply?" -> "Invoke Skill tool" [label="yes, even 1%"];
    "Might any skill apply?" -> "Respond (including clarifications)" [label="definitely not"];
    "Invoke Skill tool" -> "Announce: 'Using [skill] to [purpose]'";
    "Announce: 'Using [skill] to [purpose]'" -> "Has checklist?";
    "Has checklist?" -> "Create TodoWrite todo per item" [label="yes"];
    "Has checklist?" -> "Follow skill exactly" [label="no"];
    "Create TodoWrite todo per item" -> "Follow skill exactly";
}
```

## Red Flag

**If you're about to do something WITHOUT checking for a matching skill first, STOP.** Any rationalization ("it's simple", "I'll be quick", "I know this") is a signal to check skills. No exceptions.

## Skill Priority

When multiple skills could apply, use this order:

1. **Context skills first** (pre-flight) — load relevant memory and constraints before anything
2. **Reasoning skills second** (think, brainstorming, debugging) — structure HOW to approach
3. **Orchestration skills third** (team, dispatching-parallel-agents) — multi-model when needed
4. **Implementation skills fourth** (frontend-design, software-architecture, owasp-security) — domain execution
5. **Completion skills last** (retro, verification-before-completion, requesting-code-review) — capture lessons

### The Cognitive Pipeline

For non-trivial tasks, skills chain in this order:
```
pre-flight → think/brainstorming → team (if complex) → [implementation skills] → retro
```

### Key Routing Rules

| Trigger | Skill | NOT |
|---------|-------|-----|
| "think", "ultrathink", "analyze", "reason through" | **think** | team (no agents needed) |
| "team", "agents", "swarm", "codex in the loop" | **team** | think (needs multi-model) |
| "ralph team", "autonomous team", "team loop" | **ralph-team** | team (needs autonomous iteration) |
| Starting any non-trivial task | **pre-flight** | Skip for typos/trivial |
| After completing significant work | **retro** | Skip for trivial |
| "HIPAA", "PHI", "patient data", healthcare code | **hipaa-compliance** | General security |
| Security review, auth code, user input handling | **owasp-security** | hipaa (unless healthcare) |
| "architecture", "system design", "SOLID", "refactor" | **software-architecture** | General coding |
| "SEO" (any kind) | **seo-orchestrator** (routes to sub-skills) | Individual seo-* skills directly |
| Bugfix sequence | **systematic-debugging** first → **test-driven-development** for the fix | TDD alone |

"Let's build X" → pre-flight → brainstorming → implementation skills.
"Fix this bug" → pre-flight → debugging → TDD for the fix.
"Think deeply about X" → pre-flight → think.
"Team up on X" → pre-flight → team (which auto-runs retro at end).

## Skill Types

**Rigid** (TDD, debugging): Follow exactly. Don't adapt away discipline.

**Flexible** (patterns): Adapt principles to context.

The skill itself tells you which.

## User Instructions

Instructions say WHAT, not HOW. "Add X" or "Fix Y" doesn't mean skip workflows.
