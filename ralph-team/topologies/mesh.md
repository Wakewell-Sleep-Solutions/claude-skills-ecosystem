# Mesh Topology (Parallel Workers)

**Axes:** mesh + none + single_pass
**When:** N independent items to process in parallel (pages, files, tests, audits).

## Key Research

- Maps to Anthropic's "Parallelization — Sectioning" pattern
- Maps to Google ADK's ParallelAgent
- Fan-out / fan-in (scatter-gather) architecture
- Azure: fraud detection fans out to usage, location, billing analysis agents

## Protocol

### 1. Fan-Out: Distribute Work
```
Items to process: [list of N items]
  ↓
Partition into agent-sized batches:
  Agent 1: items 1-5
  Agent 2: items 6-10
  Agent 3: items 11-15
  ↓
Dispatch ALL agents in parallel
```

### 2. Worker Execution
Each worker gets identical instructions + their assigned items:
```
You are Worker [N] processing items [X-Y].
INSTRUCTIONS: [identical for all workers]
ITEMS: [this worker's specific items]
OUTPUT FORMAT: [structured, mergeable format]
Process each item independently. Report results per item.
```

### 3. Fan-In: Collect and Merge
- Wait for ALL workers (never synthesize partial results)
- Merge results into unified output
- Identify cross-item patterns (e.g., "12 of 50 pages have the same issue")
- Deduplicate findings that appear across multiple workers

## Work Distribution Strategies

| Strategy | When to Use |
|----------|-------------|
| **Static partition** | Items roughly equal in complexity |
| **Round-robin** | Unknown complexity, want balance |
| **Complexity-weighted** | Some items known to be harder |

## Use Cases

### SEO: Multi-Page Audit
- Worker per page (or batch of 5 pages)
- Each worker checks: meta tags, content quality, schema, images, CWV
- Synthesis: cross-page patterns, site-wide issues, priority ranking

### Content: Multi-Platform Distribution
- Worker per platform (X, LinkedIn, Threads, Bluesky)
- Each worker adapts content for platform constraints
- Synthesis: ensure no duplicate content, cross-link where appropriate

### Testing: Multi-File Fix
- Worker per test file or subsystem
- Each worker investigates and fixes independently
- Synthesis: verify fixes don't conflict, run full suite

## Agent Limits

- Max 5 parallel workers (synthesis burden grows quadratically)
- If N > 25 items, batch into groups of 5 per worker
- Each worker should complete in <5 minutes

## Anti-Patterns

- ❌ Workers editing the same files (race conditions)
- ❌ Workers depending on each other's output (use pipeline instead)
- ❌ Synthesizing before ALL workers return
- ❌ More than 5 parallel workers (diminishing returns)
