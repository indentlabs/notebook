# Feature Section Writing Kit

Companion to `docs/tailwind_redesign_inventory.md`. One section per major new feature on the
`tailwind-redesign` branch, with the concrete details needed to write an announcement/changelog
section in the same style as the Books section: what it is, where it lives, everything a user
can do (with exact option names, values, and copy), and notable details. All details verified
against the actual code in this checkout.

Conventions:
- **"Don't announce"** notes flag things that look shippable but are dead code, unwired UI, or
  known bugs — exclude them from public writeups (or fix them first).
- Premium gating is called out per feature wherever it exists.

Features covered, in order:
1. Writing Goals · Writing Activity · Word Count Tracking · Timezones · Dashboard writing widgets
2. Document Editor overhaul · Folders · Document Analysis
3. Timeline Editor · Universe Encyclopedia · Universe Hub · Content Show Tabs
4. Template Editor · Images & Gallery · Basil · Help Center & Marketing · Admin · Exports
5. Forums · Private Messages · Moderation Hub · Stream/Sharing · Profiles V2 · Collections
6. Navbar Search · Collapsible Sidebar · Dark Mode · Dashboard · Misc UX (achievements, tags, tooltips, changelog, content indexes)

---

# PART 1: Writing Goals, Writing Activity, Word Counts, Timezones, Dashboard Widgets

## Writing Goals

**What it is:** Goal-tracking system: set a target word count over a date range ("50,000 words in 30 days"); progress tracked from real per-day word deltas across all content. Multiple goals can run simultaneously.

**Where:** `/my/writing-goals` (+ `/new`, `/:id/edit`, `/history`). Nav: profile dropdown "Writing Goals" (green flag icon). Also linked from dashboard "Daily Goal" and Writing Activity CTA. Not premium-gated.

**Bullets for the section:**
- Set a title, target word count, start date, and end date — that's the whole form; presets do the rest
- 4 quick presets on the form: Novel Challenge (50k/30 days), Week Sprint (10k/7 days), Daily Habit (500/day for 2 months = 30k/60 days), Two Week (25k/14 days); empty state shows 3 clickable preset cards (Novel Challenge 50k/30d, Week Sprint 10k/7d, Daily Practice 1,667/day for a year)
- Live "Daily goal to complete on time" preview recalculates as you type
- Multiple active goals at once; each gets its own progress card ordered by soonest deadline
- Active goal card: green gradient header with words written vs target, progress bar with % and words remaining, plus 4 stat tiles: **Ahead of/Behind pace** (vs expected-by-today), **Daily Goal to finish on time**, **Original Pace** (words/day), **Days Left**
- Always-on "Today's Progress" header: words today vs daily goal, progress bar turning green with a check at 100%, "Daily goal complete!" celebration, and a live HH:MM:SS "Time Left Today" countdown to *your* midnight (timezone-aware)
- Stats header: Total Words, Days Goal Met (X/Y), Day Streak, and a column chart of words/day with a dashed green goal line; range toggle 7d/14d/30d/90d
- Actions per goal: Edit, Complete, Archive, Delete (with typed confirm on delete)
- History page: archived + completed goals; completed goals get celebratory green cards with a trophy; expired goals are auto-marked complete when you visit history
- Daily goal notification: "Congratulations! You hit your daily word goal of 1,000 words!" — fires max once per day, timezone-aware
- If no goals exist, daily goal defaults to 1,000 words; with goals, it's the max daily_goal across active goals
- Progress uses **delta math** — only words written after the goal started count (baseline snapshot per entity)
- Fully dark-mode styled, responsive

**Data model:** new `writing_goals` table (user, title, target_word_count, start/end dates, active, completed_at, archived).

## Writing Activity Dashboard

**What it is:** Analytics page for words written: per-day, per-content-type, per-page breakdowns plus an activity log.

**Where:** `/my/writing-activity`, period selector `?period=24h|7d|30d`.

**Bullets:**
- Period dropdown: Last 24 hours / Last 7 days / Last 30 days
- 4 metric cards: Words Written, Active Days (of N), Best Day (max + weekday), Streak (days in a row)
- Daily Word Count area chart; Words by Content Type donut chart
- Recent Activity log: grouped by date w/ sticky headers, content-type icons/colors, page names linked to edit pages, green +N / red -N deltas; up to 50 entries; "Adjust Word Counts →" footer link
- Top Growing Pages: top 10 by words added in period
- Bottom CTA adapts: link to goals if you have them; otherwise "Create Custom Goal"/"Set a Goal" cards with copy varying by whether you wrote this period
- Streak = any day with words > 0, up to 365 days back; today-without-words doesn't break an in-progress streak
- All ranges computed in the user's timezone; dark mode supported

## Word Count Tracking System

**What it is:** Background ledger (`word_count_updates`) snapshotting each entity's word count once/day, so daily "words written" = day-over-day deltas. Plus a user-facing Word Count Logs page with manual adjustments.

**What counts:** Documents (body), ALL worldbuilding page types (sum of prose attribute fields — link/universe/tags fields excluded), Books (description + blurb), Timeline Events (title + description), manual adjustments. Forum posts/comments do NOT count.

**Bullets:**
- One consistent counting engine (WordCountAnalyzer gem): contractions/hyphenated words/URLs = 1 word, dates = 1 word, numbers count, ellipses/dashes/stray punctuation ignored, HTML stripped; the in-editor JS counter mirrors the same rules so live counts match server counts
- Memory-efficient path for huge documents: ≥300KB uses a lightweight scanner, chunked at 100KB boundaries
- Word Count Logs page (`/my/word_count_updates`): "Keep your writing stats perfectly tuned! Log words you've written in other apps, adjust your daily totals, or clean up your tracking history here."
- Manual adjustments: date + words (+/-), positive for untracked writing, negative to offset; edit inline or delete; honor-system note card ("It's not a competition!")
- 30-day activity bar chart with hover tooltips; tracking log grouped by date, up to 200 records; automatic records are read-only, deleted entities handled gracefully
- Timezone credited at write time (a queued job past midnight still credits the right day)
- Race-safe: unique index per entity/day + retry logic; dedupe protection
- Feeds: dashboard widgets, writing goals, writing activity, Data Vault year-in-review, admin words-written stats

**Data model:** unique index [entity_type, entity_id, for_date] (concurrent build in prod), [user_id, for_date] index, `cached_word_count` on timeline_events and books.

## Per-User Timezone Support

**What it is:** Users have their own timezone; "today," daily resets, streaks, and goal math happen at their midnight, not UTC.

**Where:** Account Settings → Preferences → "Time zone" card; silent PATCH `/users/update_timezone`.

**Bullets:**
- Timezone select over all Rails zones, with helper: "This affects when your daily word count resets and your writing goal calculations."
- Auto-detection banner: "We detected your timezone as Pacific Time (US & Canada)" + "Use this timezone →" one-click button (browser Intl API, IANA→Rails mapping of ~50 zones with US-offset fallback)
- Silent one-time backfill for legacy users on UTC (dashboard-mounted, expires Jan 31 2026)
- Used by: goals, activity, dashboard, documents index stats, word logs, goal notification
- Live midnight countdown on goals page driven by the same value

**Data model:** `users.time_zone` (string, default 'UTC', not null).

## Dashboard Writing Widgets

**Bullets:**
- **Writing Progress card**: 7-dot streak strip (weekday initials, orange = active, connector lines light up between consecutive active days, +3 dots hint when streak > 7), big streak counter with hover tooltip (🔥 gradient card, total words written during streak), Today's Progress section: words today vs daily goal with green progress bar and links to activity/goals
- **30-Day Activity card**: 30 purple bars with hover tooltips (date + words), links through to writing activity
- Empty-state variants for users with no content
- **Documents/Folders "Writing Stats" sidebar**: GitHub-style 7-square heat grid (intensity tiers at 100/500/1000 words, today ringed, hover tooltips), Today/Week totals, Documents/Folders/Total Words stats, Data Vault link; collapsible with pull-tab
- Streak = any day with words; capped 365; mid-day today doesn't break it

---

# PART 2: Document Editor Overhaul & Related Document Features

## The Editor (Medium-style writing canvas)

**Where:** `/documents/:id/edit`, dedicated editor layout (no footer). Documents brand color: teal; icon `description`.

**Bullets:**
- Distraction-free canvas: borderless giant title input (placeholder "Untitled"), small teal "EDITING" label, max-width column, placeholder "Write as little or as much as you want!"
- Floating selection toolbar (Medium Editor, bundled locally): Bold/Italic/Underline/Strikethrough, H1/H2/H3, four alignments, numbered + bullet lists, block quote, insert link (Ctrl+K), clear formatting — 16 tools with keyboard-shortcut tooltips
- Enter in the title jumps into the body instead of submitting; Tab stays in the editor; links open in new tabs
- Live stats: words, characters, minutes-to-read (200 wpm, "<1" under a minute), debounced 500ms; word-count circle grays out while stale then flips back teal when recomputed
- Autosave: saves 500ms after you stop typing + guaranteed save every 30s while typing continuously; bottom pill shows Saved / Unsaved / Saving... / Error states (green flash on success, red on failure); click the pill or Ctrl+S to save instantly; browser warns before leaving with unsaved changes
- Unified autosave for metadata fields: text fields save on blur/10s, dropdowns & checkboxes save instantly; per-field yellow/green/red border feedback + "Saving.../✓ Saved/✗ Error" labels + toast
- Copying strips background colors so dark-mode text pastes clean elsewhere
- Full dark mode; mobile fixes for long unbroken strings/horizontal overflow

## Sidebar Panel System (pull-out tabs)

- Four pull-tabs pinned to the right edge, sliding with the 320px panel: **Information** (info), **Linked Pages** (link), **Books** (menu_book), **Actions** (bolt); one panel at a time, chevrons flip, active tab teal
- Mobile (<1024px): same panels as slide-in drawer with backdrop, Escape closes
- **Information panel**: word-count hero circle + characters + min-read; privacy status button ("Click to change"); **Status dropdown (saves instantly)**; About This Document 2×2 grid → Universe / Folder / Notes / Synopsis modals; View Analysis (or Run Analysis) + Revision Log links
- **Linked Pages panel**: search "Search pages to link..." with live dropdown (top 10, already-linked excluded); filter-by-type buttons w/ counts appear at 2+ types; linked page cards expand to a "Quick reference" (Role/Type/Description snippets, 150 chars) + "View full page"; red unlink with confirm; empty state "Type @ in the editor or search above to link pages"
- **Books panel**: accordion of books containing this doc ("N chapters"); auto-expands if in exactly one book; chapter list with numbered badges (current chapter highlighted), links to sibling chapters; drag-and-drop chapter reordering (desktop); Edit book / Remove from book actions; "Add to book..." dropdown; Create New Book modal (creates book with this doc as first chapter)
- **Actions panel**: New Document + All Documents; Analyze Document; Sharing section → Manage Privacy, Preview as Reader, View as Plaintext, Printable View; Danger Zone → Archive/Unarchive + Delete (confirm)

## @Mentions / Content Linking

- Type **@** in the editor → dropdown at the caret, grouped by content type with colored icons; up to 50 results, 6/section expandable; smart relevance ranking; progressive caching (~7× faster per keystroke)
- Keyboard: ↑/↓, Enter/Tab to insert, Escape closes; dismissible hint chip "Press @ to link pages"
- Inserts `[[Type-ID]]` tokens; undo/redo preserved; mentioning a page auto-links it into the Linked Pages panel with a toast
- Server backstop scans bodies for tokens and links owned pages; readers see chip-style inline links with type icon/color; pasted notebook.ai URLs auto-convert to links; deleted pages degrade gracefully
- Free users get linking + quick reference; premium additionally gets background entity analysis

## Modals

- **Notes** — private notes "for your reference only, won't be visible to readers"
- **Synopsis** — "displayed in document listings and previews"
- **Universe** — purple-themed universe picker ("No universe" option)
- **Folder** — shared hierarchical folder dropdown
- **Privacy** — Private/Public radio cards saving instantly; two tabs when in a universe (Document Privacy / Universe Privacy) with a warning when the universe is public overrides; can change universe privacy if you own it
- **Share to Stream** — content preview card, optional message, warning that sharing makes it public, green Share to Stream button
- All: gradient headers, Escape/backdrop close, dark mode, "Save & Close" with inline ⏳/✓/⚠ feedback

## Document Statuses

- 8 statuses: **Idea, Draft, Writing (default), Revising, Editing, Submitting, Published, Complete**
- Set from the editor Information panel (instant save); shown in the index byline (`1,234 words · Writing · edited 3 hours ago`); multi-select status filter on documents index

## Archiving

- Archive from Actions panel Danger Zone; archived docs move to Data Vault archive page (`/my/data/archive`) with "Un-archive" buttons; excluded from listings and linkables

## Printable + Plaintext Views

- `/documents/:id/printable`: print-optimized serif page (Georgia 12pt, justified, 8.5in), title + "By author · N min read · N words", link tokens resolved, pasted colors stripped; `/plaintext` variant too

## Revision History

- Auto-revisions on change to title/body/synopsis/notes, throttled to one per 5 minutes
- Index: stats bar (N total versions, first backup, latest change), Current Version gradient card, timeline of revisions with word deltas (+N green / −N red), Show Preview + lazy-loaded Show Changes (side-by-side diff: removals red strikethrough, additions green bold), 60 per page
- Restore: snapshots current state as a new revision first, then restores title/body/synopsis/notes; confirm dialog explains this
- Single-revision page: amber "viewing a historical revision" banner, word difference vs current, Download as Text, newer/older navigation, read-only content view
- Diff of huge docs truncated at ~10k words for performance

## Documents Index Page

- Three-column layout:
  - **Quick Access** (left, persisted visibility, auto-opens only if you have documents): New Document + New Folder, 7 Recent Documents, top-5 Frequent Folders
  - **Center**: instant "Filter current view..." box; **List View / Timeline View** toggle (persisted); Tag filter; **Status filter (multi-select of all 8)**; Favorites toggle; on mobile all collapse into a single Filters button with active-count badge
  - **Writing Stats** (right): Documents/Folders/Total Words, Data Vault link, 7-day writing streak heat strip w/ Today + Week totals
- List view: Folders section + Documents section; byline `N words · Status · edited X ago`; inline favorite stars (favorites always sort first)
- Timeline view: docs grouped by day on a vertical timeline with time, folder pill, 150-char preview, word count + min read
- Sorts via URL: alphabetical / word_count / created / updated (default); server search covers title AND body
- Shortcuts: Cmd/Ctrl+K focus search, Cmd/Ctrl+N new document
- Welcome empty state with Create Folder/Create Document

## Folders

- Blank names default to "Unnamed Folder"; nested folders (parent/child)
- Shared hierarchical dropdown: indented tree with └ glyphs, alphabetized, can't pick itself as parent
- New Folder modal (auto-focus, nests under current folder); Edit Folder modal (rename, re-parent, delete)
- Delete relocates contents: documents + subfolders move to the parent (or root) — explicit multi-line confirm explains this
- folders#show literally renders the documents index → identical features scoped to the folder

## Document Analysis

- **Premium-gated**: "Our automated document analysis is a Premium-only feature" (queueing blocked for free users; upgrade CTA)
- Marketing landing at `/analysis` (logged-out): features Readability Analysis (Flesch-Kincaid, SMOG, Coleman-Liau), Writing Style Analysis, Emotional Analysis, FAQ, futures teasers
- **Analysis hub** at `/analysis/hub`: Total Analyses, Average Readability meter, Words Analyzed w/ trend, Style Improvement; "Documents to Analyze" (one-click queue), Recent Analysis Results table, Writing Insights, Writing Tips
- Per-document analysis: hero tiles (Words, Read Time, Readability color-coded, Sentiment face, Pages); tabs Overview · Readability · Style · Sentiment
- Readability: 8 scales (Flesch-Kincaid, Coleman-Liau, Dale-Chall, Gunning Fog, Linsear Write, SMOG, FORCAST, ARI), lexical richness, word variety/complexity, syllable counts
- Style: most-used words, words per sentence + baseline, parts of speech, **comparison to famous authors**
- Sentiment: overall + per-character emotions across Anger/Fear/Sadness/Disgust/Joy, dominant + secondary emotion, entity linking
- Comprehensive test suite added (content, flesch-kincaid, readability, syllables services)

---

# PART 3: Timeline Editor, Universe Encyclopedia, Content Show Tabs

## Timeline Editor Rebuild

**Where:** `/plan/timelines` (index), `/plan/timelines/:id/edit` (editor), `/plan/timelines/:id` (public viewer). **Premium-gated: only premium users can create timelines** (free users see "Upgrade to create Timelines" with a lock + Premium ribbon). New timelines drop you straight into the editor with one starter "Untitled Event."

**Bullets:**
- **Four pull-out panels**: left — Search/Filter + Linked Content; right — Event Details (inspector) + Timeline Settings. Colored edge tabs (green when open), one per side at a time, panel state remembered per browser; mobile gets full-height overlays with backdrop + Escape
- **Inline title/subtitle editing**: click to edit, Enter saves, Escape cancels; "+ Add subtitle" when empty; View button to the public page
- **Timeline Overview card** (collapsible): Description (with live word counter), public Notes, Private Notes ("only visible to you"), Tags with autocomplete suggestions (pulled from your existing timeline + event tags; Enter/comma to add), Universe picker — all autosaving
- **Event cards on a gradient spine** with a 48px circular event-type icon dot; fields: title, start time, end time (duration = start–end display), description (auto-growing) — all autosave 500ms after typing
- **13 event types**, each with its own icon + color: General, Setup, Exposition, Inciting Incident, Complication, Obstacle, Conflict, Progress, Revelation, Transformation, Climax, Resolution, Aftermath — changing type instantly swaps the dot's icon
- **Drag & drop reordering** with a drag handle, dashed "Drop event here" placeholder, card tilt while dragging, and **auto-scroll when dragging near the viewport edge**; also a per-card menu: Move to Top / Up / Down / Bottom / Delete
- Reordering rewrites the full order in one atomic request (fixes the old "events scattering" bug); requests are serialized so rapid drags can't interleave
- **Inspector (Event Details) panel**: live-updating header as you type in the card, Starts/Ends display, event type dropdown, tag management with optimistic add/remove + 12 built-in suggested tags (Character Development, Character Introduction, Worldbuilding, Flashback, Foreshadowing, Action, Discovery, Plot Twist, Turning Point, Relationship, Tonal Shift, POV Shift) + your own timeline tags, and a linked-content list
- **Link Content modal**: search all your pages (auto-focused; Enter links first result, Escape closes), filter rail by content type with counts, a "Timeline Content" filter showing pages already used in this timeline, sections sorted by recently-updated, first 20 per type with "Show all"; rows show Linking… → Added! → Linked feedback
- **Linked content on cards**: horizontal strip of image cards (pinned/random page image), name badge with type icon, hover remove
- **Drag pages from the Linked Content panel onto any event card to link them** — cards light up as drop zones with a "Drop to link content" pill
- **Search/Filter panel**: live search across titles + descriptions; tag filters with usage counts; **Filter vs Highlight modes** (highlight turns matching tag pills yellow instead of hiding events); "Showing N of M events" counter
- **Settings panel**: Privacy & Sharing card → Share modal; Archive/Unarchive; Danger Zone delete with explicit multi-line confirm (soft-delete → recoverable from Recycle Bin)
- **Share modal**: copyable share URL, universe-wide + timeline-specific privacy toggles (privacy explainer: content must be public or in a public universe), Twitter/Facebook share buttons
- **Index page**: card grid or list with favoriting stars, instant search, sort (Recently edited / Alphabetical / Date created / Most events), tag filter, sidebar with stats (Timelines/Events, Recently Edited, Event Types breakdown, avg events/timeline)
- **Word tracking**: event titles + descriptions count toward daily writing stats/goals (timezone-aware); timeline total word count shown on the viewer
- **Public viewer**: read-only spine with event-type dots, overview card, linked-content strips, and a "Creator Spotlight" footer (Events/Words/Links stats + "View more from <name>"); full dark mode; print styles
- Mobile: duration fields stack with a rotated connector, bigger touch targets, filter UI collapses

**Don't announce:** importance_level/status fields exist in the DB but have no UI; the ToC-style tag filters are internal only.

## Universe Encyclopedia / Table of Contents ("Wiki Gateway")

**Where:** `/universes/:id/contents` — deliberately a clean URL outside `/plan` for sharing. Public universes browsable by anyone with no account; private universes 404 for outsiders.

**Bullets:**
- **Hero banner** (universe image) with frosted-glass card: universe name, "Universe crafted by <name>", description
- **Stats bar**: total Pages and total Words across the universe, plus an "About <Universe>" button
- **Featured Articles** section — your favorited pages, shown as wiki cards (star heading)
- **Books shelf**: horizontal snap-scrolling book-spine cards with covers, hover lift
- **Content category sections** (alphabetical, deep-linkable anchors): colored icon + count badge per type, up to 7 wiki cards + a dashed "Browse N more <types>" tile linking to the full category index
- **Wiki cards**: image headers (or per-type placeholder art), type badge, name over gradient — hover zoom
- **Owner/contributor banner** explains what visitors can see: private universe = only you + contributors; public = visitors see only pages explicitly marked public
- Visitors only ever see public, non-archived pages; owners/contributors see everything
- **Category index pages** (`/plan/universes/:id/characters` etc., incl. Timelines): same hero, "Listing N <Type>" toolbar with Create New button for contributors, wiki card grid, and a bottom "Explore the Universe" CTA banner back to the encyclopedia
- **Encyclopedia sidebar card** on every universe page ("Encyclopedia / Explore this universe")

**Don't announce:** there is NO search/filter UI on the ToC page itself (the Stimulus filter controller exists but is unused); navigation is anchors + per-type browse links.

## Universe Hub / Multiverse Picker (`/my/multiverse`)

- "Welcome to your own personal multiverse" hero + "Learn more about universes" help link
- "View Everything" card + one card per universe with image, description, Owner/Collaborator role pill; active universe highlighted with purple ring + "Active" pill
- **Returns you to the page you came from** after picking a universe
- Universe limits UI: free plan progress ring "N/5" with warnings at 4/5 and 5/5 + upgrade CTAs; premium shows "Unlimited universes"

## Content Show Page Tabs (all content types)

**Where:** `/plan/<type>/:id` — three-column layout: navigation sidebar (left), dynamic content (center), quick links (right); mobile pull-tabs for both sidebars; floating "Share with community" button.

**Bullets:**
- **CATEGORIES group**: one tab per non-empty attribute category + "Show All Categories"; private fields hidden from non-owners
- **DIVE DEEPER group** (with live count pills):
  - **In This Universe** (universes): card per content type with counts + "View N <Types>" CTAs
  - **Gallery**: grid of images + saved Basil art, pinned badge, full-screen lightbox (Escape/backdrop close); "Add Images" for editors; only public images shown to visitors
  - **Associations**: "Referenced By" (pages linking here, with relation titles) + "Mentioned In" (documents, styled with ruled-paper hover effect); "Explore all connections →"
  - **Collections**: published collections featuring this page, with "Also includes" sibling previews
  - **Timelines**: "Referenced in Timelines" + "Appears in Timeline Events" with up to 3 related events per timeline
  - **Documents** and **Books** (universes): cards with excerpts
  - **Contributors** (universes)
  - **Shares**: threaded community discussion about the page with replies; owners get "Share to Community"
- **PAGE STATS**: visibility badge (click to manage privacy if editor; shows "(via universe)" when public through the universe) + word count
- **OWNER STATS** (owner only): created, last updated, change count → changelog
- **Privacy & Sharing view**: toggle public/private in place, updates the sidebar badge live without reload
- **Tab URLs sync to the hash** (`#gallery`, `#shares`, ...) so links restore the right tab; old `/gallery` URLs 301-redirect to `#gallery`
- Right sidebar: Gallery card, Encyclopedia card (universes), "IN UNIVERSE" card, Community block (Shares + per-type Forum link)
- Mobile defaults to expanded all-categories view; full dark mode; print styles

**Known bugs to fix before announcing (from research):**
- Timelines tab empty-state buttons link to `/timelines` (unrouted) instead of `/plan/timelines`
- Hash restore whitelist missing `in_this_universe`, `documents`, `books` (those tabs don't survive refresh/share); `#details` is whitelisted but renders empty
- Feedback tab fully built but gated `if false` (don't announce)

---

# PART 4: Template Editor, Images & Gallery, Basil, Help Center, Admin, Exports

## Template Editor

**Where:** `/plan/<type>/attributes` — "Character Template Editor" etc. Reached via "Customize Template" in edit/show sidebars, index Options dropdown, floating action buttons.

**Bullets:**
- Hero warning: editing the template modifies all already-created pages of that type
- Two-panel layout: category cards left, sticky 384px configuration panel right (mobile: "Template Editor"/"Configuration" switch tabs)
- **Category cards**: drag handle, icon, "N fields" count, Configure/Archive/Expand buttons; collapsible
- **Field types**: create **Text** or **Link** fields; system fields (Name, Universe, Tags) shown but locked "(Cannot be changed)"
- **Field config — 3 tabs**:
  - General: label; link fields get a Linkable Types checkbox list of every content type with Select All/None
  - Appearance: text fields choose **Small (one line) / Medium (multiple lines) / Large (rich text)** with live preview; link fields choose **Tags / Text / Cards** display style with live sample previews
  - Advanced: manual position control, **"Private: For my eyes only"** sharing restriction (private fields hidden even on public pages), archive/restore, two-step Danger Zone delete ("...all answers you've written to this field across all of your pages")
- **Category config**: rename, **icon picker with ~966 Material icons** (live preview), position, archive, delete requiring you to **type the category name** to confirm
- **Drag & drop everywhere**: reorder categories and fields with dashed placeholders + tilt effect; toasts confirm ("X moved to position N")
- **Smart suggestions**: "Show Suggestions" chips for categories and fields, learned from most-used attributes across the site; click to fill
- **General Settings panel**: template info + counters; **Export Template in 4 formats — YAML, JSON, Markdown (a full readable report with emoji), CSV**; Import Template "Coming Soon"; **Show archived items** toggle
- **Template Reset**: two-phase with an impact analysis first ("N categories and N fields will be deleted... N filled answers will be deleted across N pages"), per-field data-loss list, then **type the content type name** to confirm; rebuilds defaults from stock config
- API v1 endpoints for suggest/edit added

## Images & Gallery

**Bullets:**
- **Notes/descriptions on every image** — uploads AND Basil AI images; textarea per card, auto-saves on blur ("Save Notes" → "Saved!"); descriptions show as lightbox captions on the show page
- **Drag & drop image reordering** in the gallery panel (order persists via API, "Image order saved" toast)
- **Image pinning**: pin one image to always represent the page in previews/thumbnails everywhere ("Pin this image to always use it in previews of this page"); yellow ring + Pinned badge; pinning touches the page so it bubbles up in Recently Edited; system tests added
- **Private thumbnails everywhere**: dashboard cards, grid view, recent lists all show your private images to you (public-only for visitors); Basil art used as fallback thumbnails
- Upload UX: styled Choose File w/ thumbnail preview + file size, multi-upload, bandwidth meter ("You have X of bandwidth remaining"), formats note (JPG/PNG/GIF/WebP)
- Deleting an upload credits the file size back to your upload bandwidth
- Show-page Gallery tab: lazy-loaded grid, zoom hover, **full-screen lightbox** with caption (notes → filename fallback), Escape/backdrop close
- "Generate with Basil" section inline in the gallery panel with tips + free-tier counter

## Basil (AI art)

**Where:** `/ai/basil`. **Free tier: 100 free images** (premium unlimited); max 3 commissions per page in queue. 14 enabled page types: Building, Character, Creature, Deity, Flora, Food, Item, Landmark, Location, Planet, Technology, Town, Tradition, Vehicle.

**Bullets:**
- New shared hero header: "Hey, I'm Basil." with portrait + animated gradient
- Index: "Draw my..." sidebar of page types, free-tier usage bar (N/100), universe filtering
- **Generation workspace**: field details with **per-field importance sliders** (0–1.3; 0 = ignore field), "Show N more fields" opt-ins, style tiles with icons per style + **Experimental Styles** section (per-type style sets, e.g. Character: photograph/watercolor/pencil sketch/smiling/villain/horror + experimental anime/fantasy/scifi/historical/abstract/caricature)
- Helpful empty state suggesting exactly which fields to fill to unlock generation
- **Lightbox modal** for generated images (ESC/backdrop close, floating close button)
- **Save to page** (optimistic "Saved!") and Delete with animation; last 10 shown + link to feedback center
- **Rating system**: 6-point emoji scale — Very Bad / Bad / Meh / Good / Great / **Loved (heart)** — with colored hover states; instant save + "Rating saved! Thanks for your feedback." toast
- **Feedback center** (`/ai/basil/help/rate`): images-rated counter, filter by rating, 50 random unrated images at a time, "Hurrah, inbox zero!" empty state
- **Notes on commissions**: save notes on AI images (new endpoint + migration)
- **Stats page redesign**: In Queue / Avg Wait / Avg Rating Today tiles; **"Road to 1M Visualizations"** progress banner with expected completion date + rate; 7 charts (wait times, 30-day images area chart, historical-vs-today ratings, today's donut breakdown, avg/total score by style, quality by content type) — all dark-mode compatible
- **Review page** (admin): Top Creators (48h), live queue card, prompt inspection, **pagination at 100/page**, N+1 fixed

**Don't announce:** per-page-type stats page still on old Materialize design; /about page empty; VizJam is over.

## Help Center & Marketing Pages

**Bullets:**
- **Help hub** (`/help`): "How can we help you?" hero; 7 sections — Feedback & surveys (incl. premium-only feedback forms), About our worldbuilding pages (every content type), **Writing Tools** (Timelines/Documents/Books cards), Documentation (9 guide cards), Features & Capabilities, Quick Links, Contact Support (hello@notebook.ai)
- **11 guides**: Your First Universe (step-by-step), Page Templates, Organizing with Universes, Page Visualization with Basil, Document Analysis Guide, Organizing with Tags, Premium Features Guide, Free Features Guide, Managing Your Account, Your Data (export formats/recycle bin/archives/storage), Troubleshooting & FAQ
- **/writing marketing pages** (3):
  - **/writing/books** — "Write Your Book, Your Way": unlimited free books, drag-and-drop chapters, real-time tracking, analytics showcase (auto category from Flash Fiction to Epic Novel), export formats + "PDF and Scrivener export coming soon"
  - **/writing/documents** — "Capture Ideas. Craft Stories.": folders, autosave, streaks, status workflow, AI analysis (premium), revision history
  - **/writing/timelines** — "Build Your Story. Event by Event.": 13 narrative event types catalog, entity linking, premium framing
- **/analysis** landing (1,587 lines): "Understand and improve your writing" hero with mock analysis card, features deep-dive, FAQ, testimonials, roadmap teasers (Character Relationship Graph, Emotional Arc Visualization, Style DNA Profile, Worldbuilding Consistency, AI Scene Director, Cultural Reception Predictor)
- Per-type `/worldbuilding/<types>` template refreshed (private by default, premium/free labeling, dark mode mention, smart prompts)

## Admin Overhaul (internal)

- **Admin Hub** (`/admin/hub`): Sidekiq stats (Enqueued/Processed/Failed), Basil queue + done today, **Words Written Today/This Week**, link cards to Analytics/Moderation/User Management/Configuration
- Stats dashboard: **1d/7d/30d/90d** range pills; signup and subscription charts with net lines
- **Notification analytics**: reference-code search with autocomplete, 12-month trend, top-50 by volume cards → **per-reference-code drilldown page** (Total Sent/Clicked/Click Rate/Unique Users, avg/median/fastest/slowest time-to-click, campaign timeline, trend chart, sortable link performance table, sample message); SQL aggregation for millions of rows
- Churn: All Time/30d/90d/Year picker + per-plan breakdown
- **Reported shares**: View / Dismiss Reports / Delete Share / **Delete User** (with all-content warning); pagination; "All caught up!" empty state
- Redesigned: attributes, promos, images audit, hatewatch, spamwatch, mass unsubscribe

## Exports

- **Data Vault export page** (`/my/data/export`): six formats with cards — **Text Outline (TXT), Markdown, JSON, XML, YAML, CSV (one file per page type, all content types)**; date-stamped filenames; "Coming Soon": PDF, HTML, Scrivener
- XML/YAML exclude Documents and Timelines; export crash on deleted linked pages fixed
- **OpenCharacters export** (`/ai/talk/to/:id`) redesigned: build a conversational AI persona from your character (scenario, greeting, brief + in-depth personality, dialogue examples — editable by the owner), share public characters for others to talk to; OpenAI-key notice; "Chat with <Name>" CTA
- **Don't announce:** the character picker page (/ai/talk) is still old Materialize design

---

# PART 5: Forums, Private Messages, Moderation, Stream, Profiles, Collections

## Forums (Thredded) Redesign

**Where:** `/forum`, dedicated Tailwind layout sharing the app navbar + collapsible sidebar.

**Bullets:**
- **Forum nav pill bar**: All Forums / **Unread** (amber count badge) / **Inbox** (amber unread count badge)
- Messageboards index "Community Forums": card grid grouped by board group, unread badges (followed vs plain), topic + post counts, last-activity footer
- **Topic list redesign**: table-style with Topic/Replies/Last Activity columns; sticky topics highlighted blue with pin icon; locked topics dimmed w/ lock; "NEW" pill on unread; follow-state bell icons (pulsing amber = following w/ new replies); **"Last post by <user>"** meta (replaced "Started by"); category chips
- **Inline expanding new-topic composer**: "Start a new discussion..." collapsed input → expands with avatar header, title tip, categories multi-select, Preview toggle, submit disabled until content exists
- **Topic page**: compact header card with follow/unfollow, edit, delete; locked notice; top + bottom pagination; alternate kebab menu with **Export to document**, View as plaintext, View as chat log
- **Card-style posts**: 4px left border colored by the author's favorite page type; favorite-type mini icon badge on avatars; purple **"Mod"** badge for moderators; custom **forum badge text** for premium users (plus defaults: Admin / Beta Tester / Early Adopter / Premium Supporter); first post shows view + reply counts; posts from users you've blocked hidden entirely
- **Post actions dropdown**: Quote, Edit, Delete, Mark as Unread + moderation group: Report, Approve (moderators), Block User (moderators) — moderators can act inline anywhere
- **Reply form**: page @-mentions supported, Markdown help link, live preview panel, **Ctrl+Enter to submit** hint, user autocomplete
- Unread Topics page ("Followed topics appear first"); currently-online expandable widget; Tailwind Kaminari pagination
- Notification preferences redesigned (auto-follow, follow-on-mention, per-notifier checkboxes, per-board cards)
- Search results page redesigned (though in-forum search box intentionally removed)

**Don't announce:** forum search results page + collections submission modal are the two remaining light-only surfaces; the sub-nav notification-preferences link is disabled.

## Private Messages — Full-Screen Messenger

**Bullets:**
- **Inbox** (`/forum/private_topics`): conversation rows with stacked participant avatars (+N overflow), 100-char last-message previews, unread counts, inline expanding compose, **"Mark all read"**
- **Compose**: email-style form with gradient header, **type-ahead user autocomplete** for participants, preview
- **Conversation = full-screen messenger**: no footer/breadcrumbs, true chat viewport (dvh-aware); desktop two-pane with conversation list sidebar (active convo highlighted); **chat bubbles** — yours right-aligned blue, theirs left-aligned white; sender avatars, timestamps, **read receipts** (blue double-check); auto-scroll to newest; pinned pill-shaped composer with auto-growing textarea + circular send button; mobile collapses to single pane with back arrow
- Edit conversation: title only ("Participants cannot be changed after a conversation is created")

## Moderation Hub

**Where:** `/moderation` — gated to forum moderators. "Moderation" link in the forum sub-nav with a red pending-count badge.

**Bullets:**
- Hub: **Reported Shares** and **Forum Moderation** cards with pending counts + CTAs
- Moderation tabs: **Pending / History / Activity / Users**
- Pending queue: stats (Pending Review / Approved Today / Blocked Today), post cards with Approve + Block User actions, author linked to their moderation page
- Activity: recent forum activity feed with content previews
- History: vertical timeline of moderation actions (approved/blocked markers)
- Users: search, table with moderation-state pills (Approved/Blocked/Pending), member-since, View actions
- **Share/comment moderation**: admins can delete any shared post; dismiss reports; delete user + all content (with warning); per-comment delete for comment author, share owner, or admin; share comments cleaned up on account deletion + daily orphan sweep

**Don't announce:** Pending filter chips (All/Topics/Replies/Reports) and History filter selects are presentational only — not wired.

## Stream / Sharing

**Where:** `/stream` (Following) and `/stream/world` (Everyone).

**Bullets:**
- Sticky **Following / Everyone** toggle; post counts; per-mode empty states + "Discover Creators"
- **Collapsible share composer**: "Want to share a page with the world?" → grouped select of all your content, optional message, "Page will be made public" note
- **Feed items**: avatar with colored content-type badge, "shared a <type chip>" with **human-readable type names**, permalink, content preview card (thumbnail, type-colored border, description); kebab menu: View details / Delete (owner or admin) / **Report post**
- **Comments**: first 2 shown inline with "View all N comments", quick comment box on every item ("Add a thoughtful comment..."), copy-link Share button
- Spam/blocked forum topics filtered out of stream; blocked users' content excluded both ways
- **Share to Stream modal** (content pages, books, documents): preview card, optional message, "sharing makes it public" warning
- **Creator notifications**: when someone shares your work — "🎉 <name> shared your <type> <page> with the community!"; commenting notifies all share followers ("commented on the/your shared...")
- Follow/unfollow individual shares; reports go to admin queue
- Public collection creation auto-shares "I created a new Collection!"
- **Shares tab on content pages**: threaded discussion (shares + nested replies), "Reply to this thread"/"Be the first to reply", owner "Share to Community" button
- Right sidebar: "Conversations Happening Now" (5 most active forum topics)

## User Profiles V2

**Where:** `/users/:id` and `/@username`.

**Bullets:**
- Hero: banner image (or gradient), avatar with **online dot**, verified badge, @username, **bio with smart Show more/Show less** (only when actually truncated), location/joined/website row
- Stats: Pages / Followers / Following / Words (counter-cached, indexed)
- Follow/Unfollow, **Message** button (only if user has a username), block handling, share-profile FAB
- **7 tabs**: Overview, Universes, Content, Tags, Activity, Collections, Community
  - **Overview**: About card (favorite quote blockquote + Also known as / Interests / Favorite genre / Favorite author / Favorite book / Inspirations tiles), Recently Updated Universes, At a Glance (day streak, last active, content types, unique tags), Content Highlights, Recent Activity, Popular Tags
  - **Universes**: search + sort (Recently Updated/Created/Alphabetical/Most Words) over cover cards
  - **Content**: search, grid/list toggle, per-type filter chips
  - **Tags**: tag cloud (font size scales w/ usage) + list with usage bars; search + popularity/alphabetical/recent sorts
  - **Activity**: stat cards + filterable timeline (shares, forum posts); page edits deliberately excluded from profiles
  - **Collections**: "Collections I Maintain" + "Published In Collections" (Featured badges)
  - **Community**: Followers/Following/**Mutual connections**; avatar grids with online dots + Mutual chips
- Privacy: only public content ever shown; private profiles and blocked users fully hidden; "Content is no longer public" fallbacks
- Followers/Following pages redesigned with user cards (100/page)
- Accent color/icon derived from the user's favorite page type; JSON-LD Person schema for SEO

## Collections Upgrades

**Where:** `/collections`. Creating a collection is premium-gated ("Upgrade to Create a Collection").

**Bullets:**
- **Index hub** with tabs: Featured Collections / My Collections / Following / **Open for Submissions**; "Accepting Submissions" badges; pending-review indicators for your collections
- **4-step creation wizard** with progress bar + clickable step chips (completed = green ✓):
  1. **Basics** — title, subtitle, description (live 0/500 counter, amber→red as you approach)
  2. **Visual** — header image drag-and-drop (1200×400 recommended), 4 themes (Default/Warm/Nature/Mono)
  3. **Content** — pick accepted content types (Common Types / All / None quick-selects)
  4. **Settings** — Public/Private, "Allow submissions from other users", nested **Auto-accept** toggle with trust warning
  - **Live preview panel** updates as you type, with desktop/mobile preview toggle; Ctrl+←/→ step navigation
- **Magazine-style collection pages**: masthead with serif titles, "Curated by", content-type section pills, sort chips (**Recent / A-Z / Chronological / Shuffle**), article entries with submitter explanations quoted as editorial blockquotes, **infinite scroll** (5 at a time)
- Sidebar: search + type/date/author filters (NOTE: presentational only), Collection Stats, **Editorial Board** ("Editor-in-Chief" + contributors), Get Involved (Submit/Follow), Share buttons + **RSS**
- **Editor's Picks**: owners feature up to **6** published submissions at the top of the collection (drag-to-reorder management page, positions unique per collection); type-scoped views show "Featured <Type>s"
- **RSS feeds** (`/collections/:id/feed`): full RSS 2.0 with content:encoded, editor's notes, enclosure images, auto-discovery link; 50 items
- **Submission flow**: submit modal with eligible-content select + "Why should this be included?" explanation; owner **Submission Manager** with Publish/Decline review cards; approval notifies the submitter ("...was approved!"); auto-accept mode publishes instantly; submitting to a public collection makes the content public
- Follow/report collections; contributor-scoped views (`/by/:user_id`)

---

# PART 6: Search, Sidebar & Layout, Dark Mode, Dashboard, Misc UX

## Inline Navbar Search Dropdown

**Bullets:**
- Live autocomplete in the navbar searching **your own notebook by name**: all 29 worldbuilding page types + Documents (Universes included; Timelines/Books not searched)
- Min 2 characters, 300ms debounce; up to 12 results, exact-name matches ranked first
- Rows: circular colored type icon + page name + type subtitle + chevron; flat relevance-sorted list
- **Keyboard**: ↑/↓ to select, Enter to open (or fall through to full search), Escape closes + blurs
- **Search tips panel** when focused & empty (desktop): "Start typing to see your pages as suggestions" / "Click on any result..." / "Press Enter to search all content"
- Footer escape hatches on every query: **"Search my notebook for '<q>'"** and **"Search the forums for '<q>'"**
- **Mobile**: focusing flips into a full-screen search bar (navbar-colored, back arrow to exit); sidebar auto-closes; dropdown pins full-width
- **Full results page** (`/search?q=`):
  - Searches **all attribute/field content** plus names/titles — so it finds text buried anywhere in your pages
  - **Multi-word = AND logic** (every word must appear), database-agnostic
  - Left sidebar: query chip, "All results" with count, **Filter by type** (only types with hits, with counts), contextual suggestion cards; mobile native select
  - Sort tabs: **Best Match / Most Recent / Oldest**
  - **Refine within results** box (appears at >5 results)
  - Result cards: thumbnail (private images included), universe breadcrumb, **which field matched** pill, 200-char preview with **every query word highlighted** in yellow
  - Dedup: one best field match per page; 100/page pagination; helpful empty state
- `/` anywhere on results page focuses search

## Collapsible Sidebar & App Layout

**Bullets:**
- New app shell: fixed navbar + collapsible left sidebar; content, navbar, footer all animate together (300ms)
- **Expanded (224px)**: three collapsible sections with colored rails —
  - **Worldbuilding** (blue): one row per activated content type with its icon/color + **page count badges**; "Add more..." → content type toggles
  - **Writing** (green): Books, Documents, Timelines, Prompts
  - **Community** (purple): Collections, **Discussions with amber unread badge** (followed topics w/ new replies), Activity
- Active page highlighted; section auto-expanded per current page area
- **Collapsed (64px) = icon ribbon**: every type + section icon with **instant tooltips** that escape the overflow container (custom fixed-position tooltip)
- Collapse via chevron button; expand via the logo; **state persisted in localStorage**
- **Zero-flash init**: inline head script applies saved geometry before first paint and suppresses transitions until hydrated — no sidebar jump on load (this was a real bug fixed: "Fix sidebar layout jump on page load")
- **Mobile**: off-canvas drawer with backdrop, scroll lock, hamburger open, force-close on search focus; desktop preference restored on resize
- **Universe picker moved into the sidebar footer**: active universe card ("UNIVERSE" / "Change") or "Choose a universe / Filter your notebook" card
- Navbar: yellow avatar ring when inbox has unread; red inbox count in account dropdown; notification panel widened on large screens; book-shaped notification/user buttons

**Don't announce:** `_sidenav.html.erb` is a dead Flowbite demo file.

## Dark Mode

**Bullets:**
- Per-user setting stored server-side (`dark_mode_enabled`) → rendered on the `<html>`/`<body>` tags server-side, so **no light flash on page load**
- **Two toggles**: navbar account dropdown "Toggle Dark Mode" (instant, no reload, persists via background request) and Settings → Preferences ("Dark mode — Great for night-time worldbuilding sessions.")
- Coverage is effectively site-wide: dashboard, content pages, editors, forums, admin, charts (custom dark ramps/inversion tricks), modals, pagination — rolled out across dozens of commits
- Legacy Materialize pages get a dark stylesheet too
- Same Preferences pane also has: Time zone (w/ auto-detect banner), Keyboard shortcuts toggle ("Press ? to view available shortcuts"), notification prefs, Community features toggle, Private profile

## Dashboard Redesign

**Bullets:**
- Hero: avatar w/ online dot, "Hello, <name>", **Quote of the Day** (~115 writing quotes rotating daily, same for everyone), and a **"casino" random-create button** (random page type, die icon, ripple burst on click)
- **Serendipitous Question card**: picks a random unanswered prompt from your own pages — hero image, type badge, question headline ("What is <Name>'s <field>?"), inline textarea with **@mention support and autosave** ("What you type will autosave to your <Name> page"), "Answer more questions" → Prompts page
- **Writing Progress card**: 7-dot streak chain with connector lines, weekday initials, "+3 dots" overflow when streak > 7, hover tooltips (per-day words + a 🔥 gradient streak summary), 🎉 click easter egg; Today's words vs Daily Goal progress bar with links
- **30-Day Activity**: purple bar chart with hover tooltips, links to Writing Activity
- **Recently Edited**: 7 most recent pages with **image thumbnails** (private included), edited-ago, favorite stars, links to edit pages
- **Create Something New ribbon**: dense grid of all activated types + Document + Timeline; icons cross-fade to "+" on hover; "More..." tile
- **Most-Edited Pages**: horizontal scroll of top 20 by change events (private images allowed)
- **Trending Conversations**: 6 most active forum topics of the last 30 days
- New-user null state: welcome card, free-tier explainer (Character/Location/Item + 25 premium types), big Create Universe/Character/Location/Item/Document buttons, community discussions
- Scroll-reveal animations; gradient background; stats consolidated from 3 cards to 2; all timezone-aware

**Don't announce:** `_activity_bar`, `_content_library`, `_whats_new`, `_active_discussions` partials are dead/not rendered (What's New card is commented out).

## Misc UX Features

### Achievements page (`/my/data/achievements`)
- **41 achievements in 5 sections**, each with live progress bars + percentages (locked ones show progress too):
  - Content Creation: 1/10/25/50/100/250/500/1000 pages
  - Activity: 10–10,000 updates; 5–365 active days
  - Consistency: 3/7/14/30/60/100-day edit streaks
  - Diversity: 3–25 content types
  - Special: Universe Creator, Character Ensemble (10 characters), World Explorer (5 locations), **Tree Saver** (a tree's worth of paper saved, via GreenService)

### Tag browse page (Pinterest-style masonry)
- `/browse/tag/:slug` — currently gated to the **ArtFight2025** showcase
- Hero with Pages/Creators stats; sticky filter bar with per-type chips (URL-hash synced) + sort (Latest/Oldest/A-Z/Z-A/Randomize)
- True CSS-columns masonry (2–6 cols), 3:4 cards with hover zoom+tilt, type badges, creator attribution overlay
- "How to join this showcase" dialog (3 steps + Art Fight disclaimer)

### Tags field type + shared tag input
- New **tags field type** in page templates: pills in the page type's color, Enter/comma to add, quick-tags panel of your existing tags for that type, autosaves every change, also creates real PageTags
- Tag pills on pages link smartly (own pages → your tag index; artfight2025 → public browse; else user tag pages)
- Reusable tag input component (used in timeline editor etc.): autocomplete (10 max), per-tag loading spinners, optimistic add/remove with rollback, 'Press Enter to create "<tag>"'

### Link field display styles
- Pick per link field in the template editor: **Tags** (icon pills, default), **Text** (bulleted links), **Cards** (horizontal-scroll 160px image cards) — with live preview in the editor

### Universe filter reminder
- Bottom of every filtered content index: "Universe Filter Active — You are currently only seeing <types> in <Universe>" + "See all <types>" button that preserves your sort/tag/favorite filters

### Instant CSS tooltips
- Zero-JS tooltip system (`tooltip-left/right/top/bottom` + `data-tooltip`), 0.15s fade, used in 23 places; replaced slow browser title tooltips and duplicate JS tooltip systems

### Typed delete confirmations
- Page delete: type **OK** → "Delete permanently"
- Template reset: data-loss analysis, then type the content type name
- Category delete: type the category label
- Folder delete: detailed multi-line confirm explaining where contents move

### Changelog page ("Your Creative Journey")
- Stats: Total changes, Days with edits, Biggest Edit Session, Since creation
- **GitHub-style weekly activity heatmap** (up to 52 weeks, 5 intensity tiers, auto-scrolled to today, Less→More legend)
- "Your Longest Writing Streak" insight card
- **Collapsible date-grouped timeline** on a gradient spine (first 3 groups open); per-session editor avatars; per-field diff cards with **side-by-side before/after** (red/green, word-count pills), Copy Previous/Copy Current buttons; tags/link/universe/name diff renderers; private-field masking
- Smart pagination (50/page, 1 … n-1 n n+1 … last)

### Content index pages
- Hero banner per type; New <Type> button (or Upgrade CTA); Options → Customize template
- **Instant client-side search** (⌘K focus shortcut), sort (Recently edited/Alphabetical/Date created), tag filter dropdown with Apply + removable filter chips
- **Grid/List toggle** with instant tooltips + keyboard shortcuts (1 = grid, 2 = list); ⌘\ toggles sidebar
- **Pagination top AND bottom** (50/page, sliding 5-page window, filter-preserving)
- Cards: image priority (your images → Basil art → type art), View/Edit buttons, **optimistic favorite stars**; trailing "Customize Template" and "New Content" dashed cards
- Inline collapsed serendipitous question bar ("Answer question" → expands with autosave + mentions + "Save & get another question")
- Search-empty and true-empty states with helpful CTAs
