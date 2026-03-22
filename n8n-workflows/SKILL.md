---
name: n8n-workflows
description: "Dental practice workflow automation with n8n. Designs appointment reminders, lead capture, no-show recovery, review requests, patient intake, and AI voice agent workflows. Use when user mentions 'n8n', 'workflow', 'automation', 'appointment reminders', 'no-show', 'patient follow-up', 'lead capture', 'intake form', 'automate', 'workflow automation', 'Zapier', 'Make', or any request to automate dental practice operations. Also triggers on 'reduce no-shows', 'automate reminders', 'patient communication automation', or 'build a workflow'."
origin: ECC
---

# Dental Practice Workflow Automation (n8n)

**Step 0:** Read `.claude/context/practice-context.md` for practice overview, brand voice, patient pain points, and proof points before proceeding.

Design and build n8n workflows for dental practice operations. Leverages n8n MCP tools for node search, template retrieval, and workflow validation.

## Why Automate

| Workflow | Manual hrs/wk | Automated | Savings |
|----------|:------------:|:---------:|:-------:|
| Appointment reminders | 5-8 | 0.5 | 90% |
| Patient intake entry | 4-6 | 0.5 | 88% |
| No-show follow-up | 3-5 | 0.5 | 85% |
| Review requests | 2-3 | 0 | 100% |
| Lead response | 3-5 | 0.5 | 87% |
| **Total** | **21-35** | **~3** | **~85%** |

No-show revenue recovery alone: $20K-$70K/year. Overall: 20+ hrs/week saved.

## Top 6 Workflow Patterns

### 1. Lead Capture + AI Response
**Trigger:** Webhook from PatientsReach/website form
**Flow:** Receive JSON → AI qualifies lead (implant vs cosmetic vs general) → Personalized SMS response → Log to Google Sheets → Alert staff for hot leads
**Impact:** Eliminates 50%+ lead loss from slow response. Response in seconds vs hours.
**Template:** [#7971](https://n8n.io/workflows/7971)

### 2. Appointment Reminder Cascade
**Trigger:** Schedule (daily scan)
**Flow:** Query calendar for next-day appts → 48h email → 24h SMS (Twilio) → 2h WhatsApp → No response: flag for staff call
**Impact:** 30-40% no-show reduction
**Nodes:** Schedule Trigger, Google Calendar, IF, Twilio, WhatsApp Business Cloud
**Templates:** [#6548](https://n8n.io/workflows/6548), [#7545](https://n8n.io/workflows/7545)

### 3. No-Show Recovery
**Trigger:** Calendar event passes + patient flagged absent
**Flow:** Wait 15 min → AI empathetic rebooking SMS → 24h: email with booking link → 7 days: add to reactivation campaign
**Critical:** 15-min follow-up recovers ~40% of appointments; after 24h, drops below 10%
**Template:** [#6491](https://n8n.io/workflows/6491)

### 4. Post-Visit Review Engine
**Trigger:** Appointment completed (webhook/calendar)
**Flow:** Wait 30 min → SMS with Google review link → Monitor for new reviews → AI draft responses → Staff approval via Slack
**Impact:** 100+ reviews in 90 days. 72% of patients use reviews to find a dentist.
**Template:** [#6590](https://n8n.io/workflows/6590)
→ Cross-reference: `dental-reputation` skill for HIPAA-compliant response templates

### 5. Treatment Follow-Up Nurture
**Trigger:** Patient receives treatment plan but doesn't schedule
**Flow:** Day 3: educational email → Day 7: SMS with financing info → Day 14: personal call from coordinator → Day 30: reactivation offer
**Impact:** Recovers 20-30% of uncommitted treatment plans

### 6. AI Voice Receptionist
**Trigger:** Inbound call via Retell AI or ElevenLabs
**Flow:** AI answers → Handles FAQ, checks availability → Books or escalates to human → Logs interaction → Sends confirmation SMS
**Nodes:** Webhook, AI Agent, Retell AI, Google Calendar, Twilio
**Templates:** [#6153](https://n8n.io/workflows/6153)

## HIPAA Compliance for n8n

**n8n Cloud is NOT HIPAA-compliant** (no BAA available). Self-hosted is required.

**Self-hosted requirements:**
- HIPAA-eligible infrastructure (AWS/GCP/Azure with BAAs)
- Encryption at rest and in transit (TLS)
- Private VPC, no public subnets
- Audit logging of all workflow executions
- Role-based access controls
- BAAs with ALL downstream vendors (Twilio healthcare plan, Azure OpenAI, etc.)

**Practical approach:** Minimize PHI in workflows. Send time/date only in reminders (no diagnosis). Use patient ID references, not full names in logs.

**Alternatives:** [Keragon](https://www.keragon.com) — HIPAA-compliant n8n alternative with BAAs, connects 300+ healthcare tools including Dentrix and Open Dental. [DentalRx](https://dentalrx.ca/partners/n8n) — dental-specific n8n partner.

→ Cross-reference: `hipaa-compliance` skill for full PHI framework

## n8n MCP Integration

n8n can operate as both MCP server and client:
- **MCP Server Trigger:** Expose workflows as tools that Claude/AI assistants can invoke
- **MCP Client Tool:** n8n AI agents consume external MCP servers (CRM, PMS, knowledge base)

**Dental application:** Expose "book appointment," "check availability," "send reminder" as MCP tools that Claude can invoke during patient conversations.

Use the n8n MCP tools in this session (`mcp__n8n-mcp__*`) to search nodes, get templates, and validate workflows.

## Key Nodes by Category

| Category | Nodes |
|----------|-------|
| **Triggers** | Webhook, Schedule, Form, WhatsApp Trigger, MCP Server Trigger |
| **Communication** | Twilio (SMS), WhatsApp Business Cloud, Gmail, SendGrid |
| **AI** | AI Agent (OpenAI/Gemini/Anthropic), OpenAI Chat Model |
| **Scheduling** | Google Calendar, Cal.com |
| **Data** | Google Sheets, PostgreSQL, Airtable |
| **Voice** | Retell AI, ElevenLabs |
| **Logic** | IF, Switch, Wait, Merge, Code (JS/Python) |

## PMS Integration

| PMS | Method | Notes |
|-----|--------|-------|
| Dentrix | Keragon connector, custom API | Most widely used |
| Open Dental | REST API, Keragon | Open-source friendly |
| PatientsReach | Webhook/API | 5D Smiles booking system |
| Google Calendar | Native n8n node | Simple scheduling fallback |

## Integration Points

- **dental-reputation:** Review request workflow feeds into reputation management
- **hipaa-compliance:** All patient communication workflows must pass PHI checks
- **local-seo:** Review generation impacts local ranking
- **ai-seo:** Automated content can feed AI citation strategy
