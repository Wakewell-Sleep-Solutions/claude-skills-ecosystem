# Adversarial Topology (Decision-Making)

**Axes:** star + debate + single_pass
**When:** High-stakes decisions needing genuine opposition. Architecture choices, buy-vs-build, strategic direction.

## Key Research

- FOR/AGAINST framing causes models to converge on inherent bias (Science Advances 2025)
- Anonymization improves debate quality (arXiv:2510.07517)
- Diversity of reasoning strategy > diversity of assigned position
- Fallacious arguments measurably influence LLM debate (arXiv:2511.07784)

## Protocol: Anonymized Diverse Reasoning

### CRITICAL: Do NOT Assign Positions
❌ WRONG: "Codex, argue FOR. Gemini, argue AGAINST."
✅ RIGHT: Give each agent a different reasoning LENS, not a different conclusion.

### Step 1: Frame the Decision
```
DECISION: [What are we deciding?]
OPTIONS: [A, B, C...]
STAKES: [What happens if we choose wrong?]
REVERSIBILITY: [Can we undo this?]
```

### Step 2: Dispatch with Diverse Lenses (NOT Positions)
Each agent uses a different analytical framework:

**Agent A — First Principles:**
```
Analyze this decision from first principles.
Strip away assumptions. What must be true?
What's the simplest correct answer?
```

**Agent B — Empirical/Historical:**
```
Analyze this decision based on precedent.
What have others done in similar situations?
What worked? What failed? What's the base rate?
```

**Agent C — Inversion (Pre-Mortem):**
```
It's one year from now. This decision was a disaster.
What went wrong? What did we miss?
Work backward from failure to identify hidden risks.
```

### Step 3: Anonymize Before Synthesis
Before reading agent outputs, strip all model identifiers:
- Replace "Codex says" with "Analysis 1 concludes"
- Remove any self-references to model capabilities
- Present findings purely on merit of reasoning

### Step 4: Synthesize Decision Matrix

| Factor | Analysis 1 | Analysis 2 | Analysis 3 | Weight |
|--------|-----------|-----------|-----------|--------|
| [Factor 1] | [position] | [position] | [position] | [1-10] |
| [Factor 2] | [position] | [position] | [position] | [1-10] |

### Step 5: Recommendation
- If all analyses converge → strong recommendation
- If 2/3 converge → recommend with noted dissent
- If no convergence → present options to user with tradeoffs

## When to Use Adversarial vs Socratic

| Signal | Use Adversarial | Use Socratic |
|--------|----------------|--------------|
| Binary or N-ary choice | ✅ | |
| High-stakes, irreversible | ✅ | |
| Architecture decision | ✅ | |
| Open-ended question | | ✅ |
| Evolving understanding | | ✅ |
| Need to explore unknowns | | ✅ |

## Anti-Patterns

- ❌ Assigning FOR/AGAINST (framing bias)
- ❌ Using same model instance for multiple lenses (no diversity)
- ❌ Ignoring dissenting analysis because majority agrees
- ❌ Forcing consensus when genuine uncertainty exists
- ❌ More than 3 analyses (synthesis burden outweighs insight)
