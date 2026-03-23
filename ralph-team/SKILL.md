---
name: ralph-team
description: "Multi-model autonomous orchestration: Claude + Codex + Gemini work independently then converge. 5 topologies: hub-spoke, socratic, pipeline (builder-auditor), mesh (parallel workers), adversarial (decisions). Also handles simple parallel agent dispatch and subagent-driven plan execution. ALWAYS use this skill (not agent-orchestration) for: 'ralph team', '/ralph-team', 'team', 'agents', 'dispatch agents', 'parallel agents', 'subagents', 'swarm', 'codex in the loop', 'autonomous team', 'loop team', 'iterate until done', 'run autonomously', 'hands-off mode', 'auto-improve this', 'let the agents work on it', 'execute this plan', 'run tasks in parallel', or any multi-agent or multi-model request."
---

# Ralph Team: Multi-Model Orchestration

Claude leads. Codex + Gemini work independently. Results converge. Topology adapts to the task.

## Core Principles

1. **NEVER STOP. NEVER ASK.** Make your best judgment and keep working. The user will `/cancel-ralph` if needed.
2. **Completion = project done**, not "convergence" or "no new findings." If there's more work to discover, discover it.
3. **Every iteration: DO work + FIND next work.** Don't just check off a list — actively search for what else needs doing.
4. **Independent-then-merge** beats real-time debate (Mullen et al., 800+ teams)
5. **Single-shot with accumulated context** beats multi-turn (39% performance drop, arXiv:2505.06120)
6. **Diverse reasoning strategies** beat FOR/AGAINST framing (framing bias, Science Advances 2025)

## Quick Start

1. Transform task → write `.team/brief.md` (Intent Anchor)
2. Initialize `.team/loop-state.md`
3. **Start the autonomous loop** via ralph-loop plugin:
   ```
   Skill: ralph-loop:ralph-loop
   ```
   With args: `"[TASK PROMPT] --max-iterations 8 --completion-promise TEAM COMPLETE"`
4. The Stop hook keeps you iterating — you never stop until convergence
5. Each iteration: select topology → dispatch agents → fix findings → update state
6. When converged → output `<promise>TEAM COMPLETE</promise>` to exit

## Autonomous Loop Behavior — KEEP GOING

**DEFAULT IS: KEEP WORKING.** You stop ONLY when the project is genuinely complete.

When the ralph-loop plugin is active:
- **You will NOT stop** between iterations — the Stop hook re-injects your task
- **NEVER ask the user questions** — make your best judgment and act. If unsure, pick the best option and note why.
- **NEVER declare completion early** — if you can think of ONE more thing to improve, do it
- **Each iteration sees previous work** in files, `.team/shared/`, and git history
- **Safety cap**: max iterations (default 8) — set higher for big projects
- **Emergency stop**: User can run `/cancel-ralph` at any time

### Iteration Lifecycle (Autonomous)
```
PHASE 1 — DO WORK (60% of iteration)
  1. Read .team/loop-state.md → what's in REMAINING?
  2. Pick the highest-impact item
  3. Auto-select topology, dispatch agents, execute
  4. Fix findings, write code, create content — whatever the task requires
  5. Mark completed items as DONE

PHASE 2 — DISCOVER NEXT WORK (40% of iteration)
  6. Dispatch a discovery agent: "Given what we've done so far, what else needs doing?"
  7. Review the project holistically — gaps, quality issues, missing pieces
  8. Add new items to REMAINING in loop-state.md
  9. If Codex/Gemini found issues, add those too

PHASE 3 — CONTINUE OR COMPLETE
  10. Is REMAINING empty AND discovery found nothing new? → COMPLETE
  11. Otherwise → just finish your response (hook re-engages you)
```

### The Discovery Agent (Phase 2)
Every iteration, dispatch a Claude subagent with this prompt:
```
Review the project state. What has been done (DONE list) and what remains (REMAINING).
Your job: find work that HASN'T been identified yet.
Look for: missing features, quality gaps, untested paths, unfinished edges,
documentation needs, integration issues, things that would make this BETTER.
Output: a list of new items to add to REMAINING, or "NOTHING_NEW" if genuinely done.
```
This is what keeps the loop going — it actively searches for more work instead of looking for reasons to stop.

## Intent Anchor (`.team/brief.md`)

```
## Intent Anchor
WHAT: [one sentence]
WHY: [one sentence]
SUCCESS: [how we know it worked]
CONSTRAINTS: [non-negotiable boundaries]
ANTI-GOALS: [what we are NOT doing]
TOPOLOGY: [auto | hub-spoke | socratic | pipeline | mesh | adversarial]
DOMAIN: [research | coding | seo | decision | mixed]
```

## Topology Selection

### The 3-Axis Algebra

All topologies derive from 3 orthogonal axes:

| Axis | Options | Controls |
|------|---------|----------|
| **Graph** | `star` \| `mesh` | How agents connect |
| **Review** | `none` \| `audit` \| `debate` | How output is challenged |
| **Convergence** | `single_pass` \| `iterative` | How many rounds |

### 5 Presets

| Preset | Axes | When to Use |
|--------|------|-------------|
| **hub-spoke** | star + none + single_pass | Default. Standard dispatch + synthesize |
| **socratic** | star + none + iterative | High uncertainty. Question must evolve over rounds |
| **pipeline** | star + audit + iterative | Concrete artifact with correctness risk. Builder + auditor lockstep |
| **mesh** | mesh + none + single_pass | N independent items to process in parallel |
| **adversarial** | star + debate + single_pass | High-stakes decisions needing genuine opposition |

### Auto-Selection Heuristic

```
Has a concrete artifact to build (code, page, doc)?
├── YES → Is correctness critical?
│   ├── YES → PIPELINE (builder-auditor)
│   └── NO → HUB-SPOKE
└── NO → Is it a decision between alternatives?
    ├── YES → Is the decision high-stakes/irreversible?
    │   ├── YES → ADVERSARIAL
    │   └── NO → HUB-SPOKE
    └── NO → Is uncertainty high / question needs to evolve?
        ├── YES → SOCRATIC
        └── NO → Are there N independent items?
            ├── YES → MESH
            └── NO → HUB-SPOKE
```

**Topology protocols:** Read `topologies/<preset>.md` for the full execution protocol.
**Domain adapters:** Read `domains/<domain>.md` for domain-specific rubrics.

## The Three Models

| Model | Best At | Dispatch | Session Resume |
|-------|---------|----------|----------------|
| **Claude** | Reasoning, synthesis, safety | Agent tool | N/A (orchestrator) |
| **Codex** | Code gen, security audit | `codex exec --sandbox read-only` | `codex resume --last` |
| **Gemini** | 1M+ context, cross-file | `gemini -p` | `gemini --resume latest` |

Detect availability: `command -v codex >/dev/null 2>&1` / `command -v gemini >/dev/null 2>&1`
Never fail silently. Degrade gracefully. Circuit breaker: 3 consecutive failures → stop dispatching.

## Agent Tiers (Hard Limits)

| Complexity | Claude | Codex | Gemini | Total |
|-----------|--------|-------|--------|-------|
| Small | 0 | 1 | 0 | **1** |
| Medium | 1 | 1 | 0 | **2** |
| Large | 1 | 1 | 1 | **3** |
| Critical | 2 | 1 | 1 | **4** |
| Massive | 2 | 2 | 1 | **5** |

Never exceed 5 agents. Default to Tier 2 when ambiguous.

## Mandatory Dispatch Protocol

**BEFORE updating loop-state.md, you MUST have dispatched Codex AND Gemini** (or documented failure).

### Dispatch Commands

**Codex:**
```bash
codex exec --skip-git-repo-check --sandbox read-only \
  "Ultrathink. You are Codex, part of a multi-model team.
INTENT: [paste brief.md]
STATE: [paste loop-state.md]
TASK: [topology-specific task from topologies/*.md]
Output: ## Crystallized Findings (max 7)
- [Finding]: [evidence] | Risk: [X] | Confidence: [H/M/L] | Weight: [1-10]" 2>/dev/null
```

**Gemini:**
```bash
gemini -p "Ultrathink. You are Gemini, part of a multi-model team.
INTENT: [paste brief.md]
STATE: [paste loop-state.md]
TASK: [topology-specific task from topologies/*.md]
Output: ## Crystallized Findings (max 7)
- [Finding]: [evidence] | Risk: [X] | Confidence: [H/M/L] | Weight: [1-10]" 2>/dev/null
```

Save outputs to `.team/shared/codex-iteration-N.md` and `.team/shared/gemini-iteration-N.md`.

### Research-Backed Dispatch Rules

1. **NEVER assign FOR/AGAINST positions** — causes framing bias. Instead use diverse reasoning lenses:
   - Agent A: "Approach from first principles — what must be true?"
   - Agent B: "Approach from historical precedent — what has worked before?"
   - Agent C: "Approach from risk/failure analysis — what could go wrong?"

2. **NEVER do multi-turn back-and-forth** — 39% performance drop. Instead:
   - Collect all outputs from Round N
   - Pass ALL outputs as context in a single prompt for Round N+1
   - Each agent refines position considering others' arguments in one shot

3. **Cap at 3 rounds** — most value extracted in rounds 1-3. After that, diminishing returns.

## Completion Criteria (NOT Convergence)

**The question is NOT "have we converged?" — it's "is the project DONE?"**

```
Is REMAINING empty?
├── NO → Keep working. Pick highest-impact item.
└── YES → Did the discovery agent find new work?
    ├── YES → Add to REMAINING. Keep working.
    └── NO → Is the Intent Anchor's SUCCESS criteria met?
        ├── NO → What's missing? Add to REMAINING. Keep working.
        └── YES → Output <promise>TEAM COMPLETE</promise>
```

**BIAS: KEEP GOING.** When in doubt, find more work. Only stop when:
1. REMAINING is empty AND
2. Discovery agent returned NOTHING_NEW AND
3. SUCCESS criteria from Intent Anchor are genuinely met

**NEVER stop because:**
- ❌ You ran out of ideas (dispatch discovery agent)
- ❌ You want to ask the user a question (make your best judgment)
- ❌ "Good enough" (push for great)
- ❌ Iterations feel repetitive (you're probably close — push through)

## Loop State Format

```
ORIGINAL INTENT: [from brief.md]
TOPOLOGY: [selected preset]
ITERATION: [N]

## DONE (completed this session)
- [item 1 — what was done]
- [item 2 — what was done]

## REMAINING (work still needed)
- [highest impact item first]
- [next item]

## DISCOVERED THIS ITERATION (from discovery agent)
- [new work found] or NOTHING_NEW

## DISPATCH PROOF
CODEX: YES/FAILED — [file path]
GEMINI: YES/FAILED — [file path]
```

## Failure Recovery

| Failure | Response |
|---------|----------|
| Agent timeout | Log, continue with available outputs, redispatch if critical |
| Malformed output | Push back once for crystallized format, then extract what you can |
| Codex sandbox write | Expected — capture stdout directly |
| Gemini can't find files | Pipe file contents inline instead of $(cat) |
| Complete failure | Note in MODEL_FAILURES, reduce tier by 1, continue |
| Infinite loop (2+ agents same point) | Lead breaks tie with reasoning |
| Drift from intent | Challenge: "How does this serve the Intent Anchor?" |

## Session Hygiene

If `.team/` exists from previous task: archive (`mv .team .team-archive-$(date)`) or delete.

## Context Health

Do NOT prematurely handoff. Opus 4.6 has 1M context. When degradation IS observed (repeating fixed work, contradicting itself):
1. Write `.team/COMPRESSED-STATE.md`
2. Tell user: "Continue from .team/COMPRESSED-STATE.md"

## Anti-Patterns

- **🚫 STOPPING EARLY**: The #1 failure. If you can think of one more thing to do, DO IT
- **🚫 ASKING QUESTIONS**: Never. Make your best judgment. Note your reasoning. Keep going.
- **🚫 "Good enough"**: Push for great. The discovery agent exists to find what you missed.
- **🚫 Framing bias**: Never assign FOR/AGAINST — use diverse reasoning lenses
- **🚫 Multi-turn trap**: Never do back-and-forth — single-shot with accumulated context
- **🚫 Agent bloat**: More agents ≠ better. Synthesis burden grows quadratically
- **🚫 Intent drift**: Every action must trace to Intent Anchor
- **🚫 Premature synthesis**: WAIT for ALL agents. No exceptions

## Completion

Output `<promise>TEAM COMPLETE</promise>` ONLY when ALL THREE are true:
1. REMAINING list is empty
2. Discovery agent returned NOTHING_NEW
3. Intent Anchor's SUCCESS criteria are genuinely met

**If ANY of those are false → keep working. Do not output the promise.**

## Learnings (Metaswarm Pattern)

After each merge, append to `.team/learnings.jsonl`:
```jsonl
{"iteration":N,"type":"pattern|antipattern|decision","finding":"...","evidence":"...","confidence":"H/M/L"}
```

## File Structure

```
ralph-team/
  SKILL.md                    ← You are here (router + shared protocol)
  topologies/
    hub-spoke.md              ← Default dispatch + synthesize
    socratic.md               ← Iterative convergence for research
    pipeline.md               ← Builder-auditor lockstep for coding
    mesh.md                   ← Parallel workers for batch processing
    adversarial.md            ← Anonymized debate for decisions
  domains/
    research.md               ← Evidence hierarchy, citation discipline
    coding.md                 ← Repo inspection, patch/test/review
    seo.md                    ← SERP/entity/content audit rubric
    decision.md               ← Option matrix, uncertainty, reversibility
  references/
    RESEARCH.md               ← Academic citations
    divergent-template.md     ← Divergent research prompt
```
