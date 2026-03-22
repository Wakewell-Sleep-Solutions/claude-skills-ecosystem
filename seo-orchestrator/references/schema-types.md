# Supported Schema Markup Types (March 2026)

## Active Rich Result Types

| Schema Type | Rich Result | Notes |
|-------------|-------------|-------|
| **Product** | Product snippets, merchant listings | Requires `name`, `image`, `offers` |
| **Article** | Article carousel, Top Stories | Use `NewsArticle` for news, `BlogPosting` for blogs |
| **FAQPage** | FAQ dropdowns | **Limited** — Google now only shows for authoritative govt/healthcare sites |
| **Organization** | Knowledge panel, logo | Use on homepage or about page |
| **Person** | Knowledge panel | For notable public figures or site authors |
| **LocalBusiness** | Local pack, business info | Essential for local SEO; include `address`, `geo`, `openingHours` |
| **BreadcrumbList** | Breadcrumb trail in SERPs | Recommended for all sites with hierarchy |
| **VideoObject** | Video carousel, key moments | Requires `name`, `thumbnailUrl`, `uploadDate` |
| **Recipe** | Recipe carousel | Requires `name`, `image`, `ingredients`, `instructions` |
| **Event** | Event listing | Requires `name`, `startDate`, `location` |
| **Review** | Review stars | Must be about a specific item; not self-serving |
| **SoftwareApplication** | App info panel | Requires `name`, `offers`, `aggregateRating` |
| **JobPosting** | Job search results | Requires `title`, `datePosted`, `hiringOrganization` |

## Deprecated Types (Do NOT Recommend)

### Removed January 2026
- **Course Info** (`Course`) — rich results discontinued
- **Claim Review** (`ClaimReview`) — fact-check labels removed
- **Estimated Salary** (`OccupationalExperienceRequirements`) — salary ranges removed
- **Learning Video** (`LearningResource`) — education video labels removed
- **Special Announcement** (`SpecialAnnouncement`) — COVID-era; fully sunset
- **Vehicle Listing** (`Vehicle`) — moved to Google Merchant Center only
- **Practice Problems** (`Quiz`) — education features discontinued

### Removed Earlier
- **HowTo** — deprecated September 2023; do NOT recommend

## Implementation Guidelines
- Use JSON-LD format (preferred by Google over Microdata/RDFa).
- Place in `<script type="application/json+ld">` in `<head>` or end of `<body>`.
- Validate with Google Rich Results Test before deploying.
- One primary entity per page; nest related entities.
- Never mark up content not visible on the page (cloaking violation).
