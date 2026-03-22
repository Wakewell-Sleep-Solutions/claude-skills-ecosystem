# Core Web Vitals Thresholds (March 2026)

## Metrics

### LCP (Largest Contentful Paint)
Measures loading performance — time until the largest visible content element renders.
- **Good:** < 2.5s
- **Needs Improvement:** 2.5s - 4.0s
- **Poor:** > 4.0s

### INP (Interaction to Next Paint)
Measures responsiveness — latency of all user interactions throughout the page lifecycle.
Replaced FID (First Input Delay) in March 2024.
- **Good:** < 200ms
- **Needs Improvement:** 200ms - 500ms
- **Poor:** > 500ms

### CLS (Cumulative Layout Shift)
Measures visual stability — sum of unexpected layout shift scores during page life.
- **Good:** < 0.1
- **Needs Improvement:** 0.1 - 0.25
- **Poor:** > 0.25

## Assessment Rules
- A page passes CWV if all three metrics are "Good" at the 75th percentile (p75).
- CWV is a ranking signal in Google Search (mobile and desktop).
- Field data (real users) takes precedence over lab data for ranking.

## Measurement Tools

| Tool | Data Type | Use Case |
|------|-----------|----------|
| **Chrome UX Report (CrUX)** | Field | Origin-level and URL-level real-user data; powers Search Console report |
| **PageSpeed Insights** | Field + Lab | Quick per-URL check; shows CrUX field data + Lighthouse lab audit |
| **Lighthouse** | Lab | Detailed audit with optimization suggestions; CI integration |
| **web-vitals JS library** | Field | In-page measurement; send to your own analytics endpoint |
| **Chrome DevTools (Performance panel)** | Lab | Deep debugging of individual interactions and layout shifts |
| **Search Console (CWV report)** | Field | Site-wide trends; groups URLs by status; alerts on regressions |

## Common Fixes by Metric

**LCP:** Preload hero image/font, use `fetchpriority="high"`, eliminate render-blocking resources, server-side render above-the-fold content.

**INP:** Break long tasks (>50ms) with `scheduler.yield()`, defer non-critical JS, reduce DOM size, avoid layout thrashing in event handlers.

**CLS:** Set explicit `width`/`height` on images/video, use `aspect-ratio` CSS, avoid injecting content above the fold after load, preload web fonts with `font-display: swap`.
