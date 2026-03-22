# Specialist Overlays

## Code Audit (Risk-Based)

**Layer 1 — Automated (zero agents):** Lint, typecheck, secret scan, SAST. Run first.

**Layer 2 — Focused passes (parallel, single-intent each):**

| Risk Level | Passes | Why |
|-----------|--------|-----|
| Critical (auth, crypto, PHI) | Correctness + Security + Reliability | Breach risk |
| High (APIs, business logic) | Correctness + Security | Production-facing |
| Medium (features, UI) | Correctness only | Most bugs are logic |
| Low (config, docs, tests) | Layer 1 only | Delete unnecessary audit |

**Layer 3 — Integration (sequential):** One agent checks if parallel findings conflict.

## Healthcare Overlay

When PHI is involved, add to ALL agent prompts:
- No PHI in logs, errors, URLs, query params
- Encryption at rest (AES-256) + in transit (TLS 1.3)
- BAA verification for third-party services
- Minimum necessary principle
- Audit logging for all PHI access

At Tier 4+, dedicate one agent to compliance review.

## Skill Relevance Scan (Before Every Task)

| Domain | Skill | Invoke when... |
|--------|-------|----------------|
| Security | `owasp-security` | ANY code touches auth, user input, APIs, secrets, MCP, or database |
| Healthcare | `hipaa-compliance` | ANY healthcare/dental/patient data context |
| SEO | `seo-orchestrator` | ANY web content, page creation, or site changes |
| AI SEO | `ai-seo` | ANY content meant to be found by AI search |
| Local SEO | `local-seo` | ANY local business, GBP, Google Maps |
| Frontend | `frontend-design` | ANY UI/component/page building |
| Architecture | `software-architecture` | ANY structural decision affecting multiple modules |
| Reasoning | `think` | ANY non-trivial decision |
| Code audit | `codex` | ANY significant code (50+ lines, or security-sensitive) |
| Testing | `tdd-workflow` | ANY feature implementation or bugfix |
| Context | `pre-flight` | START of any non-trivial task |
| Lessons | `retro` | END of any significant completed work |

**Err on the side of invoking.** Cost of false positives is near-zero; cost of false negatives is real.

### Skill Injection Map (for Agent Prompts)

| Agent Role | Inject These Skills |
|-----------|-------------------|
| Security auditor | `owasp-security` + `hipaa-compliance` (if healthcare) |
| Frontend implementer | `frontend-design` + `vercel-react-best-practices` |
| Architecture reviewer | `software-architecture` |
| SEO work | `seo-orchestrator` + `local-seo` + `ai-seo` |
| Code reviewer | `owasp-security` + domain-specific skill |
| Compliance reviewer | `hipaa-compliance` |
