---
name: competitor-pages
description: "Create competitor comparison and alternatives pages for SEO and sales. Use when user mentions 'comparison page', 'vs page', 'alternatives page', 'competitor comparison', '[X] vs [Y]', '[X] alternative', 'competitive landing pages', 'battle card', or 'competitor teardown'. Covers 4 formats: singular alternative, plural alternatives, you vs competitor, competitor vs competitor. For building comparison pages at SCALE, see programmatic-seo."
metadata:
  version: 2.0.0
origin: ECC
---

# Competitor & Alternative Pages (Merged — SEO + Sales)

Create high-converting comparison and alternatives pages that target competitive intent keywords with accurate, structured content.

## Initial Assessment

**Check for product marketing context first:** If `.agents/product-marketing-context.md` exists, read it before asking questions.

1. **Your product**: Value prop, differentiators, ideal customer, pricing, honest weaknesses
2. **Competitive landscape**: Direct/indirect competitors, market positioning, search volume
3. **Goals**: SEO traffic, sales enablement, conversion from competitor users, brand positioning

## Core Principles

1. **Honesty builds trust** — acknowledge competitor strengths, be accurate about your limitations
2. **Depth over surface** — go beyond checklists, explain WHY differences matter
3. **Help them decide** — be clear about who you're best for AND who competitor is best for
4. **Centralized data** — single source of truth per competitor, updates propagate to all pages

## Four Page Formats

### 1. [Competitor] Alternative (Singular)
**Intent:** User actively looking to switch. **URL:** `/alternatives/[competitor]`
**Keywords:** "[Competitor] alternative", "alternative to [Competitor]", "switch from [Competitor]"
**Structure:** Why people look for alternatives → You as the alternative → Detailed comparison → Who should switch (and who shouldn't) → Migration path → Social proof from switchers → CTA

### 2. [Competitor] Alternatives (Plural)
**Intent:** Researching options, earlier in journey. **URL:** `/alternatives/[competitor]-alternatives`
**Keywords:** "[Competitor] alternatives", "best [Competitor] alternatives"
**Structure:** Common pain points → What to look for (criteria) → List of 4-7 real alternatives (you first) → Comparison table → Detailed breakdown → Recommendation by use case → CTA

### 3. You vs [Competitor]
**Intent:** Direct comparison. **URL:** `/vs/[competitor]`
**Keywords:** "[You] vs [Competitor]", "[Competitor] vs [You]"
**Structure:** TL;DR (2-3 sentences) → At-a-glance table → Detailed comparison by category → Who you're best for → Who competitor is best for (be honest) → Testimonials from switchers → CTA

### 4. [Competitor A] vs [Competitor B]
**Intent:** Comparing two competitors (not you). **URL:** `/compare/[a]-vs-[b]`
**Structure:** Overview of both → Comparison by category → Who each is best for → Introduce yourself as third option → Three-way table → CTA

## Feature Matrix

```
| Feature          | Your Product | Competitor A | Competitor B |
|------------------|:------------:|:------------:|:------------:|
| Feature 1        | ✅           | ✅           | ❌           |
| Feature 2        | ✅           | ⚠️ Partial   | ✅           |
| Pricing (from)   | $X/mo        | $Y/mo        | $Z/mo        |
```

**Data accuracy:** All claims verifiable from public sources. Include "as of [date]" on pricing. Review quarterly.

## Keyword Patterns

| Pattern | Example | Volume |
|---------|---------|--------|
| `[A] vs [B]` | "Slack vs Teams" | High |
| `[A] alternative` | "Figma alternatives" | High |
| `[A] alternatives [year]` | "Notion alternatives 2026" | High |
| `best [category] tools` | "best PM tools" | High |
| `[A] vs [B] for [use case]` | "AWS vs Azure for startups" | Medium |
| `[A] vs [B] pricing` | "HubSpot vs Salesforce pricing" | Medium |

**Title formulas:**
- X vs Y: `[A] vs [B]: [Key Differentiator] ([Year])`
- Alternatives: `[N] Best [A] Alternatives in [Year] (Free & Paid)`
- Roundup: `[N] Best [Category] Tools in [Year] — Compared & Ranked`

## Schema Markup

Use **Product** or **SoftwareApplication** schema with AggregateRating for each product. Use **ItemList** for roundup pages. Add **FAQ** schema for common questions.

## Conversion Optimization

- **CTA placement:** Above fold (summary), after comparison table, bottom of page
- **Social proof:** Customer testimonials, G2/Capterra ratings, migration case studies
- **Pricing:** Tier-by-tier comparison including hidden costs
- **Trust signals:** "Last updated [date]", methodology disclosure, affiliation disclosure
- Avoid aggressive CTAs in competitor description sections (reduces trust)

## Internal Linking

- Cross-link between related competitor pages
- Link from feature pages to relevant comparisons
- Create hub page for all competitor content
- Breadcrumb: Home > Comparisons > [This Page]

## Research Process

1. **Product research**: Sign up, use it, document features/UX/limitations
2. **Pricing research**: Current pricing, included features, hidden costs
3. **Review mining**: G2, Capterra, TrustRadius for praise/complaint themes
4. **Content research**: Their positioning, their comparison pages, their changelog
5. **Updates**: Quarterly pricing/feature check. Annual full refresh.

## Related Skills

- **programmatic-seo**: Build competitor pages at scale
- **copywriting**: Compelling comparison copy
- **schema-markup**: FAQ and comparison schema
- **seo-page**: Single-page SEO optimization
