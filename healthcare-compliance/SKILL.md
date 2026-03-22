---
name: healthcare-compliance
description: "Healthcare software compliance: HIPAA, SOC 2 Type II, and HITRUST CSF. Code-level security patterns for PHI handling, audit logging, encryption, RBAC, and breach readiness. Use when user mentions 'HIPAA', 'SOC 2', 'SOC2', 'HITRUST', 'PHI', 'patient data', 'healthcare compliance', 'BAA', 'breach notification', 'audit logging', 'healthcare security', 'medical software compliance', 'compliance audit', 'Trust Service Criteria', 'healthcare SaaS', 'protected health information', 'healthcare startup compliance', or when building any healthcare-facing software."
---

# Healthcare Compliance

HIPAA + SOC 2 + HITRUST compliance stack for healthcare software development.

## The Compliance Stack

```
HITRUST CSF (Gold standard — 300+ controls, certifiable)
  ├── Incorporates SOC 2, HIPAA, NIST, ISO 27001, PCI DSS, 40+ frameworks
  │
SOC 2 Type II (Market baseline — auditor-attested, 85% HIPAA overlap)
  ├── 78% of enterprise clients require it
  │
HIPAA (Legal floor — regulatory mandate, self-attested)
  └── Required by law for any entity handling PHI
```

**Progression path:**
1. Year 1: HIPAA + SOC 2 Type II (pursue simultaneously — 85% control overlap)
2. Year 2-3: HITRUST e1 or i1 (entry-level, faster/cheaper)
3. Year 3+: HITRUST r2 (full certification for large health systems)

## 1. HIPAA Essentials

- **BAA required** for every vendor touching PHI (cloud, analytics, monitoring, email)
- **Breach notification**: 60 days to HHS + affected individuals
- **Designated officers**: Privacy Officer + Security Officer required
- **Minimum necessary**: Only access PHI needed for specific task
- **PHI = any of 18 identifiers** + health condition/treatment/payment data
- **No formal certification** — self-attested with OCR enforcement

## 2. SOC 2 Type II

### Trust Service Criteria
| Criteria | Required? | Healthcare Need |
|----------|-----------|-----------------|
| **Security** | Mandatory | Always |
| Availability | Optional | Yes — SLAs matter |
| Processing Integrity | Optional | Yes — clinical data accuracy |
| Confidentiality | Optional | Yes — PHI/trade secrets |
| Privacy | Optional | Recommended for patient-facing |

- Type II = 3-12 month observation window (6+ recommended)
- Combined SOC 2 + HIPAA report available (single audit engagement)

## 3. Code-Level Patterns

### Audit Trails (CRITICAL)
Every mutating operation on sensitive data must produce an immutable record:
- **Fields**: timestamp (UTC), actor ID, actor IP, action, resource type, resource ID, previous value hash, new value hash, request ID
- **Storage**: append-only datastore separate from application DB
- **Retention**: 6 years minimum (HIPAA), 12 months minimum (SOC 2)
- **Access**: only authorized personnel; access to logs is itself logged
- **NEVER** log PHI/PII in plaintext — use tokenization or redaction

### RBAC (Default-Deny)
- Define roles: admin, provider, staff, patient, auditor, billing
- Permission checks as middleware/decorators, not inline conditionals
- Every API endpoint enforces authorization — default-deny
- Role-permission matrix as versioned config (not hardcoded)
- Log all permission changes and role assignments
- Support break-glass emergency access with enhanced logging

### Encryption
- **In transit**: TLS 1.2+ mandatory, TLS 1.3 preferred
- **At rest**: AES-256 for databases, object storage, backups
- **Field-level**: encrypt PHI columns, not just disk-level
- **Per-tenant keys** in multi-tenant architectures
- **Envelope encryption**: data key encrypts data, master key encrypts data key
- **Key rotation** without downtime, at least annually
- **KMS**: AWS KMS, GCP Cloud KMS, Azure Key Vault, or HashiCorp Vault

### Session Security
- 15-minute idle timeout for healthcare applications
- Forced re-authentication for sensitive actions (viewing full SSN, data export)
- Cryptographically random session tokens, httpOnly/secure cookies
- Rate limiting on auth endpoints, account lockout with alerting

### Secrets Management
- Secrets in vault (never in code or committed env files)
- Scan repos with git-secrets/truffleHog/Gitleaks in CI
- Rotate at least annually, API keys quarterly
- Separate secrets per environment

## 4. HITRUST CSF (v11.7.0, Dec 2025)

| Tier | Controls | Use Case | Cost |
|------|----------|----------|------|
| **e1 (Essentials)** | 44 | Low-risk vendors, fastest path | Lower |
| **i1 (Implemented)** | 182 | Moderate assurance, most common threats | Mid |
| **r2 (Risk-based)** | 300+ | Full certification, required by major health systems | $60-200K |

Combined SOC 2 + HITRUST report reduces audit fatigue by 20-30%.

## 5. Startup Readiness Checklist

### Phase 1: Foundation (Weeks 1-4)
- [ ] Select Trust Service Criteria (Security + Confidentiality + Availability)
- [ ] Appoint compliance owner
- [ ] Choose automation platform (Vanta, Drata, or Secureframe)
- [ ] Conduct gap assessment
- [ ] Engage CPA auditor firm

### Phase 2: Policies (Weeks 4-8)
- [ ] Write 10 core policies: InfoSec, Access Control, Incident Response, Change Mgmt, Risk Assessment, Data Classification, Acceptable Use, Vendor Mgmt, BC/DR, Data Retention
- [ ] Version, date, assign owners, track employee acknowledgments

### Phase 3: Technical Controls (Weeks 4-12)
- [ ] MFA on all critical systems
- [ ] RBAC with least privilege
- [ ] Encryption at rest (AES-256) and in transit (TLS 1.2+)
- [ ] Centralized logging and monitoring (SIEM)
- [ ] Automated vulnerability scanning in CI/CD
- [ ] Automated onboarding/offboarding with access provisioning
- [ ] Endpoint protection (MDM, disk encryption, screen lock)
- [ ] Backup + tested restoration procedures

### Phase 4: Evidence (Ongoing)
- [ ] Connect compliance platform to infrastructure
- [ ] Quarterly access reviews with documentation
- [ ] Annual penetration testing
- [ ] Security awareness training for all employees
- [ ] Vendor SOC 2 reports collected annually

### Phase 5: Audit (Months 4-12)
- [ ] Type I audit (optional, 2-3 months)
- [ ] Begin Type II observation period (6+ months)
- [ ] Complete Type II audit

**Timeline**: 6-9 months total. **Cost**: audit $20-80K + platform $7.5-30K/yr.

## 6. Common Audit Findings

| Finding | Prevention |
|---------|------------|
| Late user deprovisioning | Automate with HRIS, 24h SLA |
| Missing access reviews | Quarterly with screenshots, automate via platform |
| Incomplete change management | Branch protection, required PR approvals |
| Missing vendor assessments | Vendor inventory, collect SOC 2 reports annually |
| Insufficient logging | Centralized SIEM, test alerting quarterly |
| Outdated policies | Annual review cycle, track acknowledgments |
| No security training evidence | Annual training with completion tracking |
| Missing backup/restore tests | Quarterly restoration tests, document results |

## 7. Tools Comparison

| Platform | HIPAA | SOC 2 | HITRUST | Starting Price |
|----------|-------|-------|---------|----------------|
| **Vanta** | ✅ | ✅ | ✅ | ~$10K/yr |
| **Drata** | ✅ | ✅ | ✅ | ~$7.5K/yr |
| **Secureframe** | ✅ | ✅ | ✅ | ~$8K/yr |
| **Sprinto** | ✅ | ✅ | — | ~$5K/yr |

Vanta or Drata recommended for healthcare startups.

## Anti-Patterns

- ❌ PHI in application logs (use tokenization)
- ❌ Shared accounts (unique user IDs required)
- ❌ Hardcoded secrets or credentials
- ❌ Missing authorization checks on endpoints
- ❌ Direct database access without audit trail
- ❌ Error messages leaking system internals
- ❌ Sending PHI to AI/LLM APIs without BAA
- ❌ Storing encryption keys alongside encrypted data

> Cross-reference: `security` for OWASP/ASVS standards. `sleep-practice` for sleep-specific HIPAA considerations.
