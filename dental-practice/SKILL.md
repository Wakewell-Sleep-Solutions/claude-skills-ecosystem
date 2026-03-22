---
name: dental-practice
description: "Comprehensive dental practice management: analytics/KPIs, finance/tax, HR/staffing, presentations, reputation/reviews, social media, and email marketing. Use when user mentions 'KPIs', 'analytics', 'dashboard', 'production numbers', 'overhead', 'collection rate', 'case acceptance', 'no-show rate', 'patient lifetime value', 'marketing ROI', 'cost per acquisition', 'revenue cycle', 'GA4', 'attribution', 'morning huddle', 'practice metrics', 'P&L', 'profit and loss', 'taxes', 'tax planning', 'depreciation', 'Section 179', 'QBI', '199A', 'S-Corp', 'entity structure', 'cash flow', 'accounts receivable', 'insurance negotiation', 'fee schedule', 'PPO fees', 'practice valuation', 'EBITDA', 'budget', 'CPA', 'hiring', 'staffing', 'job description', 'onboarding', 'employee handbook', 'performance review', 'salary', 'compensation', 'benefits', 'turnover', 'retention', 'firing', 'non-compete', 'HR', 'presentation', 'slides', 'deck', 'lecture', 'CE presentation', 'case presentation', 'review', 'reviews', 'reputation', 'star rating', 'Google reviews', 'negative review', 'review response', 'online reputation', 'social media', 'Instagram', 'TikTok', 'Facebook post', 'LinkedIn', 'content calendar', 'Reels', 'GBP posts', 'email marketing', 'email campaign', 'newsletter', 'reactivation', 'recall', 'nurture sequence', 'drip campaign', 'email automation', 'insurance reminders', 'year-end benefits', 'referral emails', or 'email ROI'."
origin: ECC
---

# Dental Practice Management

Data-driven dental practices grow 2-3x faster. This skill covers analytics, finance, HR, presentations, reputation, social media, and email marketing.

**Step 0:** Read `.claude/context/practice-context.md` for practice overview, brand voice, patient pain points, and proof points before proceeding.

---

## 1. ANALYTICS & KPIs

### Financial KPIs

| KPI | Target | Average | Fix If |
|-----|:------:|:-------:|:------:|
| Overhead ratio | 55-60% | 60-65% | >70% |
| Net collection rate | 98%+ | 92-95% | <90% |
| Production/provider/hour | $600-700+ | $350-600 | <$350 |
| Profit margin | 40%+ | 30-40% | <25% |

**Overhead breakdown targets:** Staff 25-30%, Facility 7-10%, Supplies 4-7%, Lab 4-7%, Marketing 5-10% (growth: 10-15%).

### Operational KPIs

| KPI | Target | Average | Fix If |
|-----|:------:|:-------:|:------:|
| Case acceptance rate | 70-90% | 50-60% | <40% |
| New patients/month | 50-80+ | 47 | <19 |
| No-show rate | <5% | 6.2% | >10% |
| Schedule utilization | 85-90% | 75-80% | <70% |

### Revenue Cycle Management

| Metric | Target | Problem |
|--------|:------:|:-------:|
| Days in AR | <30 | >50 |
| Claims denial rate | <3% | >10% |
| AR over 90 days | <10% | >20% |

**Warning:** After 60 days, collection likelihood drops below 10%.

### Patient Lifetime Value

```
PLV = Avg Visit Value x Visits/Year x Retention Years
Full PLV = PLV + (PLV x Avg Referrals Per Patient)
Example: $400 x 2.5 x 8yrs = $8,000; with 2 referrals = $24,000
Max Acquisition Spend = PLV x Profit Margin = $8,000 x 30% = $2,400
```

### Marketing Attribution

| Channel | CPA Range | Best For |
|---------|:---------:|----------|
| Referrals | <$50 | Highest-value patients |
| Organic SEO | $50-100 | Long-term compounding |
| Google Ads | $65-135/lead | Immediate visibility |
| Social media (paid) | $200-400 | Awareness |
| Implant PPC | $250-500 | Justified by high procedure value |

**LTV:CAC targets:** 3:1 break-even, 5:1 healthy, 10:1 exceptional. Average patient journey: 7 touchpoints, 45 days.

### GA4 Setup

Essential conversion events: form submissions, phone call clicks, call tracking (CallRail), chat widget, booking widget (PatientsReach), directions clicks. Use GTM, not direct install. Link Search Console and Google Ads.

### Dashboard Cadence

- **Daily (huddle):** Scheduled production vs goal, open chair time, unconfirmed appointments
- **Weekly:** New patients booked, case acceptance, no-show rate, production per provider
- **Monthly:** Total production/collections, overhead ratio, CPA by channel, AR aging
- **Quarterly:** PLV trends, LTV:CAC by channel, staff productivity, YoY growth

### Key Formulas

```
Overhead Ratio = Total Overhead / Total Collections
Collection Rate = Total Collections / Total Production
Hygiene Ratio = Hygiene Production / Hygiene Wages (target 3.5:1)
CPA = Total Marketing Spend / New Patients Acquired
Marketing ROI = (Revenue from Marketing - Cost) / Cost
```

### HIPAA Analytics Rules

- Never track individual patient journeys in GA4 -- use Freshpaint (HIPAA proxy) or aggregate-only
- No PHI in UTM parameters, conversion events, or campaign URLs
- Third-party pixels (Meta, Google Ads): NEVER fire on pages containing PHI
- Every analytics tool touching patient data MUST have a signed BAA

---

## 2. FINANCE & TAX

### P&L Benchmarks

Median gross billings: $942,290/yr per general dentist (2024). Average net income: $207,980. EBITDA margins: 15-25% (average), 25-35% (high-performing).

### Cash Flow / A/R Targets

| Metric | Target | Problem |
|--------|:------:|:-------:|
| Days in A/R | 10 (best) | >45 |
| Collection rate | 98%+ | <90% |
| A/R over 60 days | <10% | >20% |

**Collection priority:** (1) Collect co-pays at time of service, (2) File electronic claims within 24-48hrs, (3) Verify insurance BEFORE appointments, (4) Automate patient billing, (5) Weekly A/R aging reviews, (6) Maintain 3-6 months cash reserves.

### Tax Optimization (2026 Post-OBBBA)

- **100% Bonus Depreciation** -- permanently restored. New AND used assets. No dollar cap. Example: $250K CBCT scanner = ~$92,500 savings at 37%.
- **Section 179** -- expanded to $2.5M permanent ($2.56M inflation-adjusted 2026). Cannot reduce below zero.
- **Section 199A QBI** -- made permanent. Dental = SSTB. Phase-outs: $201,775 (single) / $403,550 (MFJ). S-Corp salary optimization: set at 28.571% of QBI to maximize deduction.
- **Student loan repayment** -- employer contributions up to $5,250/yr tax-free, permanent.

### Entity Structure

| Situation | Best Structure |
|-----------|---------------|
| New/low revenue | LLC (sole prop) |
| Established, profitable | LLC taxed as S-Corp |
| High earner ($500K+) | S-Corp + cash balance pension |
| Multi-location/DSO | Multi-entity S-Corp or C-Corp |

### Insurance Fee Schedule Negotiation

20%+ reimbursement increase possible. Set UCR fees at 80th-90th percentile. Focus top 20-30 codes by volume. Leverage patient volume and competing network rates. Renegotiate every 24 months. Consider firms: Apex Reimbursement, Veritas Dental Resources.

### Practice Valuation

| Buyer | EBITDA Multiple |
|-------|:--------:|
| Solo doctor-to-doctor | 1.8-4x |
| Mid-market general | 4-6x |
| DSO add-on | 5-8x |
| DSO platform deal | 9-11x |

Premium drivers: overhead <60%, recurring hygiene base, multi-location, strong payer mix, provider depth.

### Finding a Dental CPA

Look for dental-specific experience, year-round tax planning, QBI/199A SSTB expertise, retirement plan design. Directory: ADCPA (adcpa.org). Notable: Dental CPA USA, Edwards & Associates, Tooth & Coin, DrillDown Solution.

---

## 3. HR & STAFFING

**Crisis:** Only 68% of practices adequately staffed. 95% struggle to recruit hygienists. Turnover costs 0.5-2x annual salary.

### Salary Benchmarks (2024-2026)

| Role | National Median | Entry |
|------|:-:|:-:|
| Dental Hygienist | $94,260/yr | $72K |
| Dental Assistant | $47,300/yr | $35-38K |
| Front Desk | $40K ($19.35/hr) | $35K |
| Office Manager | $66,232/yr | $50K |

Staff salaries should be 25-30% of collections.

### Hiring Checklist

1. Qualifications verification (education, licensure, certifications)
2. Software proficiency assessment (Dentrix, Eaglesoft, Open Dental)
3. Cultural fit interview (separate from skills)
4. Reference check + background check
5. Offer letter with at-will language

### Onboarding (90-Day Plan)

| Training | Deadline | Penalty |
|----------|:--------:|:-------:|
| OSHA | Within 10 days of hire | $16K-$70K/citation |
| HIPAA | First 1-2 weeks | Up to $1.5M |
| Annual refresher | Every 12 months | Same penalties |

Week 1: OSHA + HIPAA + software orientation. Weeks 2-4: shadow experienced staff. Day 30-60: increasing independence. Day 60-90: full patient load + formal evaluation.

### Retention Strategies

- Competitive pay (annual market rate review via DentalPost survey)
- Benefits packages (92% of hygienists now expect benefits)
- Flexible scheduling (4-day weeks = 15% satisfaction increase)
- Career pathways (DA to hygienist, OM to practice administrator)
- Recognition programs (45% less likely to leave after 2 years)
- Monthly 1:1s, quarterly reviews, SMART goals

### Employment Law Basics

- **Non-competes:** FTC ban vacated; state variation matters (CA bans entirely). Non-solicitation clauses remain enforceable.
- **Overtime:** Qualifying OT exempt from federal income tax 2025-2028 (OBBBA). Misclassification triggers back taxes.
- **Employee handbook:** Must cover at-will statement, anti-harassment, HIPAA, compensation, PTO, disciplinary procedures, social media policy.

### HR Software

Best combo for dental: **HR for Health** (compliance, OSHA/HIPAA) + **Gusto** (payroll/benefits, $80/mo + $12/person).

---

## 4. PRESENTATIONS

### Slide Design Principles

- One idea per slide, 28pt headlines, max 2-4 bullets
- 10-minute rule: break content every 10 min with interaction
- 40%+ white space, real practice photos (no clipart)

### Presentation Types

**CE Lecture (45-60 min, 30-40 slides):** Disclosures (ADA CERP 2026: simplified to 5 standards/17 criteria), learning objectives, literature review with case breaks every 10 min, before/after cases, technique walkthrough, complications, takeaways, references, Q&A.

**Patient Education Seminar (20-30 min, 15-20 slides):** Practice intro, problem framing in patient language, treatment options with visuals, before/after, process walkthrough, financing, testimonials (video preferred), CTA with QR code to booking. Treatment acceptance: 60-85% with visuals vs 40-50% without.

**Staff Training (15-30 min, 10-20 slides):** Protocol review, new procedure, step-by-step workflow, common mistakes, quiz (required for OSHA compliance).

**Case Presentation (10-15 min, 8-12 slides):** De-identified per HIPAA. Demographics, chief complaint, imaging, treatment plan, sequence, outcome, learning points.

### Tools

Reveal.js (free, self-hosted), Gamma (AI-generated), Beautiful.ai ($12/mo), Canva (quick visuals), PowerPoint + Copilot ($20/mo). Use `white` theme for patient-facing, `black` for clinical/CE.

### HIPAA for Clinical Photos

Written consent required specifying WHO/WHERE/HOW. De-identification checklist: crop tightly (teeth/gums only), remove name tags/date stamps, strip EXIF metadata, store on encrypted platform. Patients can revoke consent at any time.

---

## 5. REPUTATION & REVIEWS

- 95% of patients read reviews before booking; 75% require 4+ stars
- 200+ reviews at 4.8+ stars = 50-75% more new patients monthly
- One-star increase = 5-9% more consultation bookings

### HIPAA Review Response Rules

**Never confirm or deny that a reviewer is or was a patient.** Prohibited: patient names, "you/your" referencing visits, dates of service, treatment details. Use generic, policy-based language. Move conversation offline.

### Response Templates

- **Positive:** "Thank you for sharing your feedback. We are pleased to hear about this positive experience!"
- **Negative:** "We appreciate this feedback and are committed to providing the best care possible. Due to federal privacy regulations, concerns cannot be addressed online. Please contact us at [phone/email]."
- **Neutral:** "Thank you for this feedback. We welcome the opportunity to discuss any concerns -- please reach out to our office."

### Negative Review Protocol

1. Alert office manager within 1 hour
2. Generate HIPAA-compliant draft response
3. Two-person compliance review before posting
4. Post response moving conversation offline
5. Direct outreach via phone or secure channel
6. If fake/defamatory: initiate platform removal request

### Review Generation

Optimal pattern (6x more reviews than automation alone): (1) In-person ask at checkout, (2) Auto-trigger SMS 1-2 hrs post-appointment, (3) Direct Google review link, (4) Single 24hr follow-up reminder. Target: 15+ new reviews/month. Never review-gate.

### Platform Priority

Google (63% traffic, 80% effort), Yelp (do NOT solicit -- Yelp penalizes), Healthgrades (claim each provider profile), Facebook (community/referral), Zocdoc (verified reviews).

---

## 6. SOCIAL MEDIA

- 78% of patients check social media before booking
- Before/after transformations get 340% more engagement
- Google indexes social content for AI search citations

### Platform Strategies

| Platform | Frequency | Best For |
|----------|-----------|----------|
| Instagram | 2-3 posts/wk + 3-5 Stories | Cosmetic/elective, Reels (7-15s) |
| TikTok | 2-5 posts/wk | Viral reach, Gen Z, myth-busting |
| Facebook | 3-4 posts/wk | Community, family dentistry, ads |
| LinkedIn | Weekly | Professional, high-value patients |
| GBP | Weekly (posts expire 7 days) | Highest local SEO ROI, free |

### Weekly Content Calendar

| Day | Content | Platform |
|-----|---------|----------|
| Mon | Educational tip / oral hygiene hack | IG Reel + FB |
| Tue | Before/after transformation (with consent) | IG carousel + FB |
| Wed | Behind-the-scenes / meet the team | TikTok + IG Story |
| Thu | Patient testimonial video | FB + LinkedIn |
| Fri | Fun/humor/myth-busting | TikTok + IG Reel |
| Sat | Service highlight or promo | GBP |

### Monthly Themes

Jan: new smile goals. Feb: Valentine makeovers + Children's Dental Health Month. Apr: Oral Cancer Awareness. May: Dental Hygiene Month. Jul/Aug: back-to-school. Oct: Halloween candy tips. Nov/Dec: use-it-or-lose-it insurance.

### Hashtag Strategy (Three-Tier)

1. **Branded:** #5DSmilesDental, #SmileWith5DSmiles
2. **Treatment:** #DentalImplants, #AllOn4, #SmileMakeover
3. **Local:** #DowneyDentist, #LADentalImplants

### HIPAA Photo/Video Consent

Written consent mandatory specifying WHO/WHERE/HOW. Full-face images, tattoos, scars = PHI. Patients can revoke anytime. Penalties up to $50K/violation. Safe content (no consent needed): general tips, team highlights, office tours, promos.

### AI Search via Social

Video/audio indexed by AI engines -- speak target keywords naturally. Entity consistency (name, address, services) identical across all platforms. Reddit and LinkedIn prioritized by Google/Perplexity as high-authority sources.

---

## 7. EMAIL MARKETING

Email delivers ~$36 ROI per $1 spent -- highest-ROI channel for dental.

### Core Sequences

**New Patient Welcome (4 emails / 2 weeks):** Day 0 welcome + what to expect, Day 2 pre-visit prep, post-visit thank you + care instructions, +7 days review request.

**Post-Treatment Follow-Up (undecided patients -- $500K-$1M in idle plans):** 24hrs care instructions, 3-5 days "any questions?", 1wk educational content, 2wks testimonial, 4wks financing options, 6wks final nudge. Segment by treatment type (CDT-code triggered).

**Reactivation (lapsed 18+ months -- $500K-$1.5M inactive):** Day 1 SMS, Day 4 email, Day 10 phone call, Day 21 email #2, Day 35 postcard. 4-5 touches = 81% more reactivation. Case study: 1,000 patients reactivated = $220K collections.

**Year-End Insurance (Sept-Nov):** Sept soft reminder, Oct weekly email+SMS, early Nov urgency, late Nov final call. 40%+ of FSA holders forfeit benefits.

**Referral Request:** Embed in post-visit sequence. Quarterly standalone campaigns. Incentives: free whitening, treatment credits, digital gift cards.

### HIPAA + CAN-SPAM Rules

**Safe to send (no authorization):** Appointment reminders, care coordination, treatment-related info, general educational newsletters (no PHI-based targeting).

**Requires written authorization:** Third-party-funded marketing, emails targeting based on PHI (e.g., implant content only to patients with missing teeth).

**Hard rules:** Use HIPAA-compliant platforms with BAA. Encrypt any email with PHI. Never use Gmail/Yahoo for patient comms. No PHI in subject lines. Include unsubscribe + physical address. Mailchimp/HubSpot free tiers will NOT sign BAA.

### Tools

| Need | Tool | HIPAA? |
|------|------|:------:|
| Dental all-in-one | RevenueWell (~$189/mo) | Yes |
| Advanced automation | ActiveCampaign (~$15/mo, BAA available) | Yes |
| All-in-one comms | Weave (~$249/mo) | Yes |
| Budget/simple (non-PHI only) | Mailchimp (free/$13/mo) | No |

### Benchmarks

| Metric | Healthcare Avg | Target |
|--------|:-:|:-:|
| Open rate | 43.46% | 45%+ |
| Click rate | 2.09% | 3%+ |
| Click-to-open rate | 6.81% | 8%+ |
| Unsubscribe rate | 0.22% | <0.3% |

Note: Apple MPP inflates open rates. Focus on click rate and CTOR as reliable metrics. Subject lines under 50 chars. 55-60% of opens are mobile.

---

## Cross-Domain Integration

- **Analytics + Finance:** CPA/channel metrics (analytics) complement P&L/cash flow (finance)
- **HR + Analytics:** Staff productivity ratios feed overhead calculations
- **Reputation + Social:** 5-star reviews repurposed as social proof content
- **Email + Reputation:** Review request embedded in post-visit email sequence
- **Presentations + Social:** Repurpose slides as Instagram carousel content
- **All domains:** HIPAA compliance required -- every vendor handling patient data needs a BAA
