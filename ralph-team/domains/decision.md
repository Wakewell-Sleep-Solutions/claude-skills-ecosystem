# Domain Adapter: Decision-Making

**Success rubric:** Clear recommendation with evidence, risks acknowledged, reversibility assessed
**Tool preferences:** WebSearch, internal docs, stakeholder context
**Artifact type:** Decision memo or recommendation brief
**Evidence mode:** cite + verify (claims need sources, assumptions need validation)

## Domain-Specific Rules

- Frame every decision with: options, stakes, reversibility
- Include expected value analysis when quantifiable
- Never present a recommendation without acknowledging risks
- Distinguish "we don't know" from "we know it's safe"
- If decision is irreversible, require higher evidence bar

## Recommended Topology: Adversarial (Anonymized)

High-stakes decisions need genuine opposition, not manufactured consensus:
- Use diverse reasoning lenses (NOT FOR/AGAINST positions)
- Anonymize agent outputs before synthesis
- Present decision matrix with weighted factors

## Agent Lens Assignments

- **Agent A (First Principles):** Strip assumptions. What must be true? Simplest correct answer?
- **Agent B (Empirical):** What have others done? Base rates? Case studies? What worked/failed?
- **Agent C (Pre-Mortem):** It's one year later, this was a disaster. What went wrong?

## Decision Framework

### Step 1: Frame
| Element | Value |
|---------|-------|
| Decision | [What are we deciding?] |
| Options | [A, B, C...] |
| Stakes | [What happens if we choose wrong?] |
| Reversibility | [Can we undo this? At what cost?] |
| Timeline | [When must we decide?] |

### Step 2: Analyze (via agents with diverse lenses)

### Step 3: Decision Matrix
| Factor | Weight | Option A | Option B | Option C |
|--------|--------|----------|----------|----------|
| [Factor 1] | [1-10] | [score] | [score] | [score] |

### Step 4: Recommend
- All agents converge → Strong recommendation
- 2/3 converge → Recommend with noted dissent
- No convergence → Present options with tradeoffs, ask user

## Output Format

```markdown
# Decision: [Topic]
## Recommendation: [Option X]
## Why: [2-3 sentences]
## Evidence Summary
## Risks and Mitigations
## Dissenting View (if any)
## Reversibility Plan
```
