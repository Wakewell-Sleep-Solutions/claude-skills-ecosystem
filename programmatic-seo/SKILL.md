---
name: programmatic-seo
description: "Create SEO-driven pages at scale using templates and data. Use when user mentions 'programmatic SEO', 'pSEO', 'template pages', 'pages at scale', 'directory pages', 'location pages', '[keyword] + [city] pages', 'generate pages', 'data-driven pages', or 'templated landing pages'. For competitor comparison pages, see competitor-pages. For single-page SEO, see seo-page."
metadata:
  version: 2.0.0
origin: ECC
---

# Programmatic SEO (Merged — Strategy + Technical)

Build SEO-optimized pages at scale from structured data. Covers strategy, template design, quality gates, and index management.

## Initial Assessment

**Check for product marketing context first:** If `.agents/product-marketing-context.md` exists, read it before asking questions.

1. **Business**: Product/service, audience, conversion goal
2. **Opportunity**: Search patterns, page count, volume distribution
3. **Competition**: Who ranks now, what their pages look like, can you compete?

## Core Principles

1. **Unique value per page** — not just swapped variables in a template
2. **Proprietary data wins** — hierarchy: proprietary > product-derived > user-generated > licensed > public
3. **Clean URL structure** — subfolders consolidate authority, subdomains split it
4. **Search intent match** — pages must answer what people actually search for
5. **Quality over quantity** — 100 great pages > 10,000 thin ones

## The 12 Playbooks

| Playbook | Pattern | Example |
|----------|---------|---------|
| Templates | "[Type] template" | "resume template" |
| Curation | "best [category]" | "best website builders" |
| Conversions | "[X] to [Y]" | "$10 USD to GBP" |
| Comparisons | "[X] vs [Y]" | "webflow vs wordpress" |
| Examples | "[type] examples" | "landing page examples" |
| Locations | "[service] in [location]" | "dentists in austin" |
| Personas | "[product] for [audience]" | "crm for real estate" |
| Integrations | "[product A] [product B] integration" | "slack asana integration" |
| Glossary | "what is [term]" | "what is pSEO" |
| Translations | Multi-language content | Localized content |
| Directory | "[category] tools" | "ai copywriting tools" |
| Profiles | "[entity name]" | "stripe ceo" |

**Choosing:** Proprietary data → Directories/Profiles. Integrations → Integrations. Multi-segment audience → Personas. Local presence → Locations. Tool product → Conversions. Expertise → Glossary/Curation. You can layer playbooks.

## Data Source Assessment

- **CSV/JSON/API/DB**: Row count, column uniqueness, missing values, update frequency
- Flag duplicate records (>80% field overlap)
- Each record must have enough unique attributes to generate distinct content
- Verify data freshness — stale data = stale pages

## Template Design

- **Variable injection**: Title, H1, body, meta, schema
- **Content blocks**: Static (shared) vs dynamic (unique per page)
- **Conditional logic**: Show/hide based on data availability
- Each page must read as standalone valuable resource — no mad-libs patterns

## URL Patterns

- `/tools/[tool-name]`, `/[city]/[service]`, `/integrations/[platform]`, `/glossary/[term]`
- Lowercase, hyphenated, under 100 chars, no query params, consistent trailing slash

## Internal Linking

- **Hub/spoke**: Category hub → individual pages → cross-links between related spokes
- **Related items**: 3-5 auto-linked per page based on attributes
- **Breadcrumbs**: BreadcrumbList schema from URL hierarchy
- 3-5 internal links per 1000 words

## Quality Gates (Critical — Google Enforcement 2025-2026)

Google's Scaled Content Abuse policy saw major enforcement in 2025 (45% reduction in low-quality content). Apply these gates:

| Metric | Threshold | Action |
|--------|-----------|--------|
| Unique content per page | <30% | 🛑 HARD STOP — scaled content abuse risk |
| Unique content per page | <40% | ⚠️ Flag as thin content — penalty risk |
| Word count per page | <300 | ⚠️ Review — may lack value |
| Pages without review | 100+ | ⚠️ Require content audit before publish |
| Pages without justification | 500+ | 🛑 HARD STOP — require approval |

**Safe at scale:** Integration pages (real docs), template pages (downloadable), glossary (200+ words), product pages (unique specs), data-driven pages (unique stats/charts)

**Penalty risk:** Location pages with only city name swapped, "[tool] for [industry]" without industry value, AI-generated without human review, >60% template boilerplate

**Progressive rollout:** Publish in batches of 50-100. Monitor 2-4 weeks before expanding. Never publish 500+ simultaneously.

## Index Management

- Self-referencing canonical on every page
- Noindex low-value pages and paginated results beyond page 1
- Split sitemaps at 50K URLs, use sitemap index
- `<lastmod>` = actual data update timestamp
- Monthly audit: indexed count vs intended count

## Pre-Launch Checklist

- [ ] Each page provides unique value and answers search intent
- [ ] Unique titles and meta descriptions
- [ ] Schema markup implemented
- [ ] Connected to site architecture (no orphan pages)
- [ ] In XML sitemap, crawlable, no conflicting noindex
- [ ] Page speed acceptable

## Related Skills

- **seo-audit**: Audit programmatic pages post-launch
- **schema-markup**: Structured data implementation
- **site-architecture**: Page hierarchy and internal linking
- **competitor-pages**: Comparison page frameworks
