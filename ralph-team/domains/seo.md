# Domain Adapter: SEO

**Success rubric:** All pages audited, issues prioritized, actionable fixes
**Tool preferences:** WebFetch, firecrawl, DataForSEO MCP, Kapture browser
**Artifact type:** Audit report with prioritized findings
**Evidence mode:** verify (check actual page source, not assumptions)

## Domain-Specific Rules

- Always check actual page source (don't assume from URL)
- Prioritize by impact: title/H1 > meta description > schema > images
- Check Core Web Vitals (CLS, LCP, INP) with real data
- Verify schema with Google Rich Results Test
- Check mobile rendering separately from desktop

## Recommended Topology: Mesh (Parallel Workers)

SEO audits are inherently parallelizable — each page is independent:
- Worker per page (or batch of 5 pages)
- Each worker checks: meta tags, content quality, schema, images, CWV
- Synthesis: cross-page patterns, site-wide issues, priority ranking

## Agent Lens Assignments (for SEO strategy decisions)

- **Agent A (Technical):** What technical SEO issues exist? Crawlability, indexing, speed?
- **Agent B (Content):** Is the content high-quality, E-E-A-T compliant, AI-citation ready?
- **Agent C (Competitive):** How does this compare to competitors? What gaps exist?

## Cross-Page Pattern Detection (Mesh Synthesis)

After all workers return, identify:
- Issues appearing on >50% of pages (systemic)
- Template-level problems (same issue on all pages of a type)
- Missing schema patterns across the site
- Internal linking gaps between related pages
- Cannibalization (multiple pages targeting same keyword)

## Output Format

```markdown
# SEO Audit: [Site]
## Critical Issues (fix immediately)
## High Priority (fix this week)
## Medium Priority (fix this month)
## Cross-Page Patterns
## Recommendations
```
