# Gallery management: UX & quality-of-life plan

> **Status (2026-09-02):** Phases 1 through 4 and the round-two items in section 7 are implemented on `tailwind-redesign`.
> Decisions taken: random cover stays when nothing is pinned; Cropper.js drives the editor;
> crops are generated on Paperclip now (behind `ImageDerivativeService`); no separate alt-text field, notes only.
> After deploying, run `rake gallery:backfill_dimensions` then `rake gallery:backfill_crops` so
> existing uploads get their banner/card/square derivatives (until then they render through the
> focal-point fallback). Of the Phase 5 extras, undo-delete, bulk actions, replace-image and rotate remain open.

Scope: the **Gallery** tab of `content#edit` (`app/views/content/edit/_gallery_panel.html.erb`, also rendered by `books/edit`), the endpoints behind it, and every place around the site that displays a page's image (banners, cards, thumbnails, social previews).

Goal: turn the gallery from "a list of files with a pin" into a place where a writer decides **which image represents a page and exactly how it is framed everywhere it appears**, without page reloads, native `confirm()` dialogs, or CSS guessing.

---

## 1. What's there today

### 1.1 The panel

- One ERB partial (629 lines) renders a 2-column grid of cards, an upload form (cocoon nested fields, full-page `PATCH`), and a "Generate with Basil" block.
- Each card: image (`src(:medium)`, i.e. max 300 px, shown ~560 px wide), file size, a notes textarea, a delete button, a pin button, a hover-only drag handle, and a "Pinned" badge.
- Two image sources are supported and handled with two nearly identical ~60-line branches: `ImageUpload` (Paperclip on S3) and `BasilCommission` (ActiveStorage on S3).
- Inline `<script>` (≈330 lines): pin toggle, delete, notes autosave, jQuery UI sortable, a toast helper, and a `MutationObserver` on `document.body` that re-runs init on every DOM mutation.
- Ordering is saved through `POST /api/v1/gallery_images/sort` (`Api::V1::GalleryImagesController`), pinning through `POST /toggle_image_pin` (`ContentController#toggle_image_pin`), notes through `PATCH /image_uploads/:id` and `PATCH /basil/commission/:id`.

### 1.2 Bugs and rough edges (as observed)

| # | Problem | Where / why |
|---|---------|-------------|
| 1 | **"Pinned" badge overlaps the notes textarea.** | Badge is `absolute bottom-12 left-3` on the whole card wrapper, not on the image area, so it lands inside the footer. |
| 2 | **Pinning feels janky.** No optimistic state; the JS hand-mutates classes, creates badges by string, and looks other cards up via `.bg-yellow-400`. The active/inactive classes don't match (`text-gray-400` added, `dark:text-gray-300` never removed). Nothing explains what pinning does. | `handlePinClick` in the partial. |
| 3 | **Drag handle is an oval, and only exists on hover in the middle of the picture.** | `p-2` around an inline Material icon with no fixed box; hidden below 768 px, so there is **no reordering at all on phones** even though `jquery.ui.touch-punch` is loaded. |
| 4 | **Blurry grid images.** | `src(:medium)` is `300x300>`; cards are ~560 px wide on desktop. |
| 5 | **Basil images are always the full original**, served with `disposition: "attachment"`, so clicking them downloads instead of opening. | Every Basil `image_tag` uses `rails_blob_path(..., disposition: "attachment")`. |
| 6 | **Aspect box works by accident.** `aspect-w-16 aspect-h-9` is not a Tailwind class in this config (no aspect-ratio plugin); it only works because `timeline_viewer.scss` happens to define it and is globally required. | Use Tailwind 3's built-in `aspect-video`. |
| 7 | **Uploads reload the page.** One file per cocoon row, "Add another image", then submit. No drag-and-drop, no multi-select, no progress, no client-side size check against the bandwidth quota. `ImageUploadController#create` is an empty stub. | `content/form/images/_upload*.html.erb`, `ContentController#upload_files`. |
| 8 | **Notes save on every blur**, changed or not, and a "Save Notes" button pops in and out on focus. | `handleNotesSave` + focusin/focusout handlers. |
| 9 | **Delete uses the browser `confirm()`**, the card vanishes with no undo, and the "(4)" count, sidebar badge, and bandwidth line don't update. | `handleDeleteClick`. |
| 10 | **No per-image privacy UI** even though `image_uploads.privacy` exists and is used for filtering. Uploads are always `public`. | `upload_files` hard-codes `privacy: 'public'`. |
| 11 | **Authorization is inconsistent across endpoints.** Pin allows universe contributors; notes update requires `image.user`; delete requires owner; Basil update/delete require `user: current_user`. | `ContentController#toggle_image_pin`, `ImageUploadController`, `BasilController`. |
| 12 | **Duplicate logic.** The view rebuilds the combined/sorted list inline although `combine_and_sort_gallery_images` exists in `ApplicationHelper`; three fetch helpers each look up the CSRF token; a toast helper is re-implemented. | |
| 13 | **Accessibility.** Icon-only buttons have `title` only, no `aria-label`; reorder is mouse-only; no keyboard alternative. | |
| 14 | **No empty state** on the tab, and no lightbox/preview on the edit page (links open the original in a new tab). | |
| 15 | **Whole-document `MutationObserver`** with `subtree: true` re-runs init on every Alpine toggle anywhere on the page. | |

### 1.3 Where a page's image shows up around the site

Every one of these calls `object-fit: cover` and lets the browser pick the centre. This is the "sometimes right, sometimes wrong" behaviour.

| Context | File | Box | Effective shape | File served today |
|---------|------|-----|-----------------|-------------------|
| Hero banner on `content#show` | `content/_hero_header.html.erb` | full width × `h-64 / md:h-80 / lg:h-96` | ~1.5:1 on phones → ~4:1 on desktop | **original upload** (e.g. 1.6 MB) / full Basil blob |
| Content cards (dashboard, lists, collections) | `content/display/_card.html.erb` | ~300 × `h-48` | ~3:2 | `medium` (300 px) |
| Card index | `content/display/tailwind_content_list/_card_index.html.erb` | `w-full` × `h-64` | ~4:3 to 1:1 | `small` (190×190 centre crop, **upscaled**) |
| Page sidebar preview | `content/tailwind_components/_content_context_sidenav.html.erb` | ~272 × `h-64` | ~1:1 | `medium` |
| Universe strip in sidebar | same file, line 46 | `w-full` × `h-24` | ~3:1 | `medium` |
| Square thumbs | `search/results`, `content/references`, `users/tabs/_content`, `shared/_share_to_stream_modal` | 48–80 px | 1:1 | `medium` / `thumb` |
| Circle avatar | `universes/hub.html.erb` | 128 px `rounded-full` | 1:1 | `medium` |
| Small wide | `timelines/index`, `display/_tailwind_foldered_index` | 96×64 – 128×80 | 3:2 | `hero` (800 px) |
| Social / Open Graph image | `content/show.html.erb` | platform crops to 1.91:1 | 1.91:1 | `medium` (300 px, far below the 1200 px platforms want) |
| Basil pages, page collections, stream, RSS | ~30 other call sites | mixed | mixed | `medium` |

Paperclip styles defined on `ImageUpload#src`: `thumb 100x100>`, `small 190x190#`, `square 280x280#` (unused), `medium 300x300>`, `large 600x600>`, `hero 800x800>`.

### 1.4 How the "cover" image gets chosen

`HasImageUploads` (`app/models/concerns/has_image_uploads.rb`):

- If an image is pinned, it wins everywhere (`pinned_image_upload`, `pinned_public_image`).
- Otherwise `random_image_including_private` calls **`.sample`**, so the banner and cards can change between page loads. `first_public_image` uses the first public image.
- Basil images are only considered after uploads.

So "pin" really means "cover image", and today the UI never says so.

---

## 2. Principles for the redesign

1. **One concept: the cover.** Rename pin → "Set as cover" in the UI. The cover is what shows on cards, banners, thumbnails and link previews. Selection is deterministic when no cover is set (first image by position), never random.
2. **The user frames the image, not CSS.** A per-image editor with a focal point plus an optional crop/zoom per display shape. The site renders from those choices; CSS `object-position` is only the fallback.
3. **Nothing reloads the page.** Upload, reorder, cover, notes, privacy, delete, crop: all in place, with clear saved/failed states.
4. **One card, one presenter, one renderer.** A `ContentImage` presenter hides the `ImageUpload` vs `BasilCommission` split from every view; a `content_image_tag(content, :card)` helper replaces ~40 hand-written `image_tag` calls.
5. **Serve the right size.** Grid uses `large`; banner uses a banner derivative with `srcset`; OG uses ≥1200 px; Basil uses ActiveStorage variants instead of originals.
6. **Keyboard and touch are first-class.** Reorder with buttons as well as drag; drag works on touch; every icon button has an accessible name.

---

## 3. Phased plan

### Phase 1 — Polish the gallery panel (quick wins, ~1–2 days)

Touches `content/edit/_gallery_panel.html.erb`, a new `content/edit/gallery/_card.html.erb`, a new `app/javascript/controllers/gallery_controller.js` (Stimulus is already set up), and `HasImageUploads`.

- **Unify the card.** One `_card` partial rendered for both sources through a `ContentImage` presenter (`app/presenters/content_image.rb`: `id`, `kind` (`upload`/`basil`), `url(style)`, `pinned?`, `notes`, `position`, `byte_size`, `width`, `height`, `privacy`, `update_path`, `delete_path`). Use `combine_and_sort_gallery_images` instead of the inline rebuild.
- **Cover state, done properly.** The card header row gets a "Cover" chip; the pin button becomes a labelled "Set as cover" / "Cover ✓" control that toggles optimistically and reconciles from the JSON response. Remove the floating "Pinned" badge that overlaps the textarea; keep the ring on the image area only. Add one sentence under the section heading: "Your cover image appears on cards, the page banner and link previews."
- **Drag handle.** `w-10 h-10 rounded-full flex items-center justify-center` (a real circle), top-centre of the image, visible at low opacity always on touch and on hover on desktop. Make the whole image area the sortable handle so the textarea and buttons still work. Delete the `max-width: 768px { display:none }` rule. Add "Move up / Move down" to a card `⋯` menu for keyboard and small screens. Show "Drag to reorder" as a persistent hint under the heading rather than only mid-drag.
- **Notes.** Autosize textarea; save on blur **only if changed**; show an inline "Saved" tick that fades; `Cmd/Ctrl+Enter` saves; no pop-in button. Keep the `js-image-notes` class so the unsaved-changes tracker in `edit.html.erb` keeps ignoring it.
- **Delete.** Inline two-step confirm on the card ("Delete this image? Delete / Keep"), fade out, update the "(n)" heading, the sidebar badge, and the bandwidth line from the JSON response (return `reclaimed_kb` and `remaining_kb` from `ImageUploadController#delete`).
- **Meta row.** Source chip (Uploaded / Basil), `W × H`, size, added date; privacy chip that toggles (public/private) via the existing `PATCH /image_uploads/:id` once `privacy` is permitted.
- **Images.** `src(:large)` with `loading="lazy"` and `aspect-video`; Basil cards use `image.variant(resize_to_limit: [800, 800])` and `disposition: :inline`.
- **JS.** Move the inline script into a Stimulus controller; one `request()` helper; initialise once on connect (the tab is server-rendered behind `x-show`, so no observer is needed); reuse the site toast if one exists in `enhanced_autosave.js`, otherwise keep a small shared `toast.js`.
- **Empty state** with "Upload images" and "Generate with Basil" CTAs.
- **Deterministic cover.** In `HasImageUploads`, replace `.sample` with "first by position" when nothing is pinned. (Behaviour change, see Decisions.)
- **Authorization parity.** Add `ImageUploadAuthorizer` / `BasilCommissionAuthorizer` in `app/authorizers/` that delegate to `content.updatable_by?(user)`, and use them in pin, update, delete and sort.

### Phase 2 — Uploads that don't reload the page (~2–3 days)

- Extract `ContentController#upload_files` into `ImageUploadService.upload(user:, content:, file:, privacy:)` (bandwidth check, charge/refund, create, return record or errors). Both the legacy form and the new endpoint call it.
- Implement `ImageUploadController#create` as JSON (`POST /image_uploads`, params: `content_type`, `content_id`, `src`, `privacy`). Response: the rendered `_card` HTML plus `remaining_kb`.
- **Drop zone** covering the whole gallery tab ("Drop images anywhere"), multi-file input, clipboard paste. Each file gets a queued row with thumbnail, size, and an XHR progress bar; on success the row becomes a card in the grid; on failure the row shows the reason (type, too large, out of bandwidth) with a retry.
- **Client-side checks** against `data-remaining-kb` before sending; live bandwidth meter.
- Optional "Shrink large images before uploading" toggle (canvas resize to 2500 px, JPEG 0.85), off by default, to save quota.
- Keep the old form inside `<noscript>` and delete the cocoon "Add another image" flow.

### Phase 3 — The image editor: focal point, crop and zoom per shape (~5–7 days)

#### 3.1 Shapes

Define presets once, in `app/models/image_presets.rb` (or an initializer), derived from the catalog in §1.3. Only build presets for shapes the site actually uses:

| Preset | Ratio | Output size | Used by |
|--------|-------|-------------|---------|
| `banner` | 3:1 | 1600×533 (+800×267 for `srcset`) | hero header, universe strip, timeline headers |
| `card` | 3:2 | 900×600 | content cards, small wide thumbs, Basil pages, OG/Twitter (1200×800 variant) |
| `square` | 1:1 | 600×600 | sidebar preview, square thumbs, circle avatars, card index |

Each preset has a `ratio`, `size`, a label, and a `preview` partial for the editor (see 3.3).

#### 3.2 Data

Migrations for both `image_uploads` and `basil_commissions`:

- `crops jsonb, default: {}` — `{ "banner": {x, y, w, h}, "card": {...}, "square": {...} }`, rectangles **normalised to the original image (0..1)** so they survive any re-encode.
- `focal_x float, focal_y float` (default `0.5, 0.5`) — the universal fallback used for any container shape.
- `alt_text string`.
- `width integer, height integer` — populated on upload (Paperclip `before_post_process` + MiniMagick geometry; ActiveStorage `image.analyze` metadata) and backfilled by a one-off job. Needed to validate crop ratios and to draw the editor without waiting for the image.

Model validation: each crop is inside `0..1`, and `(w × width) / (h × height)` matches the preset ratio within 1 %.

#### 3.3 Editor UI

Opens from a card's "Edit" button (or clicking the image) as a full-screen modal inside the gallery tab; deep link via `#gallery/upload-123` / `#gallery/basil-456` so it survives refresh and can be shared with a collaborator. A dedicated route can come later if needed.

Layout (desktop; stacks on mobile with the shape tabs across the top):

```
┌────────────────────────────────────────────────────────────────────────┐
│ Amelia · concept.jpg  1652 KB · 2048×1365 · Uploaded        [Cover ✓] ✕ │
├───────────────────────────────────────────┬────────────────────────────┤
│                                           │  Shape                     │
│   ┌ · · · · · · · · · · · · · · · · ┐     │  ◉ Banner 3:1   custom     │
│   ·                                 ·     │  ○ Card   3:2   auto       │
│   ·     image, pan by dragging      ·     │  ○ Square 1:1   auto       │
│   ·     crop box locked to ratio    ·     │                            │
│   ·     corners resize (= zoom)     ·     │  ┌─ live preview ────────┐ │
│   └ · · · · · · · · · · · · · · · · ┘     │  │ real hero chrome with │ │
│                                           │  │ page title pill       │ │
│   [−]──────●──────[+]  zoom   ⊹ grid      │  └───────────────────────┘ │
│   Reset · Use focal point · Copy to all   │                            │
│                                           │  Focal point  ◎ drag on img│
│                                           │  Caption / alt text        │
│                                           │  Privacy  ● Public ○ Private│
│                                           │  Download original · Delete│
├───────────────────────────────────────────┴────────────────────────────┤
│                                              Cancel      Save (⌘⏎)     │
└────────────────────────────────────────────────────────────────────────┘
```

- **Stage:** the original image (`src(:original)` / Basil blob served inline) with a dotted crop box locked to the selected preset's ratio. Drag inside the box to pan, drag corners to resize (zooming in and out), mouse wheel / pinch to zoom, rule-of-thirds grid toggle. A shape that has no custom crop shows the automatic crop (centred on the focal point) and is labelled "auto" until touched.
- **Focal point mode:** a single draggable dot on the image; sets `focal_x/y`; "Use focal point" recentres the current crop on it; "Copy to all" applies the same centre to the other shapes.
- **Live previews** are rendered in the real site chrome so the decision is obvious: a mini hero header with the title pill, a content card with the type badge, a square thumb next to a circle avatar. Previews update on every drag (CSS transform of a cloned `<img>`, no canvas, so cross-origin Basil blobs are fine).
- **Details:** caption/alt text (replaces the free-text "notes" as the primary field; notes stay as a secondary field), privacy toggle, cover toggle, file facts, download original, delete.
- **Keyboard:** arrows nudge the box 1 % (Shift = 5 %), `+`/`−` zoom, `1`/`2`/`3` switch shapes, `Esc` closes (with unsaved-changes guard), `Cmd/Ctrl+Enter` saves.
- **Library:** use **Cropper.js 1.6** (MIT, ~40 KB, touch, ratio lock, `getData()` in natural pixels) wrapped in an Alpine component; it already does the hard geometry and mobile gestures. Add via `yarn add cropperjs` and import from a small `gallery_editor` pack loaded only on edit pages. A hand-rolled pan/zoom is feasible but not worth the maintenance.

#### 3.4 Rendering the choices

Do this in two steps so the editor ships value immediately:

- **3a — Focal point via CSS (ships with the editor).** `content_image_tag` sets `style="object-position: X% Y%"` from `focal_x/y`. Works for every container on the site today, including shapes we don't have presets for. No image processing.
- **3b — Real derivatives per preset.** `ImageDerivativeService.generate(image, preset)`:
  - `ImageUpload` (Paperclip): add styles `banner`, `card`, `square` with a custom `Paperclip::Cropper` processor that prepends `-crop WxH+X+Y` from the stored rectangle (the classic Paperclip cropping pattern); `GenerateImageCropsJob` calls `src.reprocess!(:banner, :card, :square)` after a crop is saved.
  - `BasilCommission` (ActiveStorage): `image.variant(crop: [x, y, w, h], resize_to_fill: size).processed` in the same job.
  - Until the job finishes (or if it fails) the helper falls back to 3a on the closest existing style. Store a `crops_generated_at` timestamp to know which is which.
  - Keeping this behind one service means a later Paperclip → ActiveStorage migration (already a TODO in `ImageUpload`) changes one file.

#### 3.5 Endpoints

- Extend `PATCH /image_uploads/:id` and `PATCH /basil/commission/:id` to permit `crops`, `focal_x`, `focal_y`, `alt_text`, `privacy`, `notes`; validate; enqueue derivatives; respond with the updated presenter JSON (including fresh preset URLs so the card can refresh its thumbnail).
- Both go through the authorizers from Phase 1.

### Phase 4 — One renderer for every image on the site (~2–3 days, can be spread)

- `ContentImage` presenter gains `url(preset)`, `focal_css`, `alt`.
- `HasImageUploads` gains `cover_image` (a record, not a URL) and `cover_image_url(preset)`; existing helpers (`first_public_image`, `random_image_including_private`, …) delegate to it so nothing breaks while call sites migrate.
- `content_image_tag(content, preset, **html_options)` returns the right derivative, `srcset` for `banner`, `object-position` fallback, `alt`, `loading="lazy"`, and the type placeholder when there is no image.
- Migrate call sites by visibility: hero header → `display/_card` → `_card_index` → context sidenav → square thumbs → OG/Twitter tags (use the `card` preset at 1200×800) → the rest.
- Make the hero honour the banner crop exactly on desktop: give it a ratio-based height (`aspect-banner: '3 / 1'` in `tailwind.config.js`, capped with `max-h-96`) instead of three fixed heights.

### Phase 5 — Nice-to-haves (pick as time allows)

- Lightbox on `content#show` gallery with keyboard navigation, captions and alt text; serve `large` there instead of originals.
- Bulk select → delete / set privacy / make public.
- "Replace image" (swap the file, keep notes, crops, position, cover).
- Rotate 90° in the editor (requires rewriting the original; do after 3b).
- Reuse the same card partial on the Data Vault uploads page (`data/uploads.html.erb`).
- Move "Generate with Basil" into the empty state and the section header as a secondary CTA so the tab is shorter.

---

## 4. Testing

- **Models:** crop validation (bounds, ratio tolerance), `cover_image` selection (pinned > first by position > Basil > placeholder), privacy filtering for non-owners.
- **Services:** `ImageUploadService` bandwidth charge/refund, error messages; `ImageDerivativeService` produces the expected geometry for both storage backends (fixture images in `test/fixtures/files`).
- **Controllers:** `ImageUploadController#create` JSON happy path, over-quota, wrong type; `#update` permits crops/privacy/alt and rejects out-of-range rectangles; authorization parity for owner, universe contributor, stranger, logged-out across pin/update/delete/sort (extend `content_controller_pin_test.rb`, `gallery_images_controller_test.rb`, `image_upload_controller_test.rb`).
- **Helpers:** `content_image_tag` fallbacks (no image, no crop, derivative not yet generated).
- **System:** one `ApplicationSystemTestCase` covering open editor → change banner crop → save → hero renders the new derivative URL; one for drop-zone upload.
- **JS:** if any crop math lives outside Cropper.js, keep it in a pure module with a small unit test.

---

## 5. Decisions to make

1. **Deterministic cover when nothing is pinned** (first image by position) instead of random per render. Recommended: yes. It's a visible behaviour change for pages that rely on the "random" effect.
2. **Cropper.js vs. hand-rolled pan/zoom.** Recommended: Cropper.js.
3. **Crop derivatives on Paperclip now, or migrate `ImageUpload` to ActiveStorage first.** Recommended: ship crops behind `ImageDerivativeService` now; migrate later without touching the editor.
4. **One `content_images` table for uploads and Basil images.** Out of scope; the presenter hides the split. Revisit with the ActiveStorage migration.
5. **Editor as a modal + hash deep link vs. its own route.** Recommended: modal first; add a route if collaborators need a shareable URL.
6. **Notes vs. caption/alt text.** Recommended: introduce `alt_text` as the primary short field (shown in lightbox and used for `alt`), keep `notes` for longer private notes.

---

## 6. Suggested order

| Step | What ships | Effort |
|------|-----------|--------|
| 1 | Phase 1 polish (cover concept, circle handle, notes, delete, meta, `large` images, Stimulus controller, authorizers) | 1–2 days |
| 2 | Phase 2 uploads without reload | 2–3 days |
| 3 | Phase 3a editor with focal point + captions/privacy + live previews | 2–3 days |
| 4 | Phase 4 renderer migration for hero, cards, sidebar, thumbs, OG | 2–3 days |
| 5 | Phase 3b per-shape crop/zoom with generated derivatives | 3–4 days |
| 6 | Phase 5 extras | as needed |

Steps 1–2 are independent of the crop work and can go out as their own PRs. Step 4 before 3b means the site already renders from the focal point everywhere before real crops exist, so 3b only has to swap URLs.

---

## 7. Round two: polish and consolidation

Eight follow-ups agreed after Phases 1–4 shipped, in the order that keeps each step cheap for the next one. Estimates assume one person; the whole list is 6–8 days, so a cut line after step 5 fits a 4-day budget and leaves the sweeps (7 and 8) for a later PR.

| Step | Item | Effort |
|------|------|--------|
| 1 | Different cover per shape | 1 day |
| 2 | Social preview shape | 0.5 day |
| 3 | Smaller derivative files (WebP, srcset, one backfill pass) | 1 day |
| 4 | Show-page gallery and lightbox | 1 day |
| 5 | Mobile uploads (HEIC, camera, shrink before upload) | 0.5–1 day |
| 6 | Accessibility and dark-mode pass on the editor | 0.5–1 day |
| 7 | N+1 cleanup on list pages | 0.5–1 day |
| 8 | Retire the old image helpers and partials | 1–1.5 days |

### 7.1 Different cover per shape

**Why.** A portrait is right for the square thumbnail and wrong for the 3:1 banner. One cover for every shape forces a compromise.

**Model.** Store the choice on the image, not on the ~30 content tables: `cover_for json, default: []` on `image_uploads` and `basil_commissions` (declared with `attribute :cover_for, :json` like `crops`), holding preset keys such as `["banner"]`. The existing `pinned` flag stays the default for every shape. `HasImageUploads#cover_image(preset:)` resolves: image whose `cover_for` includes the preset → pinned image → current fallback (first / random). `ContentImage#cover_for` and `cover_for?(preset)` feed the JSON.

**Endpoint.** Extend `POST /toggle_image_pin` with an optional `preset` param. With a preset it toggles that shape only and clears the same preset from every other image of the page (the same "unpin others" pattern already used for `pinned`). Authorisation unchanged.

**UI.** The card's "Set as cover" button becomes a split button: main click = cover for everything; caret menu = "Banner only", "Card only", "Square only", "Link preview only". Chips on the image read "Cover", "Banner", "Thumbnail", "Card", "Preview". The editor header gets the same menu, and the editor's preview panel highlights which image is currently used for each shape ("Currently: this image" / "Currently: Amelia-2.jpg") so the choice is visible where the crop is made.

**Files.** Migration; `has_image_framing.rb` (or a small `HasCoverRoles` concern); `has_image_uploads.rb`; `content_controller.rb#toggle_image_pin`; `content_image.rb`; `_card.html.erb`; `_editor.html.erb`; `gallery_controller.js`; `image_editor_controller.js`; `content_image_helper.rb`.

**Tests.** Model resolution order (per-shape → pinned → fallback); controller toggle clears others per preset; helper renders the banner from image A and the square from image B.

### 7.2 Social preview shape

**Why.** Open Graph and Twitter crop to 1.91:1 at 1200×630; today they borrow the 3:2 card.

**Change.** Add `social: ratio [1.91, 1] → use [40, 21], size [1200, 630], label "Link preview"` to `ImagePresets`. Because the editor, the Paperclip styles, the Cropper processor, the validation and the backfill all iterate `ImagePresets`, the new shape appears everywhere with only: the tab icon size in `_editor.html.erb`, a fourth preview mock (a link card with title and "notebook.ai"), and `content_social_image_url` switching to `preset_url(:social)` with the card as fallback. Emit `og:image:width`/`height` and switch `twitter:card` from the deprecated `photo` to `summary_large_image` in `content/show.html.erb` and `content/references.html.erb`.

**Tests.** Preset present; helper prefers `/social/`; meta tags present on show.

### 7.3 Smaller derivative files

**Why.** Banners are the heaviest asset on the site; 48 px avatars are served from a 600 px square.

**Changes.**
- Shape styles (`banner`, `card`, `square`, `social`) and a new `xlarge 1600x1600>` (used by the lightbox and the editor instead of the original) get `format: :webp` and `convert_options: '-quality 82 -strip'`. Basil variants pass `format: :webp, saver: { quality: 82 }`.
- Add `banner_sm 750x250#` and `square_sm 200x200#`; `content_image_tag` emits `srcset`/`sizes` for the banner and picks `square_sm` when the rendered box is ≤ 96 px (a `size: :small` option on the helper), plus `width`/`height` attributes from the preset to stop layout shift and `decoding="async"`.
- Confirm S3 objects are written with a long `Cache-Control` (Paperclip `s3_headers`); the timestamp query string already busts caches on reprocess.
- Backfill: change `gallery:backfill_crops` to reprocess **all** styles once (the originals are downloaded anyway), so legacy `thumb`/`medium`/`large` also become WebP. Run off-peak; it is one pass over every original in S3.
- Production check before deploying: `convert -list format | grep -i webp` on the app image.

**Tests.** Derivative content type is `image/webp`; `srcset` present on banner; `square_sm` chosen for small boxes; Basil variant transformation includes the format.

### 7.4 Show-page gallery and lightbox

**Why.** `content/show/_gallery_content.html.erb` still serves originals through inline `onclick` handlers and a modal without navigation.

**Change.** Re-render the grid from `ContentImage.gallery_for(content, viewer:)` (privacy-aware, same order as the editor) with `url(:large)`, lazy loading, notes as a hover caption, and the cover chip. New Stimulus `lightbox_controller.js`: opens on click or Enter, previous/next by arrows, buttons and touch swipe, Escape closes, focus is trapped and returned, `aria-modal` and a live "3 of 8" counter. It shows `xlarge` (from 7.3) with the notes as caption, a download link, and for editors an "Edit framing" link to `edit#gallery/upload-<id>`. Neighbours are preloaded. Delete the global `openImageModal`/`closeImageModal` and the `.gallery-grid` CSS block in `_dynamic_content.html.erb`, moving it to `gallery.scss`.

**Tests.** Controller test that show renders `/large/` and no `/original/` in the grid; privacy filtering for a stranger.

### 7.5 Mobile uploads

**Why.** iPhones upload HEIC, and the local ImageMagick reads it (`convert -list format` lists HEIC and AVIF here; confirm on the production image).

**Changes.**
- Server: every Paperclip style already re-encodes (7.3 makes them WebP), so HEIC originals get browser-readable derivatives. The editor and lightbox load `xlarge`, never the original, so HEIC never has to render in a browser. `validates_attachment_content_type` already accepts `image/heic`.
- Client: `accept="image/*,.heic,.heif"`, a "Take a photo" button on touch devices (`capture="environment"` input), and the "Shrink large images before uploading" toggle: `createImageBitmap` → resize to 2500 px → JPEG 0.85, off by default, skipped for GIF/HEIC (canvas cannot decode HEIC outside Safari). Show the estimated saving next to the toggle ("about 4.2 MB → 900 KB").
- Queue rows and the drop-zone prompt tighten on narrow screens (single column, larger tap targets).

**Tests.** Service accepts a HEIC fixture (skipped when the host ImageMagick lacks HEIC); controller returns a card for it.

### 7.6 Accessibility and dark-mode pass on the editor

**Checklist.**
- Focus trap inside the modal, initial focus on the active shape tab, focus returned on close (partly done: return only).
- Tabs use `role="tablist"` with arrow-key navigation between shapes; `aria-selected` already set.
- Shape state changes ("Banner: custom") announced through a visually hidden `aria-live` region; the footer status already is.
- Privacy button `aria-label` reflects the current state instead of the static "Toggle image privacy".
- A "?" shortcut that opens a keyboard-help sheet listing the existing shortcuts.
- Cropper handles enlarged to 20 px on touch devices; the focal dot gets a visible focus ring and is reachable by Tab (arrow keys already move it).
- Toasts get `role="status"`; card fades respect `prefers-reduced-motion`.
- Dark mode: the site toggles a `dark` class from `localStorage.dark_mode_enabled`, so the Playwright harness can set it and screenshot every editor state. Check stage background vs. crop overlay, preview mock contrast, chip colours, range slider and select styling under `dark:`.

**Tests.** Extend the Playwright check with a dark-mode run; add an axe-core pass over the open editor (axe is loadable from `node_modules` in the harness) and fix what it reports.

### 7.7 N+1 cleanup on list pages

**Why.** `cover_image` loads `image_uploads` and `basil_commissions` per page unless they are preloaded. The content index builds its own `@random_image_including_private_pool_cache`, which the foldered index still reads, so those cards never got the focal point.

**Changes.**
- `ContentController#index`: replace the pool cache and `@saved_basil_commissions` with `includes(:image_uploads, basil_commissions: { image_attachment: :blob })` on `@content`; the two `_tailwind_foldered_index` branches use `content_image_tag(item, :card, include_private: true, pick: :random)`.
- Same `includes` on: dashboard content library, `users#content` tab, `main#recent_content`, search results, page collections, universes content list, Basil index.
- `ContentImage#url`/`preset_url` for Basil touch `image.blob`; with the attachment preloaded they are query-free. Memoise `variant_for` per instance.
- Verify with the Bullet output already shown in development, plus a request test that loads a character index with 20 characters and asserts the query count stays flat (`assert_queries`-style helper around `ActiveSupport::Notifications`).

### 7.8 Retire the old image helpers and partials

**Scope (from a grep of the tree).** About 50 remaining call sites still use `random_image_including_private`, `first_public_image`, `pinned_or_random_image_including_private`, `custom_thumbnail_url`, `custom_public_thumbnail_url` or `get_preview_image`: page collections (views, model and the RSS builder), the stream partials, the dashboard components, books, conversation pages, `universes/content_list`, `_image_card_header`, `_secondary_sidebar`, `_parallax_universe_header`, the content panels, plus `content_page.rb`, `page_collection.rb`, `users_controller.rb`, `main_controller.rb` and `conversation_controller.rb`.

**Steps.**
1. Migrate every view call site to `content_image_tag` (or `cover_image(...)&.url(...)` where a URL is needed, and `content_social_image_url` in the RSS builder, which needs absolute URLs).
2. Migrate the model/controller callers (`content_page.rb`, `page_collection.rb`, JSON in `users_controller.rb`) to `cover_image`.
3. Delete from `HasImageUploads`: `primary_image`, `extract_image_url`, `public_image_uploads`, `private_image_uploads` (which calls a non-existent `self.image`), `random_image_including_private`, `first_public_image`, `random_public_image`, `pinned_image_upload`, `pinned_public_image`, `pinned_or_random_image_including_private`, `custom_thumbnail_url`, `custom_public_thumbnail_url`. Keep `header_asset_for`.
4. Delete `ApplicationHelper#combine_and_sort_gallery_images` and `#get_preview_image` with their tests, the pool-cache code in `ContentController`, and the `instance_variable_set` cache clears in `toggle_image_pin`.
5. Delete the dead partials `content/form/gallery/_panel.html.erb`, `content/form/images/_gallery.html.erb`, `content/form/_panel.html.erb` if nothing renders it, `app/assets/javascripts/image_uploads.js`, and the `.aspect-w-16` rules in `timeline_viewer.scss` if no other view uses them. Keep `content/form/images/_upload*.html.erb` for the no-JS fallback.
6. Add a guard test that greps `app/` for the removed method names so they cannot creep back.

**Order of work.** 7.1 first because it changes the cover API that 7.7 and 7.8 migrate everything onto. 7.2 and 7.3 together, since they share one backfill pass. 7.4 and 7.5 both rely on `xlarge` from 7.3. 7.6 once the editor UI has settled. 7.7 and 7.8 last as one sweep with the query-count test as the safety net.

**Deploy notes for the round.** One migration (`cover_for`), one full reprocess pass over S3 originals (WebP plus the new styles), and a check that the production ImageMagick lists `WEBP` and `HEIC` formats.
