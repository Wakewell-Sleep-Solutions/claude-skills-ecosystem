---
name: content-engine
description: Unified content creation, strategy, and distribution. Use when the user wants to plan content strategy, write copy (headlines, CTAs, landing pages, pricing pages), write articles/guides/blog posts, create social posts, crosspost across platforms, build content calendars, or repurpose content. Triggers on "content strategy," "what should I write about," "content ideas," "blog strategy," "topic clusters," "content planning," "editorial calendar," "content marketing," "write copy for," "improve this copy," "headline help," "CTA copy," "value proposition," "tagline," "hero section," "write an article," "blog post," "guide," "tutorial," "newsletter," "crosspost," "post everywhere," "distribute this," "social posts," "threads," "content calendar," or any content creation/distribution request.
origin: ECC
---

# Content Engine

Unified system for content strategy, copywriting, long-form writing, and multi-platform distribution.

## When to Activate

- Planning what content to create (strategy, pillars, editorial calendar)
- Writing marketing copy (headlines, CTAs, landing pages, pricing pages, feature pages)
- Writing articles, guides, blog posts, tutorials, or newsletter issues
- Creating social posts for X, LinkedIn, TikTok, YouTube, Threads, Bluesky
- Repurposing one asset across multiple platforms
- Crossposting content with platform-native adaptation

## First Questions

Clarify based on the task:
- **What:** source asset, topic, or page type
- **Who:** audience (builders, investors, customers, operators, ICP)
- **Where:** platform or page (website, X, LinkedIn, newsletter, etc.)
- **Why:** goal (awareness, conversion, authority, launch, engagement)
- **Voice:** brand voice references or tone preference

**Check for context first:** If `.agents/product-marketing-context.md` or `.claude/product-marketing-context.md` exists, read it before asking questions.

---

## 1. Content Strategy & Planning

### Searchable vs Shareable

Every piece must be searchable, shareable, or both. Prioritize search -- it captures existing demand.

**Searchable:** target a keyword, match search intent, structure with headings that mirror search patterns, optimize for AI/LLM discovery.

**Shareable:** lead with novel insight or original data, challenge conventional wisdom, tell stories, connect to trends.

### Content Pillars

Identify 3-5 core topics your brand will own. Each spawns a cluster:

```
Pillar Topic (Hub)
+-- Subtopic Cluster 1
|   +-- Article A, B, C
+-- Subtopic Cluster 2
|   +-- Article D, E, F
```

Identify pillars via: product-led (problems solved), audience-led (ICP needs), search-led (volume), competitor-led (gaps).

### Keyword Research by Buyer Stage

| Stage | Modifiers | Example |
|-------|-----------|---------|
| Awareness | "what is," "how to," "guide to" | "What is Agile Project Management" |
| Consideration | "best," "vs," "alternatives" | "Asana vs Trello vs Monday" |
| Decision | "pricing," "reviews," "demo" | "Project Management Tool Pricing" |
| Implementation | "templates," "tutorial," "setup" | "Step-by-Step Setup Tutorial" |

### Content Ideation Sources

1. **Keyword data** -- group by clusters, buyer stage, intent, quick wins
2. **Call transcripts** -- extract questions, pain points, objections, language
3. **Forum research** -- Reddit, Quora, HN, industry communities
4. **Competitor analysis** -- top posts, gaps, outdated content to improve
5. **Sales/support input** -- common objections, repeated questions, success stories

### Prioritizing Ideas

Score on: Customer Impact (40%), Content-Market Fit (30%), Search Potential (20%), Resources (10%).

### Strategy Output

Deliver: 3-5 content pillars with rationale, priority topics with keyword/buyer stage, topic cluster map showing interconnections.

---

## 2. Copywriting

### Principles

1. **Clarity over cleverness** -- if choosing, choose clear
2. **Benefits over features** -- what it means for the customer
3. **Specificity over vagueness** -- "Cut reporting from 4 hours to 15 minutes"
4. **Customer language** -- mirror voice-of-customer from reviews and interviews
5. **One idea per section** -- build logical flow down the page
6. **Honest over sensational** -- no fabricated stats or testimonials

### Writing Style

- Simple over complex ("use" not "utilize")
- Active over passive ("We generate reports" not "Reports are generated")
- Confident over qualified (remove "almost," "very," "really")
- No exclamation points, no marketing buzzwords without substance

### Page Structure

**Above the fold:** Headline (core value prop) + Subheadline (adds specificity) + Primary CTA (action-oriented)

**Headline formulas:**
- "{Achieve outcome} without {pain point}"
- "The {category} for {audience}"
- "Never {unpleasant event} again"

**Core sections:** Social Proof, Problem/Pain, Solution/Benefits, How It Works (3-4 steps), Objection Handling, Final CTA.

### CTA Copy

**Weak:** Submit, Sign Up, Learn More, Click Here
**Strong:** Start Free Trial, Get [Specific Thing], See [Product] in Action

**Formula:** [Action Verb] + [What They Get] + [Qualifier]

### Page-Specific Guidance

- **Homepage:** serve multiple audiences, lead with broadest value prop
- **Landing page:** single message, single CTA, match headline to traffic source
- **Pricing page:** help choose the right plan, make recommended plan obvious
- **Feature page:** connect feature to benefit to outcome
- **About page:** tell why you exist, connect mission to customer benefit

### Copy Output

Deliver: page copy organized by section, annotations explaining choices, 2-3 headline/CTA alternatives with rationale, meta title and description.

---

## 3. Article & Long-Form Writing

### Core Rules

1. Lead with the concrete thing: example, anecdote, number, code block
2. Explain after the example, not before
3. Prefer short, direct sentences
4. Use specific numbers when available and sourced
5. Never invent biographical facts, company metrics, or customer evidence

### Voice Capture

If matching a specific voice, collect published articles, posts, or style guides. Extract: sentence rhythm, formality level, rhetorical devices, humor tolerance, formatting habits. Default: direct, operator-style voice -- concrete, practical, low hype.

### Banned Patterns

Delete on sight:
- "In today's rapidly evolving landscape"
- Filler transitions: "Moreover," "Furthermore"
- Hype: "game-changer," "cutting-edge," "revolutionary"
- Vague claims without evidence

### Structure by Type

**Technical guides:** open with what the reader gets, code examples in every section, concrete takeaways.

**Essays/opinion:** start with tension or sharp observation, one argument thread per section, examples that earn the opinion.

**Newsletters:** strong first screen, mix insight with updates, clear section labels for skimming.

### Article Output

Deliver: polished draft matching voice references, every section adding new information, factual claims verified against sources.

---

## 4. Multi-Platform Content & Distribution

### Core Rules

1. Adapt for the platform -- never cross-post identical copy
2. Hooks matter more than summaries
3. Every post carries one clear idea
4. Use specifics over slogans
5. Keep the ask small and clear

### Platform Guidance

**X:** Open fast, one idea per tweet, keep links out of main body, no hashtag spam. (280 chars, 4000 Premium)

**LinkedIn:** Strong first line (visible before "see more"), short paragraphs, frame around lessons/results/takeaways, 3-5 hashtags. (3000 chars)

**Threads:** Conversational, casual, shorter than LinkedIn, visual-first. (500 chars)

**Bluesky:** Direct, concise, community-oriented, use feeds for targeting. (300 chars)

**TikTok/Short Video:** First 3 seconds interrupt attention, script around visuals, one demo + one claim + one CTA.

**YouTube:** Show result early, structure by chapter, refresh visual every 20-30 seconds.

**Newsletter:** One clear lens per issue, skimmable section titles, opening paragraph doing real work.

### Repurposing Flow

1. Start with anchor asset (article, video, demo, memo, launch doc)
2. Extract 3-7 atomic ideas
3. Write platform-native variants
4. Trim repetition across outputs
5. Align CTAs with platform intent

### Crossposting Workflow

1. **Create source content** -- identify core message, draft primary platform version first
2. **Identify targets** -- which platforms, priority order
3. **Adapt per platform** -- rewrite for each platform's conventions
4. **Post primary** -- capture URL for cross-referencing
5. **Post secondary** -- stagger 30-60 min gaps, include cross-platform references

### Campaign Deliverables

Return: core angle, platform-specific drafts, posting order, CTA variants, missing inputs needed before publishing.

---

## 5. Healthcare Content Compliance

**If creating content for a healthcare/dental practice:**

- Social media with patient photos/videos requires signed HIPAA authorization per platform
- Never confirm patient status in comments -- even if the patient mentioned it first
- Before/after content requires written consent specifying who, where, how
- AI-generated health content: disclose per CA AB 489 (dental), TX TRAIGA (Texas)
- No specific treatment outcomes or guarantees ("guaranteed results," "pain-free")
- FTC requires substantiation for all health claims -- cite sources
- CTA copy should direct to HIPAA-compliant booking systems (not unencrypted forms)
- Patient testimonials require signed consent -- never fabricate or composite
- Staff posting patient content without authorization = criminal HIPAA violation
- Revocation protocol: patients can withdraw consent at any time

> **Cross-reference:** `hipaa-compliance` for PHI framework, `dental-social-media` for photo consent, `ad-creative` for dental ad compliance.

---

## Quality Gate

Before delivering any content:
- Each draft reads natively for its platform or page type
- Hooks are strong and specific
- No generic hype language or filler transitions
- No duplicated copy across platforms unless requested
- CTA matches content and audience
- Factual claims verified against provided sources
- Voice matches supplied examples or brand guidance
- **If healthcare:** no PHI, AI disclosure compliant, photo consent verified, medical claims sourced

## Related Skills

- **copy-editing** -- polish existing copy after drafting
- **seo-audit** / **seo-page** -- technical SEO and on-page optimization
- **ai-seo** -- optimize for AI search engines and LLM citations
- **programmatic-seo** -- scaled content generation
- **schema-markup** -- structured data for rich results
- **x-api** -- X/Twitter API integration for posting
- **email-sequence** -- email copywriting and sequences
- **popup-cro** -- popup and modal copy
