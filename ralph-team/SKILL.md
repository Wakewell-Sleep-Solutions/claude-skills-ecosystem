---
name: ralph-team
description: "Autonomous multi-model team orchestration with flexible topologies. Claude (lead) + Codex + Gemini work independently, then converge. Supports 5 topologies: hub-spoke (default), socratic (research convergence), pipeline (builder-auditor coding), mesh (parallel workers), adversarial (decision-making). Use when user says 'ralph team', 'team', 'agents', 'swarm', 'codex in the loop', 'autonomous team', 'loop team', 'iterate until done', 'run autonomously', 'hands-off mode', 'auto-improve this', 'let the agents work on it', or any request for multi-model collaboration."
---

# Ralph Team: Multi-Model Orchestration

Claude leads. Codex + Gemini work independently. Results converge. Topology adapts to the task.

## Core Principles

1. **Independent-then-merge** beats real-time debate (Mullen et al., 800+ teams)
2. **Single-shot with accumulated context** beats multi-turn (39% performance drop in multi-turn, arXiv:2505.06120)
3. **Diverse reasoning strategies** beat FOR/AGAINST framing (framing bias confirmed, Science Advances 2025)
4. **3 rounds max** — most debate value is in rounds 1-3 (ICLR 2025)
5. **Topology is policy, not identity** — all topologies share the same lifecycle

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

## Autonomous Loop Behavior

When the ralph-loop plugin is active:
- **You will NOT stop** between iterations — the Stop hook re-injects your task
- **Do NOT ask the user questions** — make your best judgment and act
- **Each iteration sees previous work** in files, `.team/shared/`, and git history
- **The loop prompt is the SAME every time** — use `.team/loop-state.md` to track progress
- **Safety cap**: max iterations (default 8) prevents runaway loops
- **Emergency stop**: User can run `/cancel-ralph` at any time

### Iteration Lifecycle (Autonomous)
```
1. Read .team/loop-state.md → what's REMAINING?
2. Auto-select topology based on REMAINING items
3. Execute topology: dispatch Codex + Gemini, run Claude agents
4. Collect results, fix findings, update loop-state.md
5. Check convergence → if met, output <promise>TEAM COMPLETE</promise>
6. If not converged → just finish your response (hook re-engages you)
```

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

## Convergence Detection

```
New HIGH findings this iteration?
├── YES → Reset counter to 0/3. Continue.
└── NO → Increment counter.
    ├── REMAINING identical to previous? → Counter += 2 (fixed-point).
    ├── Counter < 3, budget remaining → Continue.
    ├── Counter ≥ 2, past 50% iterations → COMPLETE.
    └── Counter = 3/3 → COMPLETE (strict).
```

**Multi-agent convergence signal:** When all agents' outputs share >80% semantic overlap on key claims across 2 consecutive rounds, declare convergence.

## Loop State Format

```
ORIGINAL INTENT: [from brief.md]
TOPOLOGY: [selected preset]
DOMAIN: [adapter loaded]
ITERATION: [N] / MAX: [3]
FIXED THIS ITERATION: [changes]
REMAINING: [open items]
CONVERGENCE: [X]/3

## DISPATCH PROOF
CODEX: YES/FAILED — [file path]
GEMINI: YES/FAILED — [file path]
AGENTS_DISPATCHED: [count]
EST_COST: [$]
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

- **Framing bias**: Never assign FOR/AGAINST — use diverse reasoning lenses
- **Multi-turn trap**: Never do back-and-forth — single-shot with accumulated context
- **Agent bloat**: More agents ≠ better. Synthesis burden grows quadratically
- **Intent drift**: #1 failure mode. Every finding must trace to Intent Anchor
- **Re-litigating truth**: Once multi-model consensus establishes a finding, PROTECT it
- **Premature synthesis**: WAIT for ALL agents. No exceptions

## Completion

Output `<promise>TEAM COMPLETE</promise>` ONLY when:
- Convergence reached per decision tree
- All findings addressed
- Dispatch proof files exist
- Output serves Intent Anchor's SUCCESS criteria

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
