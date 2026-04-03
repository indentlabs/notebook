# Help Center Audit: Missing Resources & Recommendations

**Audit Date:** February 2026
**Auditor:** Claude Code Analysis
**Scope:** `/help` pages, Data Vault, related documentation

---

## Executive Summary

The Help Center is well-structured with strong documentation on core features, but has significant gaps in account management, data management workflows, and user journey support. The existing guides are comprehensive and well-designed with consistent styling, Table of Contents navigation, and clear organization.

---

## Currently Covered (Well Documented)

### Help Center Pages (`/help/*`)

| Page | Coverage Quality | Notes |
|------|------------------|-------|
| Your First Universe | Excellent | Step-by-step guide for new users |
| Page Templates | Excellent | Complete guide to customization |
| Organizing with Universes | Excellent | Covers privacy, collaboration, focus mode |
| Page Visualization (Basil) | Good | AI visualization features |
| Document Analysis | Good | AI-powered extraction features |
| Organizing with Tags | Good | Tag management guide |
| Free Features Guide | Excellent | Comprehensive free tier overview |
| Premium Features Guide | Excellent | All premium features covered |

### Feedback Collection
- Bug reports (Google Form)
- Feature requests (Google Form)
- General feedback (Google Form)
- Mobile usage survey
- Page type requests
- Premium-specific surveys (Document Analysis, Timeline, Collections)

### Content Type Documentation
- All 20+ content types have dedicated info pages at `/worldbuilding/:type`
- Writing Tools section covers Timelines, Documents, and Books

---

## Missing Resources & Recommendations

### 1. ACCOUNT & SETTINGS (High Priority)

**Currently Missing:**
- Account settings guide (profile, preferences, notifications)
- Password/security management
- Avatar/profile customization
- How to delete account or export all data
- Email notification preferences

**What Exists:**
- `edit_user_registration_path` exists and is linked from Data Vault as "Account Settings"
- No dedicated help documentation for these features

**Recommendation:** Add "Managing Your Account" guide covering:
- Profile customization options
- Security best practices (password changes)
- Email notification preferences
- Account deletion process (GDPR compliance)
- How to contact support for account issues

---

### 2. DATA MANAGEMENT (High Priority)

**Currently Missing from Help Center:**
- Data Vault overview and feature tour
- Export options guide (explaining TXT, MD, JSON, XML, YAML, CSV formats)
- Recycling Bin / recovering deleted content
- Archive management workflow
- Storage usage and limits explanation (50MB free, 10GB premium)

**What Exists:**
- Robust Data Vault UI at `/data` with all these features
- Export page at `/export` with format explanations
- Archive page at `/data/archive`
- Recycle Bin at `/content/deleted`
- Uploads management at `/data/uploads`

**Recommendation:** Add "Your Data: Export, Backup & Recovery" guide linking to:
- Data Vault overview (`/data`)
- Export formats guide (`/export`)
- Archive management (`/data/archive`)
- Recovering deleted content (`/content/deleted`)
- Image upload management (`/data/uploads`)
- Storage limits by tier

---

### 3. COLLABORATION (Medium Priority)

**Currently Missing:**
- Standalone collaboration guide (step-by-step)
- Detailed contributor permissions breakdown
- Managing/removing collaborators
- Troubleshooting collaboration issues

**What Exists:**
- Collaboration section in "Organizing with Universes" guide (lines 260-311)
- Collaboration management page at `/data/collaboration`
- Premium collaboration sharing explanation in Premium Features guide

**Current Coverage Quality:** Good but embedded in Universe guide

**Recommendation:** Either:
1. Add dedicated "Collaboration Guide" with expanded content, OR
2. Add Quick Links section pointing to collaboration management and existing docs

---

### 4. COMMUNITY FEATURES (Medium Priority)

**Currently Missing:**
- How to share content publicly (detailed workflow)
- Activity Stream usage (Following vs Global feeds)
- Following/blocking other users
- Collections: creating, submitting, browsing (Premium)
- Public profiles explanation
- Forum navigation guide

**What Exists:**
- Community & Sharing section in Free Features guide (lines 244-352)
- Collections submission mentioned
- Activity Stream mentioned
- Forum links throughout
- Discussion activity in Data Vault

**Recommendation:** Add "Community & Sharing" quick reference guide covering:
- Making content public
- Activity Stream tabs
- Following users
- Collections workflow
- Forum participation
- Public profile visibility

---

### 5. SEARCH & NAVIGATION (Medium Priority)

**Currently Missing:**
- How to search content effectively
- Multi-word search tips
- Filtering by content type
- Using Table of Contents navigation
- Dashboard overview
- Universe Focus Mode usage (partially covered)

**What Exists:**
- Universe Focus Mode in "Organizing with Universes" (lines 172-209)
- Data Vault has search functionality

**Recommendation:** Add "Finding Your Content" quick reference with:
- Search syntax tips
- Filtering options
- Dashboard navigation
- Focus mode reminder

---

### 6. API & INTEGRATIONS (Low-Medium Priority)

**Currently Missing from Help Center:**
- API overview for developers
- Link to API documentation
- Third-party app authorization
- OpenCharacters export for AI chat platforms

**What Exists:**
- API docs at `/api/docs`
- Application integrations at `/api/application_integrations`
- Developer navbar and layout
- OpenCharacters export functionality (found in `conversation/character_landing.html.erb`)

**Recommendation:** Add "API & Integrations" section to Help Center with:
- Link to API docs (`/api/docs`)
- Brief overview of API capabilities
- Application authorization explanation
- OpenCharacters export guide (for AI chat platforms)

---

### 7. BILLING & SUBSCRIPTION (Low Priority)

**Currently Missing from Help Center:**
- Direct link to Billing FAQ
- Upgrade/downgrade workflow
- Payment methods summary
- Referral program link
- Gift codes and promo redemption

**What Exists:**
- Comprehensive Billing FAQ at `/subscriptions/faq` covering:
  - What is Premium
  - Price tiers ($9/mo, $8/mo quarterly, $7/mo yearly)
  - Cancellation policy
  - What happens to content on cancellation
  - Premium Codes (prepaid)
  - PayPal payment (via Premium Codes)
  - Gifting Premium
  - Collaborator Premium sharing
  - Payment method management
  - Refund requests
  - Data export
- Prepay page for Premium Codes
- Referrals page at `/data/referrals`
- Billing history at `/subscriptions/history`

**Recommendation:** Add "Billing & Subscriptions" quick links section to Help Center pointing to:
- Billing FAQ (`/subscriptions/faq`)
- Premium upgrade (`/subscription`)
- Premium Codes/Prepay (`/subscriptions/prepay`)
- Billing History (`/subscriptions/history`)
- Referral Program (`/data/referrals`)

---

### 8. LAB TOOLS (Low Priority)

**Currently Missing:**
- Babel (translation tool) - if available
- Dice Roller - if available
- Crossword Generator - if available
- Pinboard - if available
- Writing Goals - exists but not documented

**What Exists:**
- Writing Goals at `/writing_goals` (found in views)
- Achievement tracking at `/data/achievements`
- Year in Review at `/data/year_in_review`

**Recommendation:** If Lab Tools exist as distinct features, add "Lab Tools & Extras" section. If not, consider documenting:
- Writing Goals feature
- Achievements system
- Year in Review feature

---

### 9. MOBILE EXPERIENCE (Low Priority)

**Currently Missing:**
- Mobile-specific tips
- Responsive feature notes
- Mobile app information (if applicable)

**What Exists:**
- Mobile usage survey link in Feedback section
- Responsive design throughout site

**Recommendation:** If no dedicated mobile app exists, add a note in FAQ or existing guides about mobile web experience. Low priority unless mobile app launches.

---

### 10. KEYBOARD SHORTCUTS & POWER USER TIPS

**Currently Missing:**
- Keyboard shortcuts list (if any exist)
- Power user workflows
- Efficiency tips
- Bulk operations guide

**What Exists:**
- Various UI features that may have shortcuts

**Recommendation:** Audit codebase for keyboard shortcuts. If they exist, add "Power User Tips" quick reference.

---

### 11. TROUBLESHOOTING / FAQ

**Currently Missing from Main Help:**
- Common issues compilation
- "Why can't I..." answers
- Browser compatibility notes
- Known limitations

**What Exists:**
- Troubleshooting section in "Organizing with Universes" guide (lines 396-446)
- Billing FAQ covers subscription questions
- Support email provided (andrew@indentlabs.com)
- Forum link for community support

**Recommendation:** Add dedicated "Troubleshooting & FAQ" page with common issues:
- Can't create more universes (free limit)
- Content not appearing (privacy/focus mode)
- Image upload failures (storage limits)
- Collaboration access issues
- Browser recommendations

---

### 12. QUICK LINKS SECTION

**Suggested additions to Help Center index page:**

| Link | Destination | Priority |
|------|-------------|----------|
| Privacy Policy | `/privacyinfo` | Medium |
| Billing FAQ | `/subscriptions/faq` | High |
| API Documentation | `/api/docs` | Low |
| Community Forums | `/forum` | Medium |
| Referral Program | `/data/referrals` | Low |
| Data Vault | `/data` | High |

---

## Proposed New Sections for Help Center

| Section | Priority | Type | Content Summary |
|---------|----------|------|-----------------|
| Quick Links | High | Section | Links to existing pages (Billing FAQ, Data Vault, etc.) |
| Managing Your Account | High | Full Guide | Settings, profile, security, deletion |
| Your Data | High | Full Guide | Export, backup, recovery, storage |
| Community & Sharing | Medium | Quick Reference | Streams, profiles, collections, forums |
| Finding Your Content | Medium | Quick Reference | Search, filters, navigation |
| Troubleshooting FAQ | Medium | Full Guide | Common issues, browser compat |
| API & Integrations | Low | Quick Reference | API docs link, integrations overview |
| Billing & Subscriptions | Low | Section | Links to existing billing FAQ |
| Lab Tools | Low | Section | Writing Goals, Achievements, etc. |

---

## Implementation Priority Matrix

### Immediate (High Impact, Low Effort)
1. Add Quick Links section to Help Center index
2. Link to existing Billing FAQ from Help Center
3. Link to Data Vault from Help Center

### Short Term (High Impact, Medium Effort)
4. Create "Managing Your Account" guide
5. Create "Your Data: Export & Backup" guide
6. Add Troubleshooting FAQ compilation

### Medium Term (Medium Impact, Medium Effort)
7. Create "Community & Sharing" quick reference
8. Create "Finding Your Content" quick reference
9. Expand or extract Collaboration guide

### Long Term (Lower Impact, Variable Effort)
10. API & Integrations documentation
11. Lab Tools documentation
12. Mobile-specific guidance (if applicable)
13. Keyboard shortcuts documentation

---

## Technical Notes

### File Locations
- Help views: `app/views/help/`
- Help controller: `app/controllers/help_controller.rb`
- Routes: Check `config/routes.rb` for help paths

### Styling Consistency
All new guides should follow the established pattern in existing guides:
- Hero header with gradient background
- Sticky Table of Contents (left sidebar)
- Section cards with icons
- Pro Tips / Info boxes
- Troubleshooting section at bottom
- Back to Help Center link at top

### Route Suggestions
For new guides, suggested paths:
- `/help/your-account` - Account management
- `/help/your-data` - Data export & backup
- `/help/community` - Community features
- `/help/troubleshooting` - FAQ/Common issues

---

## Appendix: Resources Audit

### Existing Routes Verified
- `/help` - Help Center index
- `/help/your-first-universe` - Getting started
- `/help/page-templates` - Templates guide
- `/help/organizing-with-universes` - Universe organization
- `/help/page-visualization` - Basil visualization
- `/help/document-analysis` - AI analysis
- `/help/organizing-with-tags` - Tags guide
- `/help/free-features` - Free tier guide
- `/help/premium-features` - Premium guide
- `/data` - Data Vault
- `/export` - Export options
- `/subscriptions/faq` - Billing FAQ
- `/api/docs` - API documentation
- `/forum` - Community forums

### External Links Used
- Google Forms for feedback
- Forum at notebook.ai/forum
- Support email: andrew@indentlabs.com
