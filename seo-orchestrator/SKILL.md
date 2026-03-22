---
name: seo-orchestrator
description: >
  Comprehensive SEO analysis for any website or business type. Performs full site
  audits, single-page deep analysis, technical SEO checks (crawlability, indexability,
  Core Web Vitals with INP, security headers, JS rendering, IndexNow), content
  quality assessment (E-E-A-T framework, readability, thin content, AI content
  detection), image optimization (alt text, formats, lazy loading, CLS prevention),
  sitemap analysis and generation, hreflang/international SEO validation, schema
  markup detection/validation/generation, and Generative Engine Optimization (GEO)
  for AI Overviews, ChatGPT, and Perplexity citations. Strategic SEO planning with
  industry templates, competitive analysis, content strategy, and implementation
  roadmaps. Triggers on: "SEO", "audit", "schema", "Core Web Vitals", "sitemap",
  "E-E-A-T", "AI Overviews", "GEO", "technical SEO", "content quality", "page speed",
  "structured data", "hreflang", "i18n SEO", "international SEO", "image optimization",
  "alt text", "image SEO", "SEO plan", "SEO strategy", "content strategy",
  "site architecture", "SEO roadmap", "analyze this page", "check page SEO",
  "content audit", "readability", "thin content", "crawl issues", "robots.txt",
  "security headers", "XML sitemap", "generate sitemap".
origin: ECC
---

# SEO Orchestrator — Universal SEO Analysis

Comprehensive SEO across all industries (SaaS, local services, e-commerce, publishers, agencies).

## Quick Reference

| Command | What it does |
|---------|-------------|
| `/seo audit <url>` | Full website audit with parallel subagent delegation |
| `/seo page <url>` | Deep single-page analysis |
| `/seo technical <url>` | Technical SEO audit (9 categories) |
| `/seo content <url>` | E-E-A-T and content quality analysis |
| `/seo images <url>` | Image optimization analysis |
| `/seo sitemap <url or generate>` | Analyze or generate XML sitemaps |
| `/seo schema <url>` | Detect, validate, generate Schema.org markup |
| `/seo hreflang [url]` | Hreflang/i18n SEO audit and generation |
| `/seo geo <url>` | AI Overviews / Generative Engine Optimization |
| `/seo plan <business-type>` | Strategic SEO planning |
| `/seo programmatic [url\|plan]` | Programmatic SEO analysis |
| `/seo competitor-pages [url\|generate]` | Competitor comparison pages |
| `/seo dataforseo [command]` | Live SEO data via DataForSEO (extension) |

## Orchestration Logic

For `/seo audit`, delegate in parallel:
1. Detect business type (SaaS, local, ecommerce, publisher, agency)
2. Spawn subagents: technical, content, schema, sitemap, images, ai-seo
3. Collect results into unified SEO Health Score (0-100)
4. Create prioritized action plan (Critical > High > Medium > Low)

For individual commands, run the relevant section inline.

## Industry Detection

Detect from homepage: **SaaS** (pricing, /features, "free trial"), **Local** (phone, address, service area), **E-commerce** (/products, /cart, product schema), **Publisher** (/blog, article schema, author pages), **Agency** (/case-studies, /portfolio, client logos).

## Quality Gates

- Never recommend HowTo schema (deprecated Sept 2023)
- FAQ schema: only gov/healthcare for Google rich results (Aug 2023); existing FAQPage on commercial sites = Info priority only; new FAQPage = not recommended for Google
- All CWV references use INP, never FID
- Jan 2026 schema deprecations: Course Info, Claim Review, Estimated Salary, Learning Video, Special Announcement, Vehicle Listing, Practice Problems
- March 2026 Core Update: Discover update (800M+ users), original research +22%, AI-spam demoted
- Google AI Mode (March 2026): Separate from AI Overviews, only 13.7% citation overlap
- Location pages: WARNING at 30+, HARD STOP at 50+ (require 60%+ unique content)

## Scoring

| Category | Weight |
|----------|--------|
| Technical SEO | 22% |
| Content Quality | 23% |
| On-Page SEO | 20% |
| Schema / Structured Data | 10% |
| Performance (CWV) | 10% |
| AI Search Readiness | 10% |
| Images | 5% |

Priority: **Critical** = blocks indexing/penalties (immediate), **High** = impacts rankings (1 week), **Medium** = optimization opportunity (1 month), **Low** = backlog.

## Reference Files (load on-demand)

- `references/cwv-thresholds.md`, `references/schema-types.md`, `references/eeat-framework.md`, `references/quality-gates.md`

---

## 1. Technical SEO (9 Categories)

### 1.1 Crawlability
- robots.txt: exists, valid, not blocking important resources
- XML sitemap: exists, referenced in robots.txt, valid format
- Noindex tags: intentional vs accidental
- Crawl depth: important pages within 3 clicks
- JS rendering: critical content requiring JS execution
- Crawl budget: efficiency for sites >10k pages

**AI Crawler Management:** Check robots.txt for GPTBot (OpenAI training), ChatGPT-User (browsing), ClaudeBot (Anthropic), PerplexityBot, Bytespider (ByteDance), Google-Extended (Gemini training, NOT search), CCBot. Blocking Google-Extended does NOT affect Search/AI Overviews. ~3-5% of sites now use AI-specific rules.

### 1.2 Indexability
- Canonical tags: self-referencing, no conflicts with noindex
- Duplicate content: near-duplicates, parameter URLs, www vs non-www
- Thin content: pages below minimums per type
- Pagination: rel=next/prev or load-more
- Index bloat: unnecessary pages consuming crawl budget

### 1.3 Security
- HTTPS enforced, valid SSL, no mixed content
- Headers: CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- HSTS preload for high-security sites

### 1.4 URL Structure
- Clean, descriptive, hyphenated, no query parameters for content
- No redirect chains (max 1 hop), 301 for permanent moves
- Flag >100 character URLs, consistent trailing slashes

### 1.5 Mobile
- Viewport meta tag, responsive CSS, min 48x48px touch targets, 16px base font
- Mobile-first indexing 100% complete (July 5, 2024)

### 1.6 Core Web Vitals
- **LCP** <2.5s, **INP** <200ms (replaced FID March 12, 2024), **CLS** <0.1
- 75th percentile of real user data

### 1.7 Structured Data
- Detection: JSON-LD preferred, Microdata, RDFa
- Validate against Google's supported types

### 1.8 JavaScript Rendering
- CSR vs SSR detection, SPA framework flags (React, Vue, Angular)
- Dec 2025 update: canonical conflicts between raw HTML and JS-injected; noindex in raw HTML may be honored even if JS removes it; no JS rendering on non-200 pages; serve critical SEO elements in initial HTML

### 1.9 IndexNow Protocol
- Support for Bing, Yandex, Naver (not Google)

---

## 2. Content Quality & E-E-A-T

### E-E-A-T Framework (Sept 2025 QRG)
- **Experience:** Original research, case studies, first-hand signals, unique data
- **Expertise:** Author credentials, professional background, technical depth
- **Authoritativeness:** External citations, brand mentions, industry recognition
- **Trustworthiness:** Contact info, privacy policy, HTTPS, reviews, date stamps

### Content Metrics
| Page Type | Min Words |
|-----------|-----------|
| Homepage | 500 |
| Service page | 800 |
| Blog post | 1,500 |
| Product page | 300+ |
| Location page | 500-600 |

Word count = topical coverage floors, NOT targets. Google confirms word count is not a direct ranking factor.

- Readability: Flesch 60-70 for general audience (NOT a Google ranking factor per John Mueller)
- Keywords: primary in title/H1/first 100 words, natural 1-3% density
- Structure: logical H1>H2>H3, scannable sections, TOC for long-form
- Internal links: 3-5 per 1000 words, descriptive anchor text
- External links: cite authoritative sources
- Freshness: publication date, last updated date, flag >12 months without update

### AI Content Assessment (Sept 2025 QRG)
Acceptable: demonstrates E-E-A-T, unique value, human oversight. Low-quality markers: generic phrasing, no original insight, repetitive structure, no author attribution.

Helpful Content System merged into core algorithm (March 2024) -- no longer standalone.

### AI Citation Readiness (GEO)
- Clear quotable statements with statistics
- Answer-first formatting, tables/lists for comparative data
- Structured data for data points, strong heading hierarchy
- Multi-platform tracking: AI Overviews, AI Mode, ChatGPT, Perplexity, Bing Copilot

---

## 3. Image Optimization

### Alt Text
- Present on all `<img>` (except decorative with `role="presentation"`)
- Descriptive, 10-125 chars, natural keywords
- Good: "Professional plumber repairing kitchen sink faucet" / Bad: "image.jpg"

### File Size Thresholds
| Category | Target | Warning | Critical |
|----------|--------|---------|----------|
| Thumbnails | <50KB | >100KB | >200KB |
| Content images | <100KB | >200KB | >500KB |
| Hero/banner | <200KB | >300KB | >700KB |

### Formats
WebP (97%+) default recommendation, AVIF (92%+) best compression, JPEG/PNG fallbacks. Use `<picture>` with AVIF>WebP>JPEG fallback chain. JPEG XL: Chrome restoring support (Rust decoder), not yet stable.

### Performance Attributes
- `loading="lazy"` on below-fold images only (NEVER on LCP/hero images)
- `fetchpriority="high"` on LCP image
- `decoding="async"` on non-LCP images
- `width`/`height` attributes on all `<img>` for CLS prevention
- `srcset` + `sizes` for responsive images

### File Names
Descriptive, hyphenated, lowercase: `blue-running-shoes.webp` not `IMG_1234.jpg`

---

## 4. Sitemap Analysis & Generation

### Analyze Existing
- Valid XML, <50k URLs per file, all URLs return 200
- `<lastmod>` dates accurate (not all identical)
- `<priority>` and `<changefreq>` ignored by Google -- can remove
- Referenced in robots.txt, no noindexed/redirected/non-canonical URLs
- Compare crawled pages vs sitemap for missing pages

### Generate New
1. Detect/ask business type, load industry template
2. Apply quality gates (30+ location page warning, 50+ hard stop)
3. Generate valid XML, split at 50k with sitemap index
4. Safe at scale: integration pages (real docs), templates (downloads), glossary (200+ words), product pages, user profiles
5. Penalty risk: location pages with only city swapped, "[Competitor] alternative" without real data

---

## 5. Hreflang & International SEO

### Validation Checklist
1. **Self-referencing tags** -- every page must hreflang to itself matching canonical URL
2. **Return tags** -- bidirectional (A>B and B>A), full mesh across all variants
3. **x-default** -- required fallback, only one per set
4. **Language codes** -- ISO 639-1 two-letter (`en`, `fr`, `ja` not `eng`, `jp`)
5. **Region codes** -- ISO 3166-1 Alpha-2 (`en-GB` not `en-uk`, no `es-LA`)
6. **Canonical alignment** -- hreflang only on canonical URLs, exact URL match
7. **Protocol consistency** -- all HTTPS, no mixed
8. **Cross-domain** -- works across domains, requires return tags on both

### Common Mistakes
| Issue | Severity |
|-------|----------|
| Missing self-referencing tag | Critical |
| Missing return tags | Critical |
| Missing x-default | High |
| Invalid language/region codes | High |
| Hreflang on non-canonical URL | High |
| HTTP/HTTPS mismatch | Medium |
| Trailing slash inconsistency | Medium |

### Implementation Methods
- **HTML link tags** -- best for <50 variants per page
- **HTTP headers** -- best for non-HTML files (PDFs)
- **XML sitemap** -- best for large sites, cross-domain (include `xmlns:xhtml` namespace, every `<url>` must list ALL alternates)

---

## 6. Single-Page Analysis (`/seo page`)

Analyze one URL across all dimensions:

### On-Page SEO
- Title: 50-60 chars, primary keyword, unique
- Meta description: 150-160 chars, compelling, keyword
- H1: exactly one, matches intent
- H2-H6: logical hierarchy, no skipped levels
- URL: short, descriptive, hyphenated
- Internal/external links: sufficient, relevant anchors

### Technical Elements
- Canonical tag, meta robots, Open Graph (og:title/description/image/url), Twitter Card, hreflang

### Schema on Page
- Detect all types (JSON-LD preferred), validate required properties, identify missing opportunities

### CWV Signals (from HTML)
- Flag potential LCP issues (huge hero images, render-blocking resources)
- Flag potential INP issues (heavy JS, no async/defer)
- Flag potential CLS issues (missing image dimensions)

### Output: Page Score Card
On-Page SEO, Content Quality, Technical, Schema, Images -- each scored XX/100 with prioritized issues and ready-to-use JSON-LD suggestions.

---

## 7. Strategic SEO Planning (`/seo plan`)

### Process
1. **Discovery** -- business type, audience, competitors, goals, KPIs
2. **Competitive Analysis** -- top 5 competitors, content/schema/technical gaps, E-E-A-T comparison
3. **Architecture Design** -- URL hierarchy, content pillars, internal linking, sitemap structure
4. **Content Strategy** -- content gaps, page types, publishing cadence, E-E-A-T building plan
5. **Technical Foundation** -- hosting, schema plan, CWV targets, AI readiness, mobile-first

### Implementation Roadmap (4 Phases)
- **Phase 1 (weeks 1-4):** Technical setup, core pages, essential schema, analytics
- **Phase 2 (weeks 5-12):** Content creation, blog launch, internal linking, local SEO
- **Phase 3 (weeks 13-24):** Advanced content, link building, GEO optimization
- **Phase 4 (months 7-12):** Thought leadership, PR, advanced schema, continuous optimization

### Industry Templates (in `assets/`)
saas.md, local-service.md, ecommerce.md, publisher.md, agency.md, generic.md

### Deliverables
SEO-STRATEGY.md, COMPETITOR-ANALYSIS.md, CONTENT-CALENDAR.md, IMPLEMENTATION-ROADMAP.md, SITE-STRUCTURE.md

---

## 8. Full Audit Workflow (`/seo audit`)

1. Fetch homepage with `scripts/fetch_page.py`
2. Detect business type from homepage signals
3. Crawl site (up to 500 pages, respect robots.txt, 5 concurrent, 1s delay)
4. Delegate to subagents (or run inline sequentially):
   - Technical (crawlability, indexability, security, CWV)
   - Content (E-E-A-T, readability, thin content)
   - Schema (detection, validation, generation)
   - Sitemap (structure, quality gates, missing pages)
   - Images (alt text, formats, sizes, lazy loading)
   - GEO (AI crawler access, llms.txt, citability, brand mentions)
5. Score: aggregate into SEO Health Score (0-100)
6. Report: FULL-AUDIT-REPORT.md + ACTION-PLAN.md

### Report Structure
- Executive Summary (score, business type, top 5 critical issues, top 5 quick wins)
- Technical SEO, Content Quality, On-Page SEO, Schema, Performance, Images, AI Search Readiness
- Each section: findings + prioritized recommendations

---

## 9. GEO — Generative Engine Optimization

Every audit answers TWO questions: Can this site RANK? Can this site get CITED?

### GEO Scoring (10% of overall score)
| Factor | Weight | Pass Criteria |
|--------|--------|---------------|
| AI bot access | 25% | GPTBot, ClaudeBot, PerplexityBot not blocked |
| Content extractability | 25% | Standalone answer blocks (40-60 words) |
| Authority signals | 20% | Statistics with sources, expert attribution |
| Schema density | 15% | FAQ, Article schema on relevant pages |
| llms.txt | 10% | /llms.txt exists with structured description |
| Freshness signals | 5% | "Last updated" dates, current year refs |

### Integration Points
| Section | Traditional | GEO |
|---------|------------|-----|
| Technical | Googlebot crawlability | AI bot access in robots.txt |
| Content | E-E-A-T, keywords | Passage-level citability |
| Schema | Rich snippets | Machine-readable entity data |
| Authority | Backlinks, DA/DR | Third-party citations (Wikipedia, Reddit = 6.5x brand citation rate) |
| Performance | CWV (INP) | llms.txt, structured data density |
| Monitoring | Rankings, clicks | AI citation tracking (Otterly, Peec AI, ZipTie) |

Google AI Mode (May 2025): fully conversational, zero organic links -- AI citation is the only visibility mechanism.

---

## DataForSEO Integration (Optional)

If DataForSEO MCP tools are available, enrich any analysis:
- `serp_organic_live_advanced` -- real SERP positions
- `backlinks_summary` -- backlink data and spam scores
- `on_page_instant_pages` -- status codes, page timing, broken links
- `on_page_lighthouse` -- Lighthouse scores
- `kw_data_google_ads_search_volume` -- keyword volumes
- `dataforseo_labs_bulk_keyword_difficulty` -- difficulty scores
- `dataforseo_labs_search_intent` -- intent classification
- `dataforseo_labs_google_competitors_domain` -- competitive intelligence
- `business_data_business_listings_search` -- local business data
- `domain_analytics_technologies_domain_technologies` -- tech stack detection
