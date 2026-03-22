---
name: think
description: "Universal reasoning framework for solo deep thinking. Applies 7 research-backed principles to ANY problem without spinning up agents. Use when user says 'think', 'ultrathink', 'reason through', 'analyze this', 'think deeply', or for any non-trivial decision that doesn't need a full team."
origin: ECC
---

# Think: Universal Reasoning Framework

Use this for solo deep thinking — no agents, no team, just structured reasoning that's proven to produce better output than unstructured "think harder."

## When to Use Think vs Team

| Situation | Use |
|-----------|-----|
| One person can solve this with better structure | **think** |
| Needs multiple models or cross-model challenge | **team** |
| Strategic decision, design choice, analysis | **think** |
| Multi-file implementation with audit | **team** |
| "Ultrathink" on a focused question | **think** |
| "Ultrathink" on a complex build | **team** |

## The 7 Principles (Applied to Solo Thinking)

### 1. Sample Multiple Paths, Select the Best
Don't commit to the first approach. Generate 2-3 distinct paths BEFORE evaluating. Self-consistency research: +17.9% accuracy from sampling multiple reasoning paths and picking the majority answer (Wang et al. 2022).

**How:** Before answering, think: "What are 2-3 fundamentally different ways to approach this?" Write them out. Then evaluate.

### 2. Quality Early Compounds Into Velocity
Get the foundation right. Cutting corners on fundamentals creates exponential downstream cost. Google's lagged panel analysis: code quality CAUSES future development speed (not the other way around). DORA 10-year study: speed and stability are positively correlated.

**How:** Spend 80% of thinking time on the problem definition and constraints. The solution often becomes obvious once the problem is properly framed.

### 3. Decompose Into Fundamentals
Break complex problems into atomic pieces. Chunking (Miller 1956): working memory holds 7+/-2 items. Tree-of-Thought: decomposition + evaluation beats linear chain-of-thought on strategic tasks.

**How:** List the 3-5 fundamental sub-questions. Answer each independently. Then compose.

### 4. External Verification > Self-Assessment
Self-correction without external feedback HURTS accuracy (Huang et al. 2024). Don't trust your first answer. Seek contradiction.

**How:** After reaching a conclusion, actively try to DISPROVE it. What evidence would make this wrong? If you can't find any, your conclusion is either strong or you're not trying hard enough.

### 5. Independence Before Aggregation
Form your own view BEFORE reading others' opinions. Anchoring bias is real. Nominal groups outperform brainstorming by +57% (Mullen et al. meta-analysis).

**How:** Think independently first. Then (if applicable) check existing code, docs, or prior decisions. Note where your independent view differs — those differences are the valuable signal.

### 6. Match Technique to Complexity
Not every problem needs the same thinking depth. CoT for simple, Tree-of-Thought for strategic, sampling for critical.

| Problem Type | Technique | Why |
|-------------|-----------|-----|
| Factual / lookup | Direct answer | Overthinking adds noise |
| Single-step logic | Chain of thought | One reasoning chain suffices |
| Multi-step with branches | Tree of thought | Need to evaluate branches |
| High-stakes decision | Sample 3 paths + inversion | Can't afford to be wrong |
| Creative / open-ended | Diverge widely, then converge | Premature convergence kills creativity |

### 7. Provide Scaffolding, Not Just "Think Harder"
Structure beats raw intelligence. Checklists improve defect detection 25-40% (Fagan 1976, PBR studies). Structured reasoning frameworks outperform unstructured prompts (ACL 2024).

**How:** Use the appropriate scaffold below.

## Reasoning Scaffolds

### For Decisions
```
DECISION: [What are we deciding?]
OPTIONS: [2-3 distinct options]
FOR EACH OPTION:
  - Best case: [what if this goes perfectly?]
  - Worst case: [what if this fails? — Munger inversion]
  - Evidence: [what data supports this?]
  - Reversibility: [can we undo this if wrong?]
RECOMMENDATION: [which option, and WHY]
WHAT WOULD CHANGE MY MIND: [pre-commit to updating if X happens]
```

### For Analysis
```
QUESTION: [What are we trying to understand?]
DECOMPOSITION: [3-5 sub-questions]
FOR EACH SUB-QUESTION:
  - Finding: [what did I discover?]
  - Confidence: [H/M/L]
  - What would change this: [what evidence would flip this?]
SYNTHESIS: [How do the sub-answers compose into a full answer?]
GAPS: [What don't I know that matters?]
```

### For Problem-Solving
```
PROBLEM: [What's broken or needed?]
STEP 1 — QUESTION: Is this the right problem? (Elon Step 1)
STEP 2 — DELETE: What parts of this problem can I eliminate entirely? (Elon Step 2)
STEP 3 — SIMPLIFY: What's the simplest possible solution? (Elon Step 3)
PATH A: [Approach 1] — risk: [what kills it]
PATH B: [Approach 2] — risk: [what kills it]
PATH C: [Approach 3] — risk: [what kills it] (optional)
SELECTION: [which path, WHY, and what I'm accepting as risk]
```

### For Code Design
```
WHAT: [one sentence — what does this code need to do?]
CONSTRAINTS: [perf, compatibility, security, HIPAA if applicable]
PATHS:
  Path A: [approach] — tradeoff: [what you gain/lose]
  Path B: [approach] — tradeoff: [what you gain/lose]
INVERSION: What would make this code fail in production?
DECISION: [chosen path + reasoning]
FUNDAMENTALS CHECK:
  - [ ] Error handling for all failure modes?
  - [ ] Edge cases: empty, null, boundary, overflow?
  - [ ] Is this the simplest version that works? (Step 3)
```

## Claude 4.6 Adaptive Thinking

Claude 4.6 introduces adaptive thinking — Claude dynamically decides when and how much to think based on effort level. Fixed budgetTokens is deprecated on 4.6. Key capabilities:
- **Think tool:** Stopping mid-generation to consider approach achieved 54% relative improvement in multi-step tasks (tau-bench airline domain). Use for complex decisions where "pause and think" outperforms linear generation.
- **Multishot examples:** Include `<thinking>` tags in examples to teach reasoning patterns.
- **Bimodal workload optimization:** Adaptive mode skips deep thinking on simple queries, applies it on complex ones — optimizes cost automatically.
- **"Ultrathink" prompt:** Still effective as a quality signal. Triggers deeper reasoning allocation.

## CoT Limitations (Important Caveat)

Chain-of-thought is effective but **brittle under distribution shift** (arXiv:2508.01191, 2026). CoT works well on near-distribution data but degrades on out-of-distribution problems — LLMs can generate fluent yet logically inconsistent reasoning from memorized patterns rather than true inference.

**What this means for our skills:**
- CoT is the right default for standard tasks (Principle 6: match technique to complexity)
- For novel/unusual problems, complement CoT with self-consistency (sample multiple paths) or multi-agent verification (team skill)
- Don't trust a single fluent reasoning chain on an unfamiliar problem — verify externally (Principle 4)

**Three agentic reasoning modes** (useful taxonomy):
- **Reflective** (internal inference) → think skill
- **Instrumental** (external tool use) → codex skill
- **Collective** (multi-agent collaboration) → team skill
Each mode faces exponential accuracy decay in long-horizon plans — supporting our decomposition strategy.

## Anti-Patterns

- **Thinking without structure:** "Let me think about this..." then rambling. Use a scaffold.
- **Premature convergence:** Jumping to the first solution. Sample 2-3 paths first.
- **Self-confirming reasoning:** Reaching a conclusion then only finding supporting evidence. Apply inversion.
- **Over-thinking trivial things:** Config change doesn't need Tree-of-Thought. Match technique to complexity.
- **Under-thinking critical things:** Auth logic needs sampling + inversion, not a quick answer.

## Related Skills
- **team:** For problems needing multi-model collaboration, not just solo thinking
- **ralph-team:** For problems needing iterative improvement across multiple rounds
- **brainstorming:** For creative exploration before implementation
- **software-architecture:** For structural decisions needing architectural analysis
