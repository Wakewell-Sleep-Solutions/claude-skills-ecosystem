# Domain Adapter: Research

**Success rubric:** Cited findings, cross-verified claims, actionable recommendations
**Tool preferences:** WebSearch, WebFetch, Exa MCP, firecrawl MCP
**Artifact type:** Research report with sources
**Evidence mode:** cite (every claim needs a source)

## Domain-Specific Rules

- Minimum 10 unique sources for any research report
- Cross-reference: if only one source says it, flag as unverified
- Recency matters: prefer sources from last 12 months
- Separate fact from inference — label estimates clearly
- Include contrarian evidence and downside cases
- No hallucination: "insufficient data found" if unknown

## Agent Lens Assignments (Socratic Topology)

- **Agent A (First Principles):** What must be true about this topic regardless of context?
- **Agent B (Empirical):** What does the data/evidence actually show? What have others found?
- **Agent C (Risk/Gaps):** What are we missing? What could be wrong? What's the contrarian view?

## Output Format

```markdown
# [Topic]: Research Report
*Sources: [N] | Confidence: [H/M/L]*
## Executive Summary (3-5 sentences)
## Key Findings (with inline citations)
## Implications / Recommendation
## Risks and Caveats
## Sources (numbered, with URLs)
```

## Healthcare Research Warning

If researching topics involving PHI: de-identify before sharing, don't send PHI to LLM APIs without BAA, distinguish enacted law from proposed rulemaking.
