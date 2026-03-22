---
name: local-seo
description: "Local SEO and Google Business Profile optimization for dental practices. GBP audit, local pack ranking, NAP citation management, review strategy, local schema markup, and AI visibility for local search. Use when user mentions 'local SEO', 'Google Business Profile', 'GBP', 'Google Maps', 'local pack', 'map pack', 'near me', 'NAP', 'citations', 'local rankings', 'dentist near me', 'local search', 'Google Maps ranking', or 'local visibility'. Also triggers on 'why aren't we showing up locally', 'optimize our Google listing', 'local search optimization', or 'how do we rank in maps'."
origin: ECC
---

# Local SEO & Google Business Profile Optimization

For dental practices, local SEO is the #1 patient acquisition channel. 46% of Google searches have local intent. This skill covers GBP optimization, local ranking factors, NAP citation management, review strategy, local schema, and AI visibility for local businesses.


**Step 0:** Read `.claude/context/practice-context.md` for practice overview, brand voice, patient pain points, and proof points before proceeding.
## Ranking Factors (Whitespark 2026 Survey)

| Factor | Weight (Map Pack) | Priority |
|--------|:-----------------:|:--------:|
| Google Business Profile signals | ~32% | **Critical** |
| Review signals (volume, recency, velocity, sentiment) | ~16% | **Critical** |
| On-page SEO (NAP, local content, keywords) | ~13% | High |
| Behavioral signals (clicks, calls, directions) | ~10% | High |
| Link signals (quality local backlinks) | ~9% | High |
| Citation signals (NAP consistency) | ~7% | Medium |
| Social signals (NEW 2026) | ~5% | Medium |
| AI search signals (NEW 2026) | ~5% | Medium |

**Three core pillars: Relevance, Distance, Prominence.**

## GBP Optimization Checklist

### Identity (Highest Impact — Free)
- [ ] Primary category: **"Dentist"** (single strongest signal you control)
- [ ] Secondary categories for services offered (Cosmetic Dentist, Dental Implants Provider, Emergency Dental Service, Orthodontist)
- [ ] Exact legal business name — no keyword stuffing
- [ ] Verified and claimed profile

### Completeness (2.7x more reputable, 50% better consideration)
- [ ] All hours accurate (businesses open at search time rank higher)
- [ ] Every service added (patient language: "teeth whitening" not "bleaching")
- [ ] Booking link to PatientsReach
- [ ] All attributes filled
- [ ] Business description with service + location keywords

### Visual Content
- [ ] 10+ high-quality photos (exterior matching Street View, reception, operatories, team)
- [ ] Add new photos monthly (signals active business)
- [ ] Video tours and procedure explainers

### Q&A Section
- [ ] Pre-populate top 10-15 patient questions (insurance, sedation, emergency, parking, languages)
- [ ] Monitor and answer new questions within 24 hours

### GBP Posts (Weekly — Posts Expire After 7 Days)
- [ ] Service highlights, seasonal promotions, community involvement
- [ ] Keyword-rich content with high-quality image
- [ ] Always include CTA button (Book, Call, Learn More)

## Review Strategy

**Benchmarks:** Top practices: ~32 new reviews/month. 200+ reviews at 4.8+ stars = 2x revenue.

**Velocity over volume:** Steady stream (1+/week minimum) beats bursts then silence. Google penalizes inconsistent patterns in 2026.

**Review content matters for AI:** AI reads sentiment, specific service mentions, and location context. Reviews mentioning "dental implants" or "emergency care" feed hyperlocal signals.

**Optimal generation:** Automated SMS 3-6 PM post-appointment + personal staff ask at checkout. 70% of patients leave reviews when asked.

→ Cross-reference: `dental-reputation` skill for HIPAA-compliant response templates and full protocol

## NAP Citation Management

### Master NAP Record
Create a single source of truth document with exact formatting:
- Name, Address, Phone, Website (NAPW)
- Standardize format: "Street" vs "St.", "Suite" vs "Ste." — pick one, use everywhere

### Priority Directories (Dental)
1. Google Business Profile (primary)
2. Apple Maps / Apple Business Connect
3. Bing Places
4. Healthgrades
5. Yelp
6. Facebook Business
7. Zocdoc
8. WebMD
9. Data aggregators: Data Axle, Foursquare, Neustar
10. State dental board listings

### Call Tracking
- One primary local number across all citations
- Dynamic number insertion (DNI) on website only
- If using tracking number in GBP, put as secondary — primary stays canonical

### Audit Cadence
- Quarterly citation audits (BrightLocal, Moz Local, or Yext)
- Fix duplicates and ghost profiles first
- Re-validate annually

## Local Schema Markup

Use `Dentist` type (not generic `LocalBusiness`). 81% of local businesses lack this — huge competitive edge. Practices with complete schema: average 156% increase in Maps visibility within 90 days.

### Required Schema
```json
{
  "@context": "https://schema.org",
  "@type": "Dentist",
  "name": "5D Smiles",
  "address": { "@type": "PostalAddress", "streetAddress": "...", "addressLocality": "...", "addressRegion": "CA", "postalCode": "..." },
  "telephone": "+1-XXX-XXX-XXXX",
  "url": "https://5dsmiles.com",
  "geo": { "@type": "GeoCoordinates", "latitude": "...", "longitude": "..." },
  "openingHoursSpecification": [...],
  "priceRange": "$$",
  "sameAs": ["social profiles", "directory listings"]
}
```

### Additional Schema
- **FAQPage** on service pages (feeds voice search + AI Overviews)
- **Service** nested within Dentist block per treatment
- **MedicalProcedure** for specific treatments (implants, All-on-4)
- **AggregateRating** for review stars in SERPs

→ Cross-reference: `schema-markup` skill for full implementation

## AI Visibility for Local Businesses

**Do local businesses get cited by AI?** Yes:
- 40% of AI Overview citations point to individual local business websites
- 60% cite third-party platforms (Yelp, Healthgrades, Reddit)
- AI reads review text (not just stars) for recommendation signals
- GBP is your "new homepage" for AI — it's the canonical source AI checks first

**Optimization steps:**
1. FAQ pages answering patient questions in conversational language
2. Schema markup (Dentist, Service, FAQPage)
3. Q&A platform participation (Reddit dental threads, Quora)
4. Entity consistency across all platforms
5. Content: lead with facts in first 25 words after each heading (44.2% of citations from first 30%)

→ Cross-reference: `ai-seo` skill for full GEO strategy

## On-Page Strategy

### Service Pages
- One dedicated page per major service (implants, All-on-4, Invisalign, veneers, emergency)
- H1 with service + location naturally
- FAQ section, CTA to booking, before/after photos
- Patient language, not clinical jargon

### Local Landing Pages
- Unique substantive page per target city/neighborhood
- NOT thin doorway pages — include directions, landmarks, community content
- Unique `Dentist` schema per location page

### Technical Requirements
- Mobile-first (60%+ dental searches are mobile)
- Core Web Vitals compliance (<3s load)
- HTTPS mandatory
- One H1 per page

## Local Link Building

**Highest-value links for dental:**
- Local Chamber of Commerce
- Dental society/association memberships
- Local event sponsorships (community runs, school partnerships)
- Local news features and earned media
- Podcast appearances (builds entity authority)

**Benchmark:** 20+ quality local backlinks → 83% more likely to appear in Map Pack.

## Common Mistakes

1. Treating GBP as afterthought (60% of dental practices never post)
2. One-and-done SEO (it's an ongoing system, not a project)
3. No structured review generation system
4. NAP inconsistencies across directories
5. Missing geographic signals in meta titles and content
6. Only using primary GBP category (27% miss visibility without secondaries)
7. Tracking impressions instead of calls, bookings, and directions
8. Ignoring AI search (44.4% of queries now show AI Overviews)

## Implementation Priority

1. GBP audit and full optimization (highest impact, free)
2. Review generation system (automated SMS + staff ask)
3. Schema markup (Dentist type with services, FAQ)
4. NAP citation audit and cleanup
5. Service page optimization (one per major service)
6. Local landing pages (per target city)
7. Weekly GBP posting cadence
8. Local link building
9. AI/GEO optimization
10. Ongoing monitoring

## Integration Points

- **dental-reputation:** Reviews are #2 local ranking factor
- **dental-social-media:** GBP posts, social signals now ~5% of ranking
- **seo-orchestrator:** Local SEO is a module within full site audits
- **ai-seo:** AI visibility for local businesses
- **schema-markup:** Dentist + FAQPage + Service schema
- **n8n-workflows:** Automate review requests and GBP posting
- **hipaa-compliance:** Review responses must avoid PHI
