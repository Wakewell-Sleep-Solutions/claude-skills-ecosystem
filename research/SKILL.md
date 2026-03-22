---
name: research
description: "Multi-source research, competitive analysis, market sizing, investor due diligence, and search-before-coding. Uses Exa neural search and firecrawl. Use when user says 'research', 'deep dive', 'search for', 'look up', 'market sizing', 'competitive analysis', 'competitor comparisons', 'due diligence', 'industry intelligence', 'technology scan', 'find existing tools', 'what's the latest on', or before writing custom code that likely has existing solutions."
---

# Research

Thorough, cited research from multiple sources. Covers deep research, market intelligence, and search-before-coding.

## When to Activate

- User asks to research any topic in depth
- Competitive analysis, technology evaluation, market sizing
- Investor/fund due diligence before outreach
- Starting a new feature that likely has existing solutions
- Before writing a new utility, helper, or abstraction
- User says "research", "deep dive", "search for", "look up", "find"

## Research Workflow

### Step 1: Understand the Goal
Ask 1-2 clarifying questions: "Learning, making a decision, or writing something?" If user says "just research it" — skip with reasonable defaults.

### Step 2: Plan (3-5 sub-questions)
Break the topic into research sub-questions.

### Step 3: Multi-Source Search
For each sub-question, search with available MCP tools:
- `firecrawl_search(query, limit: 8)` — broad web search
- `web_search_exa(query, numResults: 8)` — neural search
- `get_code_context_exa(query, tokensNum: 3000)` — code/API examples
- Aim for 15-30 unique sources total

### Step 4: Deep-Read Key Sources
Fetch 3-5 key sources in full. Don't rely only on snippets.

### Step 5: Synthesize Report
```markdown
# [Topic]: Research Report
*Generated: [date] | Sources: [N] | Confidence: [H/M/L]*
## Executive Summary
## Key Findings (with sources)
## Implications / Recommendation
## Risks and Caveats
## Sources (numbered, with URLs)
```

## Research Modes

### Market Sizing
- Top-down from reports/datasets + bottom-up sanity checks
- Explicit assumptions for every leap in logic
- TAM/SAM/SOM estimates with methodology

### Competitive Analysis
- Product reality (not marketing copy), funding history, traction
- Distribution/pricing clues, positioning gaps
- Strengths, weaknesses, and moat assessment

### Investor/Fund Diligence
- Fund size, stage, typical check size
- Relevant portfolio companies, public thesis
- Reasons the fund is/isn't a fit, red flags

### Technology/Vendor Research
- How it works, trade-offs, adoption signals
- Integration complexity, lock-in risk
- Security, compliance, and operational risk

## Search-First Patterns (Before Writing Code)

0. Does this already exist in the repo? — `rg` through modules
1. Is this a common problem? — Search npm/PyPI
2. Is there an MCP for this? — Check settings
3. Is there a skill for this? — Check skills dir
4. Is there a GitHub implementation? — Search for maintained OSS

| Signal | Action |
|--------|--------|
| Exact match, well-maintained, MIT/Apache | **Adopt** — install and use |
| Partial match, good foundation | **Extend** — install + thin wrapper |
| Multiple weak matches | **Compose** — combine 2-3 packages |
| Nothing suitable | **Build** — custom, informed by research |

## Quality Standards

1. Every claim needs a source. No unsourced assertions.
2. Cross-reference — if only one source says it, flag as unverified.
3. Recency matters — prefer last 12 months.
4. Acknowledge gaps — if you couldn't find good info, say so.
5. No hallucination — "insufficient data found" if unknown.
6. Separate fact from inference. Label estimates clearly.
7. Include contrarian evidence and downside cases.
8. Translate findings into a decision, not just a summary.

## Parallel Research with Subagents

For broad topics, dispatch agents per sub-question cluster. Each searches independently, main session synthesizes.

## Healthcare Research Warning

If researching topics involving PHI: de-identify before sharing, don't send PHI to LLM APIs without BAA, distinguish enacted law from proposed rulemaking (NPRM).
