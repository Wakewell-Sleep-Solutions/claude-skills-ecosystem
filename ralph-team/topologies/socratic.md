# Socratic Topology (Research Convergence)

**Axes:** star + none + iterative
**When:** High uncertainty. Question must evolve. Need agents to independently converge on truth.

## Key Research Findings

- Multi-turn back-and-forth is 39% WORSE than single-shot (arXiv:2505.06120)
- Most debate value is in rounds 1-3 (ICLR 2025)
- Self-MoA (same model refining itself) outperforms mixture-of-agents by 6.6%
- Princeton's SocraticAI: agents question and extract knowledge from each other

## Protocol (NOT Multi-Turn)

### Round 1: Independent Exploration
Each agent independently answers the core question with NO knowledge of others' positions.
- Use diverse reasoning lenses (NOT FOR/AGAINST — that causes framing bias):
  - Agent A: "First principles — what must be true regardless of context?"
  - Agent B: "Historical precedent — what has worked/failed in similar situations?"
  - Agent C: "Failure analysis — what could go wrong? What are we missing?"

### Round 2: Cross-Pollination (Single-Shot)
Each agent receives ALL Round 1 outputs as context in ONE prompt:
```
Here are 3 independent analyses of [question]:
[Agent A output]
[Agent B output]
[Agent C output]

Given all three perspectives, refine your position.
What do you now believe is true? What changed? What remains uncertain?
```
This is a SINGLE prompt, NOT a conversation. Each agent refines in one shot.

### Round 3: Convergence Check
Compare Round 2 outputs:
- >80% semantic overlap on key claims → CONVERGED. Synthesize final answer.
- <80% overlap → One more round with remaining disagreements highlighted.
- After Round 3, if still no convergence → Present divergent views to user for decision.

## Convergence Signals

- All agents agree on the same 3-5 key claims
- Stance shift between rounds is diminishing (<10% change)
- No new HIGH-weight findings emerging
- Agents cite each other's evidence approvingly

## Anti-Patterns

- ❌ Multi-turn conversation with agents (39% performance drop)
- ❌ Assigning FOR/AGAINST positions (framing bias)
- ❌ More than 3 rounds (diminishing returns)
- ❌ Forcing convergence when genuine disagreement exists (present both views)
- ❌ Using same reasoning lens for all agents (reduces diversity)
