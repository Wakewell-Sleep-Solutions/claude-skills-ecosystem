# Content Quality Gates

Thresholds and checks applied during SEO content audits and creation.

## Minimum Word Counts by Page Type

| Page Type | Minimum | Target | Notes |
|-----------|---------|--------|-------|
| Blog post | 1,500 | 2,000-3,000 | Long-form ranks better for informational queries |
| Product page | 300 | 500-800 | Focus on unique descriptions, not filler |
| Landing page | 500 | 800-1,200 | Enough to establish relevance and intent match |
| Location page | 800 | 1,000-1,500 | Must include genuinely local content |
| Category page | 300 | 500+ | Introductory copy above product grid |
| About/bio page | 400 | 600-1,000 | Supports E-E-A-T signals |
| FAQ page | 500 | 800+ | 5-10 questions minimum |

Pages below minimum are flagged as **thin content** in audits.

## Uniqueness Requirements

### Location Pages
- **60%+ unique content required** per location page
- Shared boilerplate (service descriptions, company info) must be < 40% of page
- Unique elements: local landmarks, neighborhood references, local team bios, location-specific testimonials, area-specific stats
- **Warning threshold:** 30+ location pages — review for quality dilution
- **Hard stop:** 50+ location pages — do NOT create more without a uniqueness audit; recommend programmatic + editorial hybrid approach

### General Uniqueness
- Cross-page duplicate content > 50% triggers a warning
- Use canonical tags for intentional duplicates (print pages, parameter variants)
- Syndicated content must use `rel=canonical` pointing to original

## Thin Content Detection Criteria

Flag a page as thin if ANY of these apply:
- Word count below minimum for its page type
- More than 40% of content duplicated from another page on the same site
- No original images, media, or data
- Fewer than 2 internal links to/from the page
- No author attribution on YMYL content
- Auto-generated content with no editorial review
- Gateway/doorway page pattern (many similar pages targeting location variants with minimal unique content)

## Internal Linking Minimums

| Page Type | Outbound Internal Links | Inbound Internal Links |
|-----------|------------------------|----------------------|
| Blog post | 3-5 | 2+ (from related posts, category pages) |
| Product page | 2-3 | 3+ (from category, related products, blog) |
| Landing page | 2-4 | 5+ (primary navigation, footer, CTAs) |
| Location page | 3-5 | 2+ (from location hub, nearby locations) |
| Pillar/hub page | 8-15 | 5+ (cluster pages should link back) |

### Linking Rules
- Every page should be reachable within 3 clicks from the homepage
- Orphan pages (0 inbound internal links) must be fixed or noindexed
- Anchor text should be descriptive (not "click here")
- Avoid linking to the same URL more than once per page (first link wins for anchor text signals)
