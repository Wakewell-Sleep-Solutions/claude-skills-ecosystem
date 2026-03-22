# Hub-Spoke Topology (Default)

**Axes:** star + none + single_pass
**When:** Standard multi-model task. Claude dispatches, agents work independently, Claude synthesizes.

## Protocol

1. **Decompose** — Break task into independent subtasks
2. **Dispatch** — Send each subtask to an agent (Claude subagent, Codex, Gemini)
3. **Collect** — Wait for ALL agents to return
4. **Synthesize** — Merge findings, resolve conflicts, produce output
5. **Verify** — Check output against Intent Anchor's SUCCESS criteria

## Agent Roles

- **Claude subagents**: Complex reasoning, research synthesis, writing
- **Codex**: Code review, security audit, implementation challenges
- **Gemini**: Large-context analysis, cross-file patterns, architectural review

## Dispatch Template

```
Ultrathink. You are [MODEL], part of a multi-model team.
INTENT: [paste brief.md]
YOUR TASK: [specific subtask]
REASONING LENS: [first principles | historical precedent | risk analysis]
OUTPUT: ## Crystallized Findings (max 7)
- [Finding]: [evidence] | Risk: [X] | Confidence: [H/M/L] | Weight: [1-10]
```

## Synthesis Rules

- Accept findings with H confidence and weight ≥7
- Challenge findings where models disagree — reasoning wins, not voting
- If finding doesn't trace to Intent Anchor, discard
- Produce single unified output, not a list of agent responses
