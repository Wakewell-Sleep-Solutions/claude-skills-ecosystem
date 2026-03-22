---
name: software-architecture
description: "Software architecture and system design patterns. Clean Architecture, SOLID, DDD, microservices vs monolith decisions, API design, database modeling. Use when user mentions 'architecture', 'system design', 'SOLID', 'clean architecture', 'design patterns', 'microservices', 'monolith', 'API design', 'database schema', 'refactor architecture', or when making structural decisions that affect multiple modules."
origin: ECC
---

# Software Architecture

Systematic approach to architectural decisions. Evidence-based, not dogmatic.

## Core Principle: Architecture Is About Tradeoffs

Every architectural choice is a tradeoff. There are no universally "correct" patterns — only patterns that fit constraints. The skill is matching pattern to context.

## Decision Framework

Before choosing any pattern, answer:
1. **What are the actual constraints?** (team size, scale, compliance, timeline)
2. **What changes most often?** (protect those boundaries)
3. **What's the blast radius of a wrong choice?** (reversible vs irreversible)
4. **What's the simplest thing that could work?** (Elon Step 3)

## SOLID Principles (When They Help, When They Hurt)

| Principle | Use When | Skip When | Evidence |
|-----------|----------|-----------|----------|
| **S**ingle Responsibility | Module has multiple reasons to change | Premature split creates 50 tiny files | Google internal study: smaller files = faster reviews |
| **O**pen/Closed | Building plugin/extension systems | Simple CRUD with no variants | Over-abstraction is the #1 complaint in enterprise code |
| **L**iskov Substitution | Inheritance hierarchies exist | Using composition (no inheritance) | Composition > inheritance in practice |
| **I**nterface Segregation | Clients use different subsets of an API | API is small and cohesive | Fat interfaces are a code smell signal |
| **D**ependency Inversion | Need to swap implementations (DB, API, test doubles) | One implementation forever | DI overhead is only justified if you actually swap |

**The meta-rule:** Apply SOLID when it reduces future change cost. Skip it when it adds abstraction without reducing change cost.

## Architecture Patterns

### Monolith vs Microservices

| Factor | Monolith Wins | Microservices Win |
|--------|--------------|-------------------|
| Team size | 1-10 engineers | 20+ engineers (Conway's Law) |
| Deployment | Single deploy, simple | Independent deploy per service |
| Data consistency | Transactions are easy | Saga pattern, eventual consistency |
| Debugging | Single process, stack traces | Distributed tracing required |
| Performance | No network overhead between modules | Horizontal scaling per service |
| Healthcare/HIPAA | Simpler compliance surface | PHI boundary isolation possible |

**Default:** Start monolith, extract services at pain points. Premature microservices is the #1 architecture mistake for small teams.

**Empirical evidence (2025-2026):**
- CNCF 2025 survey: **42% of organizations that adopted microservices are consolidating back** to larger deployable units
- Amazon Prime Video: **90% infrastructure cost reduction** moving from microservices to monolith
- Cost comparison: modular monolith ~$15K/month vs microservices ~$40-65K/month at enterprise scale
- **90% of microservices teams** have a "distributed monolith" anti-pattern (batch deploying everything together)
- Team size thresholds: <10 devs = monolith, 10-30 = modular monolith, 30+ = consider microservices
- Shopify, Airbnb, GitHub all scaled as modular monoliths

### Clean Architecture (Ports & Adapters)

```
[External] → [Adapters] → [Use Cases] → [Domain/Entities]
                                              ↑
                                     (dependencies point inward)
```

**When to use:** Business logic is complex and needs isolation from infrastructure.
**When to skip:** Simple CRUD apps. The ceremony isn't worth it.

### Event-Driven Architecture

**When to use:** Multiple systems need to react to the same event, async processing, audit trails.
**When to skip:** Simple request-response flows. Events add debugging complexity.

### CQRS (Command Query Responsibility Segregation)

**When to use:** Read and write patterns are fundamentally different (high-read, low-write).
**When to skip:** Read/write patterns are similar. CQRS doubles your model surface area.

## API Design Checklist

- [ ] RESTful resource naming (nouns, not verbs)
- [ ] Consistent error format across all endpoints
- [ ] Pagination on all list endpoints
- [ ] Versioning strategy (URL path vs header)
- [ ] Rate limiting with clear headers
- [ ] Authentication on every endpoint (no "we'll add it later")
- [ ] Input validation at the boundary (never trust client data)
- [ ] Idempotency keys for mutation operations
- [ ] HATEOAS links where they add discoverability value

## Database Design Checklist

- [ ] Primary keys: UUIDs for distributed systems, auto-increment for single DB
- [ ] Indexes on all foreign keys and frequently queried columns
- [ ] No N+1 query patterns (use JOINs or batch loading)
- [ ] Soft deletes for audit-required data (healthcare: never hard delete PHI)
- [ ] Migration strategy: forward-only, backward-compatible
- [ ] Connection pooling configured appropriately
- [ ] Query timeout set (prevent long-running queries from blocking)

## Healthcare-Specific Architecture

- [ ] PHI storage isolated (separate DB/schema, not mixed with non-PHI)
- [ ] Audit log as append-only, separate from application DB
- [ ] Encryption at column level for PHI (not just disk encryption)
- [ ] Access control at data layer (not just API layer)
- [ ] BAA-covered infrastructure for all PHI paths
- [ ] Data retention policies enforced at DB level
- [ ] Backup encryption and access logging

## Domain-Driven Design (DDD)

Use DDD when: business logic is complex, multiple teams own different domains, or the domain model is the competitive advantage.
Skip DDD when: simple CRUD apps, small teams, or the domain is well-understood and stable.

**Core DDD Concepts:**
- **Bounded Context:** A boundary around a domain model where terms have specific meaning. One team's "User" is different from another's. Map contexts explicitly.
- **Aggregates:** Cluster of entities treated as a unit for data changes. One aggregate root controls access. Keep aggregates small — large aggregates = lock contention.
- **Value Objects:** Immutable, defined by attributes not identity. Money(100, "USD") not a database row. Use for anything with no lifecycle.
- **Domain Events:** Something that happened that domain experts care about. "AppointmentScheduled", "ClaimDenied". Use for cross-context communication.
- **Ubiquitous Language:** The code uses the same terms as the business. If the domain expert says "referral" don't call it "lead" in code.
- **Context Mapping:** How bounded contexts relate — Shared Kernel, Customer-Supplier, Anti-Corruption Layer, Conformist, Separate Ways.
- **Anti-Corruption Layer:** Translation layer between your context and an external system. Prevents external models from leaking into your domain.

**DDD Decision Checklist:**
- [ ] Are bounded contexts identified and documented?
- [ ] Does each context have a single owning team?
- [ ] Are aggregate boundaries drawn around consistency requirements?
- [ ] Is the ubiquitous language consistent between code and domain experts?
- [ ] Are context integrations explicit (events, APIs, shared kernel)?

## Architecture Decision Record (ADR) Template

For irreversible or high-impact decisions, document with this template:

```
# ADR-[number]: [Decision Title]
**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** [YYYY-MM-DD]
**Context:** What is the issue or force motivating this decision?
**Decision:** What is the change we are making?
**Alternatives Considered:**
  1. [Option A] — Pros: [X] / Cons: [Y]
  2. [Option B] — Pros: [X] / Cons: [Y]
**Consequences:** What becomes easier or harder because of this decision?
**Review Date:** [When to revisit this decision]
```

Use ADRs for: database schema changes, API contract changes, auth architecture, service boundary decisions, framework choices. Skip for: config changes, dependency updates, UI tweaks.

## Non-Functional Requirements Matrix (MANDATORY Before Pattern Choice)

Before choosing ANY architecture pattern (monolith, microservices, serverless, etc.), define your NFRs first. The pattern follows the requirements, not the other way around.

```
## NFR Matrix — Complete Before Architecture Decision
| Requirement | Target | Measurement | Priority |
|------------|--------|-------------|----------|
| Availability | [99.9%? 99.99%?] | Uptime monitoring | [P0/P1/P2] |
| Latency p99 | [<200ms? <1s?] | APM/tracing | [P0/P1/P2] |
| Throughput | [100 rps? 10K rps?] | Load testing | [P0/P1/P2] |
| Data consistency | [Strong? Eventual?] | By design | [P0/P1/P2] |
| Recovery time (RTO) | [<1hr? <4hr?] | Disaster recovery drill | [P0/P1/P2] |
| Data loss tolerance (RPO) | [0? <15min?] | Backup frequency | [P0/P1/P2] |
| Compliance | [HIPAA? SOC2? PCI?] | Audit | [P0/P1/P2] |
| Team size/structure | [1 team? 3 teams?] | Conway's Law | [context] |
| Deploy frequency | [Daily? Weekly?] | CI/CD pipeline | [P0/P1/P2] |
| Budget | [$X/month infra] | Cloud billing | [constraint] |
```

**Pattern follows NFRs:**
- 99.99% availability + strong consistency → managed database + multi-AZ, not distributed microservices
- <100ms p99 + high throughput → caching layer + connection pooling, not serverless cold starts
- HIPAA + small team → monolith with clear module boundaries, not microservices you can't secure
- 3+ teams + weekly deploys → service-oriented, with bounded contexts matching team boundaries

## Quantitative Scaling Thresholds (When "It Depends" Isn't Good Enough)

| Signal | Threshold | Action |
|--------|-----------|--------|
| API response time p99 | > 500ms | Profile and optimize hot paths |
| Database query time p95 | > 100ms | Add indexes, denormalize, or cache |
| Single table row count | > 10M rows | Partition, archive, or shard |
| Monolith deploy time | > 15 minutes | Split into deployable modules |
| Team size per service | > 8 people | Consider splitting the service (Conway's Law) |
| Circular dependencies | > 0 | Refactor immediately — architectural cancer |
| Service-to-service calls per request | > 3 hops | Introduce caching layer or merge services |
| Test suite runtime | > 10 minutes | Parallelize or split into fast/slow suites |
| Code change frequency collision | > 3 teams touching same file/week | Bounded context violation — split |
| Memory per instance | > 80% baseline | Scale horizontally or optimize |

These are starting points, not laws. Adjust based on your SLOs. But having NO thresholds means "it depends" forever — which is how systems rot.

## Anti-Patterns

- **Resume-Driven Architecture:** Choosing tech because it looks good on a resume, not because it fits the problem.
- **Premature Abstraction:** Building for flexibility you don't need yet. YAGNI is real.
- **Distributed Monolith:** Microservices that all deploy together and share a database. Worst of both worlds.
- **Gold Plating:** Over-engineering internal tools to production-grade when "good enough" works.
- **Ignoring Conway's Law:** Architecture that doesn't match team structure creates friction.

## Integration with Other Skills

- **team skill:** Architecture decisions at Tier 3+ get Gemini's full-codebase context for dependency mapping
- **think skill:** Use decision scaffold for reversible vs irreversible architecture choices
- **owasp-security:** Security architecture review for auth, data flow, input boundaries
- **hipaa-compliance:** Healthcare-specific architecture constraints

## Related Skills
- **owasp-security:** Security implications of architectural decisions
- **team:** Route architectural decisions through multi-model review
- **frontend-patterns:** React/Next.js architecture patterns (ECC)
- **backend-patterns:** API and database architecture patterns (ECC)
- **database-migrations:** Schema design and migration patterns (ECC)
