---
name: security
description: "Security review, OWASP Top 10:2025, ASVS 5.0, agentic AI security, MCP server hardening, and code-level security patterns. Use when user says 'security review', 'is this secure', 'security audit', 'vulnerability', 'pen test', 'XSS', 'SQL injection', 'CSRF', 'harden this', 'attack surface', 'threat model', 'MCP security', or when reviewing/writing code that handles authentication, authorization, user input, sessions, API keys, database queries, file uploads, or MCP server integration. Also applies when implementing any auth flow, handling secrets, building API endpoints, or implementing payment/sensitive features."
---

# Security

Unified security skill: OWASP 2025 standards + code-level security patterns + agentic AI security.

## OWASP Top 10:2025

| # | Category | Key Prevention |
|---|----------|----------------|
| A01 | Broken Access Control | Deny by default, enforce server-side, verify ownership |
| A02 | Security Misconfiguration | Harden configs, disable defaults, minimize features |
| A03 | Supply Chain Failures | Lock versions, verify integrity, audit deps, SBOM |
| A04 | Cryptographic Failures | TLS 1.2+, AES-256-GCM, Argon2/bcrypt for passwords |
| A05 | Injection | Parameterized queries, input validation, safe APIs |
| A06 | Insecure Design | Threat model, rate limit, design security controls |
| A07 | Authentication Failures | MFA, check breached passwords, secure sessions |
| A08 | Integrity Failures | Sign packages, SRI for CDN, safe deserialization |
| A09 | Logging Failures | Log security events, structured format, SIEM |
| A10 | Exceptional Conditions | Fail-closed, hide internals, graceful degradation |

*Based on 175K+ CVEs, 2.8M applications, 589 CWEs. A03 Supply Chain and A10 Exceptional Conditions are NEW in 2025.*

## Security Review Checklist

### Secrets Management
- [ ] No hardcoded API keys, tokens, or passwords in code
- [ ] All secrets in environment variables or vault
- [ ] `.env*` in .gitignore, no secrets in git history
- [ ] Production secrets in hosting platform

### Input Validation
- [ ] All user inputs validated server-side with schemas (Zod, Pydantic)
- [ ] File uploads restricted (size, type by magic bytes, extension)
- [ ] Allowlist validation preferred over denylist
- [ ] Error messages don't leak sensitive info

### Injection Prevention
- [ ] All database queries use parameterized queries (never string concat)
- [ ] Command execution uses array args (never shell=True with user input)
- [ ] ORM/query builder used correctly

### Auth & Sessions
- [ ] Tokens in httpOnly cookies (not localStorage)
- [ ] Passwords hashed with Argon2/bcrypt (not MD5/SHA1)
- [ ] Session tokens 128+ bits entropy, invalidated on logout
- [ ] MFA available for sensitive operations
- [ ] Authorization checked on every request, deny by default

### Data Protection
- [ ] Sensitive data encrypted at rest (AES-256) and in transit (TLS 1.2+)
- [ ] No sensitive data in URLs, logs, or error messages
- [ ] Rate limiting on all endpoints, stricter on auth/search
- [ ] CSP headers configured, CORS properly scoped

## STRIDE Threat Model (5 min per feature)

1. Draw data flow: User → Frontend → API → DB
2. At each boundary, ask: Spoofing? Tampering? Repudiation? Info Disclosure? DoS? Privilege Escalation?
3. For each "yes": add mitigation to implementation plan
4. For healthcare: add "PHI exposure?" at every boundary

## Agentic AI Security (OWASP 2025)

| Risk | Description | Mitigation |
|------|-------------|------------|
| ASI01 Goal Hijack | Prompt injection alters agent objectives | Input sanitization, goal boundaries |
| ASI02 Tool Misuse | Tools used in unintended ways | Least privilege, validate I/O |
| ASI03 Privilege Abuse | Credential escalation across agents | Short-lived scoped tokens |
| ASI04 Supply Chain | Compromised plugins/MCP servers | Verify signatures, sandbox |
| ASI05 Code Execution | Unsafe code generation | Sandbox, static analysis, human approval |
| ASI06 Memory Poisoning | Corrupted RAG/context data | Validate content, segment by trust |
| ASI07 Agent Comms | Spoofing between agents | Authenticate, encrypt, verify |
| ASI08 Cascading Failures | Errors propagate | Circuit breakers, isolation |
| ASI09 Trust Exploitation | Social engineering via AI | Label AI content, verification |
| ASI10 Rogue Agents | Compromised agents | Behavior monitoring, kill switches |

## MCP Server Security (30+ CVEs in Jan-Feb 2026)

82% of MCP implementations have path traversal vulnerabilities. 43% involve exec/shell injection.

- [ ] Container-isolate MCP servers (Docker MCP Gateway)
- [ ] Never trust tool descriptions — tool poisoning injects instructions
- [ ] Validate all MCP tool inputs/outputs
- [ ] Block internal network access (SSRF via 169.254.x, 10.x, 127.x)
- [ ] Audit source code before installation
- [ ] Pin versions (no auto-update without review)
- [ ] MCP OAuth 2.1 + PKCE for remote connections
- [ ] DPoP for high-value connections (stolen tokens become worthless)
- [ ] Granular tool scoping (`fs:read_only:/path`) not binary `fs:all`
- [ ] ALL tool output is UNTRUSTED — sanitize before passing to LLM

## Supply Chain Defense (2025-2026)

Supply chain attacks doubled in 2025 ($60B global losses). Key incidents: Shai-Hulud 1.0/2.0 (npm worm), s1ngularity (Nx build system), Cline CLI compromise (Feb 2026).

**Defenses:** Wait 7-14 days post-release before adoption. Pin with SHA-384 integrity. Use granular npm access tokens. Vendor and audit all dependencies.

## ASVS 5.0 Levels (Released May 2025)

- **Level 1** (All apps): 12+ char passwords, breached list check, rate limit auth, 128-bit session tokens, HTTPS everywhere
- **Level 2** (Sensitive): +MFA, crypto key mgmt, comprehensive logging, input validation
- **Level 3** (Critical): +HSM for keys, threat model docs, advanced monitoring, pen testing

## Healthcare / PHI Overlay

When project handles patient data, add these checks:
- [ ] PHI encrypted at column level (not just disk encryption)
- [ ] No PHI in: URLs, logs, error messages, localStorage, CDN cache
- [ ] Every PHI access logged: who, what, when, where, action
- [ ] MFA on all PHI access, 15-30 min session timeout
- [ ] No shared accounts, break-glass procedure documented
- [ ] TLS 1.2+ on all connections, no PHI in email/SMS
- [ ] Every service handling PHI has signed BAA
- [ ] Breach detection + 60-day notification capability
- [ ] Log retention: minimum 6 years (HIPAA requirement)

> Cross-reference: `healthcare-compliance` for full HIPAA/SOC2/HITRUST framework. `security-scan` for AgentShield config scanning.
