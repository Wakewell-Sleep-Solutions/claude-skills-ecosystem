---
name: patient-comms
description: "HIPAA-aware patient communication templates for dental practices. Drafts recall/reactivation texts, post-op care instructions, insurance pre-authorization letters, referral thank-yous, treatment acceptance follow-ups, and new patient welcome messages. Use when user mentions 'patient message', 'recall text', 'reactivation message', 'post-op instructions', 'care instructions', 'insurance letter', 'pre-authorization', 'referral letter', 'treatment follow-up text', 'welcome message', 'patient communication', 'appointment confirmation', or 'HIPAA-compliant message'. Also triggers on 'text the patient', 'send a recall', 'post-op email', 'write an insurance letter', 'draft a referral', or 'patient outreach'."
origin: ECC
---

# Patient Communication Templates (HIPAA-Aware)

SMS has 98% open rate (90% read within 3 min) vs email's 12-20%. But phone still books 71% of appointments. Multi-channel wins: SMS primary, email for detail, phone for complex conversations.


**Step 0:** Read `.claude/context/practice-context.md` for practice overview, brand voice, patient pain points, and proof points before proceeding.
## Channel Effectiveness (2026 Data)

| Channel | Open Rate | Patient Preference | No-Show Reduction | Key Stat |
|---------|:---------:|:------------------:|:------------------:|----------|
| **SMS** | 98%+ | 62-70% prefer | 30-50% | 86% opt in; 25% fewer inbound calls |
| **Email** | 12-20% | 24% | Moderate | 4x lower response than SMS |
| **Phone** | N/A | 14% | 30-60% | 35% calls unanswered; 78% hang up on voicemail |

**Critical:** 67% of patients who can't get through call a competitor immediately. 45% ignore calls from unknown numbers.

## HIPAA Rules for ALL Communications

1. Never include diagnosis, treatment details, or clinical info in SMS
2. Appointment reminders: date/time/location ONLY — no procedure names
3. Email with PHI must be encrypted (HIPAA-compliant platform with BAA)
4. Patient must have opted in to channel
5. Include opt-out in marketing messages
6. Never confirm patient status to third parties

## 1. Recall / Reactivation (96% action rate when personalized vs 20% generic)

**Optimal send time:** 6 PM SMS achieves 41% higher confirmation than noon.

**Sequence by overdue period:**

| Overdue | Channel | Message Focus | Expected Recovery |
|---------|---------|---------------|:-:|
| 3 months | Email | Friendly reminder + booking link | High |
| 3.5 months | SMS | "Reply YES to schedule" | High |
| 4 months | Phone | Personal outreach, Tue-Thu 10am-12pm or 2-4pm | Medium |
| 6-12 months | SMS + email | "We miss you" + incentive | Medium |
| 12-18 months | Multi-touch (5 touches = 81% higher reactivation) | "Fresh start" + $50 off | Lower |
| 18+ months | SMS → email → phone → email → postcard | No-judgment + strong incentive | 15-20% |

**ROI example:** Modern Dentistry: 59 reactivations in 90 days = $49,456, 140x ROI from automated texts.

**Templates:**

**6-month (warm):**
> Hi [Name]! It's been a while since your last visit at 5D Smiles. Your smile deserves regular check-ups! Book easily: [link]. Reply STOP to opt out.

**12+ month (incentive):**
> Hi [Name], we've missed you at 5D Smiles! Come back with a complimentary exam for returning patients. No judgment — just great care. Book: [link]

## 2. Post-Op Instructions (60% of patients don't fully understand verbal explanations)

**Video-based delivery:** 25% more patients complete 3+ recall visits vs verbal/written only (p=0.023). Combine: short video + timed SMS reminders + digital reference on-demand.

**Implant post-op (SMS → link to full instructions):**
> Hi [Name], here are your post-op care instructions: [link]. Key reminders: ice 20min on/off, soft foods 48hrs, no smoking/straws 72hrs. Call us at [phone] if you have heavy bleeding, severe pain, or fever. Your follow-up: [date/time].

**Channel guidance:**
- SMS: brief summary + link to full digital instructions
- Email: detailed instructions (encrypted if clinical details included)
- Video: highest retention — record procedure-specific videos once, reuse
- Paper alone is insufficient (60% comprehension gap)

## 3. Insurance Pre-Authorization (automation cuts approval time 60-75%)

**Manual process:** 3-7 business days, up to 16 staff hours/week. Automated: handles 70-80% of routine auths without human intervention. ROI in 3-6 months for practices doing 50+ auths/month.

**Letter template:**
```
Re: Pre-Authorization Request
Patient: [Name] | ID: [Insurance ID] | DOB: [DOB]

Procedure(s): [CDT Code(s)] — [Description(s)]
Estimated Fee: $[Amount]

Clinical Justification:
[Narrative connecting findings → diagnosis → treatment necessity.
Include: What is the diagnosis? What evidence supports it?
Why is this treatment appropriate? What happens without it?]

Supporting Documentation:
☐ Intraoral photographs (reduces denial ~40% vs X-rays alone)
☐ Periapical/panoramic radiographs
☐ Periodontal charting
☐ Clinical notes

Please process within [X] business days.
```

**Important:** Pre-authorizations are NEVER a guarantee of payment.

## 4. Referral Communications

**Digital platforms replacing fax:** PepCare, CareStack, ReferralMD, Open Dental referral tracking. One organization increased referral volume 11.5% with standardized workflows.

**HIPAA transmission:** Treatment/payment/operations disclosures permitted without patient authorization. Use encrypted email (Google Workspace/M365 with BAA), secure fax, or HIPAA platforms. Consumer Gmail/Outlook do NOT qualify.

**Sending referral:**
> Dear Dr. [Name], I am referring [Patient] for evaluation of [area/condition]. [2-3 sentence clinical summary]. Enclosed: [attachments]. Please send treatment summary upon completion.

**Patient notification:**
> Hi [Name], we've sent your referral to Dr. [Specialist] at [Practice]. They should contact you within [X] business days. If you don't hear from them, call [specialist phone].

**Close the loop:** Automate follow-up to confirm patient scheduled with specialist.

## 5. Treatment Acceptance Follow-Up (only 16% of practices formally track this)

**Benchmarks:** National average acceptance 50-60%. Top practices: 85-90% (single-tooth), 60-75% (comprehensive). By dollar value: only 35-45%. Critical gap: 56% accepted → only 46% completed.

**Sequence:**

| Timing | Channel | Content | Why |
|--------|---------|---------|-----|
| Same day | SMS/Email | Thank you + treatment summary + financing | Strike while warm |
| Day 3 | SMS | "Any questions about what we discussed?" | Remove barriers |
| Day 7 | Phone | Personal call from treatment coordinator | Highest conversion |
| Day 14 | SMS | Financing offer or limited-time incentive | Cost barrier |
| Day 30 | Email | New availability + educational content | Last touch |
| Ongoing | AI prediction | Risk scoring triggers timely intervention | Prevent dropout |

**Rules:** Never mention specific diagnosis/treatment in texts. Use "the options we discussed" generically.

## 6. New Patient Welcome (4-6 emails over 1-2 weeks)

**First email must go within minutes** of registration to capture initial interest. Practices automating welcome + reminders + recall see 20-30% fewer no-shows.

| Timing | Channel | Content |
|--------|---------|---------|
| Immediately | Email | Welcome + what to expect + office intro |
| Day 1-2 | Email | Digital intake forms + insurance info request + "meet the team" |
| Pre-visit (2-3 days) | SMS | Reminder + parking + arrival time |
| Day of | In-office | Warm greeting + office tour |
| Post-visit (same day) | SMS | Thank you + review request link |
| Week 1 | Email | Treatment plan summary + educational resources |

## 7. Appointment Reminders (automated = 22.95% no-show reduction)

| Timing | Channel | Message |
|--------|---------|---------|
| 1 week | Email | Full details + pre-visit prep |
| 48 hours | SMS | "Reply C to confirm or call [phone] to reschedule" |
| 2 hours | SMS | "Your appointment is today at [Time]. See you soon!" |

**Rules:** Date, time, location ONLY. Never include procedure type.

## AI Communication Tools (2026)

| Tool | Focus | Key Stat | Price |
|------|-------|----------|:-----:|
| **Arini** | AI receptionist (inbound calls) | $56K+ in new appointments in first month from missed calls | Subscription |
| **Newton** | Outbound AI recall calls | Y Combinator backed, $3.8M seed | Contact |
| **DentiVoice** | Full AI receptionist 24/7 | NLP trained on dental terminology | $50-500/mo |
| **Emitrr** | HIPAA messaging + AI agent | 1,000+ integrations, 5/5 Capterra | Flexible |

**Industry benchmark:** AI handling full first-mile communication achieves 75%+ resolution. Early human intervention drops performance by 30%.

## Automation ROI

| Metric | Impact |
|--------|--------|
| Overhead reduction | 20-30% within first year |
| Patient retention increase | 15-25% |
| No-show decrease | 35-50% |
| Annual savings (mid-size) | $50,000-$150,000 |
| Reactivation revenue add | $50,000-$100,000/year |
| Reminder ROI | $3-5K/year cost → $64K no-show recovery |

## HIPAA-Compliant Platform Comparison

| Platform | BAA | Dental-Specific | AI | EHR Integration | Price |
|----------|:---:|:---------------:|:--:|:---------------:|:-----:|
| **Weave** | ✅ | Yes | Call AI | Multiple | High |
| **Emitrr** | ✅ | Yes | AI Agent | 1,000+ | Flexible |
| **NexHealth** | ✅ | Yes | No | Dentrix, Open Dental | High |
| **Klara** | ✅ | General | No | Limited | $250/mo |
| **Yapi** | ✅ | Dental only | No | Dentrix, Eaglesoft, OD | ~$99/user |

## Integration Points

- **dental-email-marketing:** Email sequences use these templates as building blocks
- **dental-reputation:** Post-visit messages include review request as final step
- **n8n-workflows:** Templates feed into automated workflow triggers
- **hipaa-compliance:** All messages checked against HIPAA guardrails
- **dental-analytics:** Track response rates, conversion by message type, no-show reduction
- **business-email:** Patient-facing here; business/professional correspondence there
- **ad-creative:** Post-ad-click sequences use welcome templates
