# tailwind-redesign Branch Inventory

**Everything that's new on `tailwind-redesign` compared to `master`.**

Generated from git history on 2026-08-06.

- **1,031 commits** ahead of master (master is fully merged in; nothing on master is missing)
- **Span:** January 2022 → August 2026
- **Diff:** 775 files changed, ~103,000 insertions, ~21,700 deletions
- **366 new files** added

---

## 1. Brand-New Features (net-new functionality)

### Books (manuscript organization)
- New `Book` and `BookDocument` models, controller, authorizer, and full CRUD UI
- Organize documents into books/manuscripts with drag-and-drop chapter reordering
- Books index with favoriting, archiving, and universe filtering
- Public book pages, book settings sidebar with privacy toggles
- Books sidebar panel inside the document editor (add/create/remove documents)
- Analytics sidebar with expandable document list on books edit page
- Cached book word counts (background job)
- Book as a linkable content type in documents

### Writing Goals
- New `WritingGoal` model, controller, and full UI (`/my/writing-goals`)
- Multiple simultaneous active goals + goals history page
- Quick presets with pre-filled values and title auto-fill
- Auto-completion of expired goals
- Daily word goal notification (background job)
- Progress charts with threshold lines

### Word Count Tracking System
- `WordCountUpdate` records with a unified `WordCountService` (standardized counting across Ruby and JavaScript)
- Real-time word count updates on content edit pages and document editor
- Client-side document word count tracking
- Manual word count adjustments
- Word tracking extended to Books and Timeline Events
- Word count logs page (`/my/word_count_updates`)
- Writing streaks based on actual word data (not `updated_at`)
- Dedup/unique indexes, cleanup rake tasks, many correctness fixes (timezones, doubling, inflation on recovery)

### Writing Activity Dashboard
- New `/my/writing-activity` page with period selector
- Daily word count charts, per-page activity, links to edit pages
- Dashboard "Words Today" card with weekly stats

### Per-User Timezone Support
- `time_zone` column on users, timezone detection + silent auto-update (Stimulus controllers)
- Shared timezone utility module; goal/streak/word-count calculations respect user timezone

### Inline Search Dropdown (navbar autocomplete)
- New `search/autocomplete` endpoint with dynamic navbar dropdown
- Database-agnostic multi-word search
- Redesigned full search results page with filters and sorts
- Instant client-side search filtering on index pages; mobile-friendly full-width dropdown

### Collapsible Sidebar & New App Layout
- All-new Tailwind app shell: navbar, sidebar, sidenav
- Collapsible left sidebar with icon-ribbon collapsed mode
- Pull-out tab system used across the app (documents, timelines, books, content edit)
- Mobile sidebar with dedicated Stimulus controller
- Persisted Quick Access sidebar visibility preference
- Universe picker moved into the sidebar

### Dark Mode
- Site-wide dark mode support across dashboard, content pages, forums, editors, admin, charts, modals, pagination — rolled out over dozens of commits

### Document Editor Overhaul
- Medium-style clean editor (Medium Editor bundled locally)
- Three-panel sidebar system with toggle tabs: Information, Actions, Entities/Linked Pages, Books
- @mention auto-linking with optimized mention search
- Separate Notes / Synopsis / Universe modals (was one metadata modal)
- Share to Stream modal with content preview
- Document **statuses** (workflow tracking, e.g. "Writing") + status filter on index
- Document **archiving** (+ archive page) 
- **Printable view** for documents
- Revision **diff and restore** (new `diffy` dependency), 60 revisions per page
- Unified/enhanced autosave system with visual feedback
- Folder selection from the editor; linked entity cards; EDITING label

### Timeline Editor Rebuild
- Rearchitected with server-side event rendering
- Drag & drop event reordering with auto-scroll near viewport edges and a single full-order reorder endpoint
- Pull-out panel system: Settings, Search/Filter, Inspector, Linked Content panels
- Event tagging (add/remove tags endpoints), enhanced duration fields
- Link Content modal with search + recency sort
- Timeline sharing modal, Privacy & Sharing settings, favoriting/archiving
- Timeline event word tracking

### Universe Encyclopedia / Table of Contents ("Wiki Gateway")
- Public universe browsing via redesigned Table of Contents (`/universes/:id/contents`)
- Universe content tabs and Encyclopedia sidebar card
- Owners/contributors can see private content in the encyclopedia
- Universe hub redesign

### Help Center
- New help hub with SEO hero + ~11 new guide pages: Your First Universe, Page Visualization, Document Analysis, Organizing with Tags, Organizing with Universes, Page Templates, Premium Features, Free Features, Your Account, Your Data, Troubleshooting
- New `/writing` marketing/info pages for Books, Documents, and Timelines
- Document analysis landing page and hub

### Moderation Hub (forums)
- New `/moderation` hub for forum moderators
- Redesigned Thredded moderation pages (pending, activity, history, users)
- Comment/share moderation UI; spam comment cleanup on user deletion
- Report post option on stream; admins can delete any shared post; dismiss share reports

### Admin Overhaul
- New admin hub page
- Redesigned (Tailwind) stats dashboard with time range selector
- Redesigned: attributes, promos, images, hatewatch, spamwatch, unsubscribe, reported shares pages
- Notification analytics with SQL aggregation, client-side sorting, and per-reference-code drilldown page
- Churn timespan picker; words-written-today/this-week stats

### Collections Upgrades
- Multi-step creation wizard with live preview
- Editor Picks system (new controller, management page, position column)
- RSS feeds for collections (`/feed`, `/rss`)
- Infinite scroll pagination; redesigned show/edit/index

### Template Editor (attributes editor)
- Completely new template editor UI
- Template export, initialization, and reset services (+ routes)
- Category/field sort endpoints, edit endpoints, and suggestion endpoints (API v1 additions)

### Images & Gallery
- Notes on image uploads (new column + UI)
- Image descriptions, including for Basil commission images
- Gallery panel redesign with event delegation; standardized upload components
- Private thumbnails used across dashboard, grid view, and recent lists
- Image pinning fixes + system tests

### Basil (AI art) Improvements
- Lightbox modal for generated images
- Rating UI redesign with colored hover states
- Stats page redesign with dark-mode charts
- Review page pagination; commission notes; update-commission endpoint

### Stream / Social
- New stream feed design with feed item partials
- Share notifications: creators notified when others share their work; human-readable page type names
- Comments/Shares tab on content pages
- Spam/blocked forum topics filtered out of stream

### Forums (Thredded) Redesign
- Full Tailwind restyle of topics, posts, messageboards, search, preferences
- Forum navigation with Unread link and Inbox link with notification count
- Currently-online display
- Private messages: full-screen messenger UI, redesigned private topics
- Tailwind Kaminari pagination theme

### User Profiles V2
- Tabbed profiles: Overview, Activity, Collections, Community, Content, Tags, Universes
- Profile bio improvements; privacy filtering (public content only)
- Counter caches + performance indexes for profiles

### Other New Pages & UX
- Achievements page (`/my/data/achievements`)
- Tailwind styleguide page (`/styleguide/tailwind`)
- Tag browse page redesign (Pinterest-style masonry)
- New tags field type with shared tag input component
- Link fields with selectable display styles (Tags, List/Text, Cards)
- Folders inside worldbuilding pages; folder creation modal; folder hierarchy shown with indentation in dropdowns
- Universe filter reminder UI on content index pages
- Instant CSS tooltips replacing browser/JS tooltips site-wide
- Delete confirmations requiring typed text
- Changelog page redesign with activity chart + stats service
- Dashboard redesign: streaks, words today, recently edited with thumbnails, quote of the day, what's new, active discussions, serendipitous question with autosave
- Redesigned landing pages, pricing, signup/login (Devise), billing pages, data vault, OpenCharacters export page

## 2. Platform / Infrastructure Changes

- **Tailwind CSS** added and upgraded to v3 (PostCSS 8, purge config, custom `tailwind.config.js`); MaterializeCSS migration completed and cleaned up
- **Alpine.js** (+ Collapse plugin) and **Stimulus** controllers introduced
- **SendGrid → Amazon SES** transactional email migration
- **Google Analytics UA → GA4** migration
- Containerization: Dockerfile updates, `Dockerfile.debug`, docker-compose webpack dev server
- Custom Devise sessions controller; password change page requires authentication; session invalidated after account deletion
- New gems: `diffy`, `mini_magick`; removed `tribute`; removed CodeClimate
- Medium Editor and chartjs-plugin-annotation vendored locally
- Cron schedule (`config/schedule.rb`), backups + cache maintenance rake tasks
- API v1 additions: content sort, page-name lookup, attribute category/field edit + suggest

## 3. Performance Work

- Dozens of N+1 query fixes (dashboard, profiles, forums, content index/edit, Basil, serializers, exports)
- New composite indexes: content change events, word count updates, document archive queries, notifications
- Counter caches on users (+ daily reset rake task)
- Slow-query fixes: DataController#green (14s), admin notifications at millions of rows, login-time ContentChangeEvent query
- Memory-efficient word counting for large documents

## 4. Notable Removals

- Legacy Materialize layouts/views (retained only as fallback during transition, then cleaned up)
- "Back to old layout" escape hatch (added during transition, later removed)
- Legacy `TemporaryFieldMigrationService` (dead code from 2020)
- Full-width layout preference option
- Old timeline event move up/down/top/bottom endpoints (replaced by full-order reorder)

---

*Sources: `git log origin/master..origin/tailwind-redesign`, `git diff origin/master...origin/tailwind-redesign` (routes, Gemfile, added files).*
