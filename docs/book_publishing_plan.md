# Book publishing plan: EPUB, print PDF, DOCX and covers

Goal: a writer can take a Book in Notebook.ai and come away with files they
can upload straight to KDP, IngramSpark, Draft2Digital, Apple Books and Kobo,
or send to an editor, agent or magazine. Nothing should need fixing in Word,
Vellum or Atticus first.

In scope:

1. Export the whole book as **EPUB 3**.
2. Export the whole book as a **print-ready PDF**, with a choice of trim
   sizes, an inner margin that defaults to the right size, embedded fonts,
   and chapters that can start on right-hand pages.
3. Export the whole book (and single stories) as **DOCX**, in standard
   manuscript format or as a formatted book.
4. **Front and back cover** uploads for books.
5. *Added:* **front and back matter and publishing metadata**.
6. *Added:* **DOCX import**.

The reasons for adding 5 and 6 are under
[Why these two additions](#why-these-two-additions).

---

## Where we are today

| Area | Today | Gap |
|---|---|---|
| `Book` (`app/models/book.rb`) | name, subtitle, description, blurb, status, privacy, universe, gallery images | No author or pen name, ISBN, language, publisher, copyright or series. No book-level settings for print or export. |
| `BookDocument` | `book_id`, `document_id`, `position` | Every entry is a "Chapter". There's nothing for parts, front matter or back matter, and nowhere to store a story's credit line or a title that differs from the document's. |
| `Document` body | HTML from Medium Editor (`p`, `h2`–`h4`, `b/i/u/s`, `blockquote`, lists, `a`, alignment); `[[Character-12]]` mention tokens | No scene break or page break element. Pasted-in Word markup stays in the HTML. The "H1" button actually inserts an `<h2>` (`document_editor_tailwind.js:24`). |
| Export | Each document has its own `plaintext` and `printable` (browser print) page. `ExportJob` is an empty stub. `ExportController` skips Documents and Books. | Nothing exports a whole book. |
| Covers | `HasImageUploads` gallery (Paperclip, with crops cut to each display shape and converted to WebP) | There's no front or back cover slot. The gallery's crops don't keep full print resolution. |
| Background jobs | Sidekiq has an `export` queue, but concurrency is **1** | A 60-second PDF render would hold up every other queue. |
| Deploy | Railway, `Dockerfile` based on `ruby:3.2.3-slim` | New system tools (WeasyPrint) can be added with `apt` or `pip`. |

---

## Architecture: one manuscript, several renderers

Every output format reads from one assembled, cleaned-up version of the book.
Format-specific code never reads `Document#body` directly.

```
Book ──► BookManuscript.build(book, viewer:, options:)
           │  orders sections (front matter → parts and chapters → back matter)
           │  runs every body through ManuscriptHtml.normalize
           │  numbers chapters, adds generated pages (title, copyright, contents…)
           ▼
        Manuscript (plain Ruby objects: Section, Metadata, Covers)
           │
   ┌───────┼──────────────┬───────────────────┬──────────────────┐
   ▼       ▼              ▼                   ▼                  ▼
EpubRenderer  PrintPdfRenderer  DocxRenderer(:manuscript)  DocxRenderer(:formatted)  PrintCoverRenderer
 (gepub)     (HTML+CSS → WeasyPrint)   (our own OOXML writer, rubyzip)              (WeasyPrint)
```

### `ManuscriptHtml.normalize` (Nokogiri + Sanitize)

All output formats rely on this step, so it needs the most tests.

- **Allowlist only:** `p, br, em, strong, u, s, blockquote, ul, ol, li, h2, h3, h4, hr`.
  `b`→`strong`, `i`→`em`. Bare `span`/`font`/`div` are unwrapped. Inline
  styles are removed, except that `text-align: center|right` becomes a class
  (writers centre epigraphs and sign-offs).
- **Mentions:** `[[Character-12]]` tokens and notebook.ai links become plain
  text, using the existing plaintext path in `ContentFormatterService`. Other
  links become text in print and DOCX, and stay links in EPUB.
- **Scene breaks:** a paragraph containing only `***`, `* * *`, `#`, `~`, `§`
  or similar, or an `<hr>`, becomes `<hr class="scene-break">`. Each renderer
  then draws its own version: an ornament or blank line in print and EPUB,
  a centred `#` in standard manuscript format.
- **Page breaks:** a new `<hr class="page-break">` that the editor can insert.
- **Headings:** a first heading that repeats the chapter title is dropped.
  The remaining in-chapter headings move down a level, beneath the chapter
  title.
- **Empty paragraphs:** runs of `<p><br></p>` are collapsed. Two or more
  blank paragraphs between text are reported in preflight as a "possible
  scene break" instead of being guessed at.
- **Typography (on by default, applied only to the exported copy, never the
  stored text):** curly quotes and apostrophes (handling `'90s` and `'til`),
  `--` → em dash, `...` → ellipsis, and a non-breaking space before a
  trailing `!?` in French. Uses the `smartypants` routine already in
  Redcarpet, or a small replacement.

### `BookManuscript`

Takes a book and a viewer, which must be someone allowed to update the book,
and returns an ordered list of `Section` objects:
`{kind, matter_type, title, label ("Chapter 3"), html, word_count, credit, epigraph, starts_recto}`.
It handles:

- **Chapter labels:** `title only` | `number only` | `number + title` |
  `"Chapter One"` spelled out. The default for a collection is title only.
- **Generated pages:** half title, title page, copyright page, contents,
  Also By and About the Author. See Feature 5.
- **Documents another viewer can't see:** password-protected documents are
  included when the owner exports. Anything the exporting user can't read is
  left out and listed in preflight.

### `BookExport` (new model) and `BookExportJob`

- **Columns:** `book_id`, `user_id`, `format` (`epub`, `pdf_interior`,
  `pdf_cover`, `docx_manuscript`, `docx_formatted`, `pdf_sample`), `options`
  (jsonb, a copy of the settings used), `status` (`queued`, `processing`,
  `complete`, `failed`), `book_layout_id` (required for the PDF formats and
  `docx_formatted`, empty otherwise), `page_count`, `warnings` (jsonb),
  `error`, `source_fingerprint`, and `has_one_attached :file`.
- **Reuse:** `source_fingerprint` is a digest of every section's
  `updated_at` plus the settings. Asking for the same export twice returns the
  stored file instead of rendering it again.
- **Retention:** keep the latest 3 per book, format and layout. A daily job
  purges the rest.
- **Job:** `BookExportJob` runs on the `export` queue. External processes run
  through `Open3` in their own process group, with a hard timeout (5 minutes)
  that kills the whole group.
- **Sidekiq:** run a separate worker process for the `export` queue
  (`Procfile`: `export: … sidekiq -q export -c 1`). Its memory limit can then
  be sized for WeasyPrint, and it can't hold up `paypal` or `analysis`.
- **Routes:**
  - `GET /books/:book_id/publish` – the Publish page.
  - `POST /books/:book_id/exports` – start an export.
  - `GET /books/:book_id/exports/:id` – status as JSON, or a redirect to a
    signed blob URL with `Content-Disposition: attachment`.
  - `RouteSmokeTest#param_value` and `test/smoke/smoke_data.rb` need entries
    for `book_id` and the export `id` (see `docs/release_safety.md`).
- **Access: the book owner only.** Not `updatable_by?`, which also lets
  universe contributors in. Add `BookAuthorizer#exportable_by?(user)` =
  `user && resource.user_id == user.id`, and check it on the Publish page, on
  create, and on every download. Contributors don't see the Publish tab.
- **Premium (decided):**

  | Free | Premium |
  |---|---|
  | `epub`, `docx_manuscript` (whole book and single story) | `pdf_interior`, `pdf_sample`, `pdf_cover`, `docx_formatted` |

  - Kept as one constant, `BookExport::PREMIUM_FORMATS`, checked with
    `user.on_premium_plan?` when an export is **created** (the same check
    document analysis uses).
  - On the Publish page, free users see the Premium formats with a lock and an
    upgrade link instead of a disabled button with no explanation. They can
    still set up print layouts and run preflight, so the upgrade is the only
    step left.
  - Files made while on Premium stay downloadable after a downgrade until the
    normal purge removes them.
- **Layouts:** print and formatted-DOCX exports record which `BookLayout` they
  were made from (`book_layout_id`, see Feature 2).

### Preflight

Run before every export and shown on the Publish page. It's cheap: it uses
`BookManuscript` and never renders a file.

- **Blocking:** an empty book; a missing title or author name; for print,
  fewer than 24 pages (KDP's paperback minimum).
- **Warnings:**
  - TKs left in the text (reuse the pattern from
    `document_tk_markers.js` as a Ruby constant).
  - Empty chapters, or documents the exporting user can't read.
  - Possible scene breaks made of blank lines.
  - Cover too small for the format or trim size; an ISBN that fails its
    checksum; the same ISBN used for ebook and print.
  - A missing copyright year, or no contents page in a book with more than
    one chapter.

---

## Feature 5 (added): front and back matter, and publishing metadata

Build this first. It also covers the EPUB's required metadata, so every
export depends on it.

### Metadata on `books`

| Column | Notes |
|---|---|
| `pen_name` | Falls back to `user.display_name`. Used for the byline, running heads and EPUB `dc:creator`. |
| `language` | BCP 47, default `en`. Required by EPUB; also sets hyphenation rules. |
| `isbn_ebook`, `isbn_print` | Optional; ISBN-13 checksum validated. Each format needs its own ISBN. |
| `publisher` (imprint) | Shown on the title and copyright pages. |
| `publication_year`, `edition` | Copyright page. |
| `copyright_holder` | Defaults to the pen name. |
| `rights_statement` | Defaults to "All rights reserved." Optionally a Creative Commons licence. |
| `fiction_disclaimer` | Boolean, on by default for fiction: the standard "work of fiction" paragraph. |
| `series_name`, `series_position` | Title page, EPUB `belongs-to-collection`. |
| `contributors` | jsonb `[{role: editor|cover_designer|illustrator|translator, name}]`. |
| `keywords`, `bisac_codes` | Not used in the files themselves; shown on a "store listing" panel ready to copy into KDP or Ingram, alongside the blurb. |
| `epub_identifier` | A UUID generated when the book is created and never changed, so stores see a re-upload as the same book. Used when there's no ebook ISBN. |
| `matter_settings` | jsonb: which generated pages to include, chapter label style, About the Author / Also By overrides. These describe the book's content, so they apply to every format and every print layout. Print settings live on `BookLayout` (see Feature 2). |

### Section kinds on `book_documents`

- `kind`: `body` (default) | `part` | `front_matter` | `back_matter`.
- `matter_type`: one of `dedication`, `epigraph`, `foreword`, `preface`,
  `introduction`, `prologue`, `epilogue`, `afterword`, `author_note`,
  `acknowledgments`, `credits`, `glossary` or `custom`. Each one is written in
  an ordinary Document.
- `display_title`: the title shown in the book when it should differ from the
  document's title.
- `credit` (text): "First published in *Clarkesworld*, 2024." Shown under the
  story title, and collected on an auto-generated Credits page in back matter
  if the writer prefers.
- `part` rows have no document (`document_id` becomes nullable only for
  `kind: part`), a `title` ("Part One: The Drowned Year"), and an optional
  epigraph.
- **Generated pages** don't need a Document. They're toggles in
  `matter_settings`, placed in the standard order:
  - Front matter: half title (right-hand page) → Also By (left) → title page
    (right) → copyright (left) → dedication (right) → epigraph → contents
    (right) → foreword / preface / introduction.
  - Body: page 1 is a right-hand page.
  - Back matter: afterword → acknowledgments → credits → About the Author →
    Also By.
  - **About the Author** defaults to `user.bio`, with an override field.
    **Also By** defaults to the user's other books with status `published`,
    with an override field.

### UI

- A **Publish** tab on `books/edit`, alongside the current info, chapters and
  photos tabs, with sub-panels for Details (metadata), Front & back matter,
  Layout (one tab per print layout), Covers and Export. Only the owner sees
  this tab.
- The chapter list on the edit page shows Front matter, Body and Back matter
  as drag targets, with "Add part" and "Add dedication / epigraph / …"
  buttons. The latter create a document with the right `matter_type`.
- The public `books/show` table of contents says "Contents", and labels
  entries by kind instead of calling everything a "Chapter".

---

## Feature 4: front and back cover uploads

### Storage

Use ActiveStorage, in line with the planned move off Paperclip:

```ruby
# on Book: the artwork is the same whichever layout is printed
has_one_attached :front_cover
has_one_attached :back_cover

# on BookLayout: a finished wraparound PDF from a cover designer only fits one
# trim size and page count, so it belongs to that layout
has_one_attached :print_cover_wrap
```

- **Originals untouched:** gallery uploads are cropped and converted to WebP,
  which isn't good enough for print. Display versions come from ActiveStorage
  variants (`image_processing` is already in the Gemfile).
- **Hard validation** (`active_storage_validations`, already in the Gemfile):
  JPEG or PNG (plus PDF for the wrap), at most 50 MB.
- **Size checks are warnings, not errors**, because the right size depends on
  the format and trim size:
  - Ebook front cover: 1600 × 2560 px is ideal (1:1.6), 1000 px minimum on the
    short side.
  - Print front or back: (trim + 0.125″ bleed on the outer edges) × 300 DPI.
    For 6×9 that's at least 1838 × 2775 px. Checked against **each** layout's
    trim size, so a cover that's fine for 5.5×8.5 but too small for 6×9 gets
    a warning on the 6×9 layout only.
  - CMYK JPEGs are accepted but flagged for ebook use.
- **Display:** the book card and `books/show` use `front_cover` when it's set,
  and fall back to the gallery's `cover_image` otherwise. Do this in
  `ContentImageHelper` so all existing views pick it up.
- **Privacy:** covers follow the book's privacy, the same way
  `ContentImageAuthorization` handles gallery images.

### Print cover generator (stretch, but this is where separate front and back uploads pay off)

KDP and IngramSpark want a single wraparound PDF. `PrintCoverRenderer` builds
one **for each layout** (its trim size, paper and page count set the
dimensions) from the book's front cover, back cover and a generated spine:

- **Page size:** width = bleed + back + spine + front + bleed; height = trim +
  2 × bleed. Bleed is 0.125″.
- **Spine width** = the layout's latest interior page count × the printer's
  paper factor. If the interior hasn't been rendered since the text or layout
  changed, render it first, because the page count has to be real. KDP:
  white 0.002252″ per page, cream 0.0025″ per page. IngramSpark uses its own
  factors. Store these per printer and paper type in a constant, with a
  comment saying where the numbers came from.
- **Spine text:** title and author, only above the printer's minimum page
  count (KDP: more than 79 pages). Background colour taken from a colour
  picker, or sampled from the edge of the front cover.
- **Optional:** blurb text printed on a plain back cover when no back image
  is uploaded.
- **Guides:** a barcode keep-out area (about 2″ × 1.2″, lower right of the
  back) and safe-area guides appear in the **preview only**, never in the
  final PDF.
- If `print_cover_wrap` is uploaded, use it as-is and only check its page
  size against the computed one.

---

## Feature 1: EPUB 3 export

Ship this first among the exports. It needs no new system packages and tests
the whole manuscript pipeline.

### Library

Use **`gepub`**, a maintained pure-Ruby EPUB 3 writer that sits on `rubyzip`
(already in the lockfile). Each section becomes its own XHTML file.

### What "industry standard" means here

- **Packaging:** EPUB 3.3 with a valid `mimetype` entry (stored first,
  uncompressed) and `META-INF/container.xml`.
- **Metadata:** `dc:identifier` (`urn:isbn:` or `urn:uuid:` +
  `epub_identifier`), `dc:title`, `dc:creator` (pen name, with `file-as`),
  `dc:language`, `dc:publisher`, `dc:date`, `dcterms:modified`, `dc:rights`,
  and series as `belongs-to-collection`.
- **Navigation:**
  - `nav.xhtml` with a `toc` covering parts and chapters.
  - `landmarks`: cover, contents, and where the body starts. Kindle uses this
    to decide where the book opens.
  - A `toc.ncx` fallback for older readers.
- **Cover:** `front_cover` with `properties="cover-image"`. A separate cover
  page (`cover.xhtml`) is a toggle, on by default; KDP adds its own, other
  stores show the embedded one.
- **Accessibility metadata.** This matters now that the European
  Accessibility Act applies to ebooks sold in the EU:
  - `schema:accessMode`, `accessModeSufficient`, `accessibilityFeature`
    (`structuralNavigation`, `tableOfContents`, `readingOrder`),
    `accessibilityHazard none`, `accessibilitySummary`, and `dcterms:conformsTo`
    EPUB Accessibility 1.1 / WCAG 2.x AA.
  - Use semantic markup to back those claims: `epub:type` on sections
    (`frontmatter`, `bodymatter`, `chapter`, `part`, `dedication`, `epigraph`,
    `copyright-page`, `toc`, `backmatter`), `lang` on `<html>`, and
    `role="doc-…"` attributes.
- **Stylesheet that leaves readers in control:**
  - Sizes in `em`; no fixed font, colour or line spacing on body text.
  - `text-indent: 1.5em` with the first paragraph flush; `hyphens: auto`;
    widows and orphans set to 2.
  - Scene breaks as a centred ornament with `aria-label="scene break"`.
  - Fonts are optional: embedding the chosen OFL font is a toggle, off by
    default.
- **No** JavaScript, remote resources or notebook.ai links.

### Checks

- **CI:** run **EPUBCheck** (the Java jar, cached in the workflow) on a sample
  book and fail on any error. The sample covers parts, front matter, scene
  breaks, mentions and a cover.
- **Optional:** DAISY Ace for the accessibility report.
- **Manual:** before release, check the output in Kindle Previewer, Apple
  Books and Thorium.

---

## Feature 2: print-ready PDF

### Rendering engine

Recommendation: **WeasyPrint**, fed HTML and CSS generated from the
manuscript.

- **Why WeasyPrint:** it supports CSS paged media natively: `@page`
  `:left`/`:right`/`:first`/`:blank`, named pages, margin boxes for running
  heads and page numbers, `string-set`, `target-counter()` for page numbers
  in the contents, `break-before: right`, widows and orphans, and real
  hyphenation through pyphen. It embeds font subsets, and it's deterministic
  with no JavaScript involved.
- **Rejected: headless Chromium + Paged.js.** About 400 MB more in the image,
  much more memory per render, recto breaks that depend on a JavaScript
  polyfill, and hyphenation that isn't reliable on Linux.
- **Rejected: Prince.** The best quality, but a paid server licence.
- **Rejected: LaTeX or Typst.** Excellent typesetting, but we'd have to write
  an HTML-to-LaTeX/Typst conversion and maintain two styling systems.
- **Install:** `pip install weasyprint==<pinned>` into a virtualenv in the
  `Dockerfile`, plus `libpango-1.0-0`, `libpangoft2-1.0-0` and `fonts` in
  `apt`. The CI workflow installs the same.
- **Cost:** roughly 20–60 s and 300–600 MB of memory for a 300-page novel,
  which is why export gets its own worker.

### Print layouts (`BookLayout`, up to 2 per book)

A book can have **two saved print layouts** (for example a 5.5×8.5 paperback
and a 6×9 hardcover or large print). Each one is exported, previewed and
checked on its own. Two is a limit, not a design assumption: everything is
built as a normal `has_many`, so allowing more later means changing one
constant.

```ruby
class BookLayout < ApplicationRecord
  MAX_PER_BOOK = 2

  belongs_to :book
  acts_as_list scope: :book_id          # the first layout is the default
  has_one_attached :print_cover_wrap    # see Feature 4
  has_many :book_exports, dependent: :nullify

  # name ("Paperback"), position, settings (jsonb), timestamps
  validate :within_limit, on: :create
end
```

- **`settings` jsonb:** read through typed accessors that fill in defaults
  (`store_accessor`, or a small `BookLayout::Settings` value object), so
  adding a setting later needs no migration. Unknown keys are dropped and
  values are checked against the options below.
- **Creating them:** a book has no layouts until the writer opens the Layout
  panel. The first is then created automatically as "Paperback" with every
  default. **"Add a second layout"** copies the first (named "Hardcover";
  rename freely), so the writer changes only what differs, usually trim size.
  Once 2 exist the button is gone; deleting one brings it back.
- **Deleting:** a layout can be deleted, but not the last one if it has
  exports. Exports keep a copy of their settings in `options`, so old files
  still describe themselves correctly.
- **Choosing a layout:** the Publish page shows the layouts as two tabs. Each
  print export button belongs to a tab, so there's never a separate "which
  layout?" question. Formatted DOCX uses the default (first) layout's trim
  size and margins, with a small selector only when there are two.

**Settings.** The four **basic** settings are always visible. The rest sit
under one collapsed "**Advanced**" section, and the defaults are good enough
that most writers never open it.

| | Setting | Options / default |
|---|---|---|
| Basic | Trim size | 5×8, 5.06×7.81, 5.25×8, **5.5×8.5**, 6×9, 6.14×9.21, 7×10, 8.5×11, 4.25×6.87 (mass market, IngramSpark), A5 (148×210 mm), B-format (129×198 mm). No custom sizes in v1. |
| Basic | Body font | Three bundled SIL OFL fonts to start: **EB Garamond**, Crimson Pro, Source Serif 4. Stored in `vendor/fonts` and **never fetched at render time**. More can be added later as one font file plus one list entry. |
| Basic | Font size | 10–13 pt, default 11 pt. |
| Basic | Chapters start on right-hand page | Toggle, default on. `break-before: right`, which inserts a blank left page when needed. |
| Advanced | Paper | white / **cream**. Only affects spine width. |
| Advanced | Line spacing | 1.2–1.6, default 1.35. |
| Advanced | Margins | **Inner: Auto** (default) or a set value; outer, top and bottom have defaults per trim size. |
| Advanced | Running heads | Left page: author. Right page: book title, or **story title** (better for collections, and the default when every body section is a separate story). Or none. Removed on chapter openings and blank pages (`@page :blank`). |
| Advanced | Page numbers | **Bottom centre** / bottom outside / top outside. |
| Advanced | Scene break | **Ornament (❦)** or blank line. If it lands at the top or bottom of a page, it's always drawn as an ornament (a blank line would be invisible there). |
| Advanced | Text | **Justified with hyphenation** or ragged right. |

Fixed in v1 (not settings): chapter titles start about ⅓ of the way down the
page, the first line of each chapter is in small caps with no indent, front
matter pages are unnumbered, and the body starts at page 1. Drop caps and
roman-numeral front matter can be added later as Advanced options.

### Inner margin "Auto" (answering the "(?)" in the request)

The inner margin has to grow with page count, because a thicker book curves
more into the binding. Printers set minimums. KDP: 24–150 pages 0.375″,
151–300 0.5″, 301–500 0.625″, 501–700 0.75″, 701–828 0.875″, with outer
margins at least 0.25″. Those minimums look cramped, so "Auto" uses
**the printer minimum + 0.25″**, with a floor of 0.625″.

Page count depends on the margin, so the renderer works it out in passes:

1. Render with the margin for an estimated page count (words ÷ the
   words-per-page figure for this trim size and font).
2. Count the pages. If the count lands in a different page-count band, render
   again with that band's margin. One extra pass is almost always enough;
   stop after 3.

A manually set margin is allowed, with a warning if it's below the printer
minimum for the final page count.

### Output checks (KDP and IngramSpark both require these)

- Page size equals the trim size exactly. No bleed for text-only interiors,
  no crop marks, single pages rather than spreads.
- All fonts embedded (checked in tests).
- Even page count: pad with blank pages at the end.
- Grayscale-safe (no colour in the default theme).
- Contents page numbers filled in with `target-counter`.
- PDF/X: KDP accepts a standard PDF with embedded fonts. IngramSpark prefers
  PDF/X-1a. **Not in this round:** add a PDF/X variant later, either through WeasyPrint if the
  pinned version supports one, or by post-processing with Ghostscript.

### Preview

"Render sample" builds a `pdf_sample` export: the front matter and the first
two chapters, under 10 seconds. The Publish page shows it in an
`<iframe>` / `<object>`. This shows exactly what the printer will get, without
running a second, browser-based layout engine that might paginate
differently.

---

## Feature 3: DOCX export (standard manuscript format and formatted book)

### Library

Write **our own small OOXML writer** (`app/services/docx/…`, on `rubyzip` +
Nokogiri builders) instead of a gem or Pandoc.

- **Why:** the input is limited to the normalized subset above, so the writer
  is a few hundred lines. Standard manuscript format needs exact control that
  generic converters handle badly: a different header on page 1, PAGE fields
  in the header, page and section breaks, keeping headings with the next
  line, and named styles.
- **Rejected:** `caracal` is unmaintained, and Pandoc is a large binary where
  we'd still have to edit the reference document per export.
- **Package parts:** `[Content_Types].xml`, `_rels/.rels`,
  `word/document.xml`, `styles.xml`, `settings.xml`, `numbering.xml` (lists),
  `header*.xml`/`footer*.xml`, `docProps/core.xml` (title, author),
  `docProps/app.xml`.
- **Real Word styles, so editors, Vellum, Atticus and Draft2Digital read the
  structure correctly:** `Normal`, `Body Text` (first-line indent),
  `First Paragraph` (no indent), `Heading 1` (chapter, page break before),
  `Heading 2/3`, `Title`, `Subtitle`, `Author`, `Scene Break`, `Block Text`
  (quotes), `Epigraph`, `Credit`.
- **Spellcheck:** language set from `book.language`, so Word checks spelling
  in the right language.

### Mode A: standard manuscript format (Shunn's modern format)

- **Page:** US Letter by default (A4 option), 1″ margins, 12 pt Times New
  Roman (Courier New option), double-spaced, 0.5″ first-line indent,
  left-aligned with ragged right, no extra space between paragraphs.
- **Page 1:**
  - Single-spaced contact block at top left: legal name, address, phone,
    email, optional agent.
  - "about N words" at top right, rounded as Shunn recommends (to the nearest
    100 for short fiction; novels are rounded more coarsely).
  - Title centred about halfway down the page, "by *Pen Name*" beneath it,
    then the text.
- **Pages 2 onwards:** right-aligned header `Surname / Short Title / N`, using
  Word's "different first page" setting.
- **Scene breaks:** a centred `#`. **End:** a centred `END` (configurable).
- **Italics** stay italic (the modern guidance); an option switches to
  underline for older markets.
- **Whole-book manuscript** (novel format): a title page with contact details
  and word count, then each chapter (or story) on a new page about ⅓ of the
  way down.
- **Single-story export:** also available from the document page and the
  document navbar, next to the current Plain text / Printable links. Short
  story writers submit to magazines one story at a time, so this is cheap to
  add and very useful.
- **Contact details:** new **private** fields on `User` (legal name, mailing
  address, phone, submission email, agent), with a "Manuscript contact info"
  section in account settings. Never shown publicly; asked for inline the
  first time someone exports.

### Mode B: formatted book DOCX

The same structure as the print PDF: front matter, Heading 1 chapters, page
breaks, page size and margins taken from a print layout (the default layout
unless the writer picks the other), and fonts named (not embedded). Premium
only. This is the file for an editor's tracked-changes pass, for
Draft2Digital, or for importing into Vellum or Atticus.

### Checks

- Unzip and run XPath assertions in tests.
- In CI, open the file with LibreOffice headless (`soffice --convert-to pdf`)
  to catch any package Word would refuse to open.
- Manual check in Word and Google Docs before release.

---

## Feature 6 (added): DOCX import

- **Upload:** `.docx` on `books/new` ("Import a manuscript") or into an
  existing book.
- **Reading:** `Docx::Reader` reads `word/document.xml` with Nokogiri,
  mirroring the writer.
  - Kept: paragraphs, bold/italic/underline/strike runs, headings (by style
    name or outline level), lists, block quotes, page breaks, and scene-break
    paragraphs.
  - Tracked changes: insertions accepted, deletions dropped. Comments, fields
    and direct formatting (fonts, colours, sizes) are dropped.
- **Splitting into chapters:** on `Heading 1`, or failing that on page breaks,
  or failing that on lines matching `^(Chapter|Part)\b` / numerals.
- **Review step:** the writer sees the proposed split (chapter titles and word
  counts), can merge or split chapters, and marks which ones are front matter,
  back matter or parts. Then it creates the Documents and `BookDocument`s.
  The import runs as a job, because big manuscripts are slow.
- **Round-trip test:** export with our writer, import the result, and expect
  the same normalized manuscript.
- **Later:** Markdown, ODT, and Google Docs through its "Download as .docx".

---

## Editor changes these features need

- **Scene break** button: inserts `<hr class="scene-break">`, drawn as a
  centred ❦ in the editor and on reading pages.
- **Page break** button (rarely needed, but writers expect it).
- Rename the heading buttons so the labels match what they insert.
- Clean up pasted Word and Google Docs markup (run the normalizer's allowlist
  on paste), so imported and pasted text doesn't bring junk styles with it.

---

## Infrastructure checklist

- **Dockerfile:** WeasyPrint (pinned, in a virtualenv) and its Pango/fontconfig
  libraries; `vendor/fonts` (OFL fonts, with their licence files).
- **Procfile:** separate `export` worker. Set its memory limit on Railway.
- **`tests.yml`:** WeasyPrint, Java (for EPUBCheck), and LibreOffice for the
  DOCX check (or run that job only on changes under `app/services/docx`).
- **Storage:** ActiveStorage on S3 (`:amazon`), already set up. Downloads use
  signed, expiring URLs.
- **Retired code:** if `books/show` "Chapter" helpers or the printable-view
  links are renamed, add the old names to `RetiredCodeTest::RETIRED`.

## Testing strategy

| Layer | How |
|---|---|
| Normalizer | Table-driven unit tests: Medium Editor HTML, HTML pasted from Word and Google Docs, mention tokens, every scene-break variant, smart-quote edge cases (`'90s`, nested quotes). |
| Manuscript | Section order for every combination of front/back matter toggles, parts, chapter numbering styles, and locked or unreadable documents. |
| EPUB | EPUBCheck must report zero errors on the sample books (CI). Assertions on OPF metadata and nav. |
| PDF | `pdf-reader` gem: page size equals trim; even page count; every font has an embedded font file; with recto starts on, each chapter title's page number is odd; contents page numbers match. |
| DOCX | XPath assertions on styles, header on pages 2+, `titlePg`; LibreOffice conversion succeeds. |
| Import | Fixture DOCX files from Word, Google Docs and Scrivener; round trip through our own writer. |
| Requests and access | Only the owner can open the Publish page or create or download exports; universe contributors and other users get a redirect, not a 500. Free users can create `epub` and `docx_manuscript` but are refused each `PREMIUM_FORMATS` entry. Smoke tests cover the new GET routes. |
| Layouts | A third layout can't be created; "Add a second layout" copies the first; deleting a layout leaves its exports readable; two layouts with different trim sizes give different page counts, spine widths and cover-size warnings. |

---

## Order of work

| # | Milestone | Size | Depends on |
|---|---|---|---|
| M1 | Metadata and section kinds (Feature 5 data + UI), `ManuscriptHtml`, `BookManuscript`, preflight, scene/page break buttons | L | — |
| M2 | `BookExport` model, job, Publish page shell (owner only, Premium locks), separate export worker | M | M1 |
| M3 | **EPUB 3** + EPUBCheck in CI | M | M2 |
| M4 | **Cover uploads** + checks + display fallback | M | — (can run alongside M1–M3) |
| M5 | **DOCX writer**: standard manuscript format (book + single story) and formatted book; private contact fields | M–L | M2 |
| M6 | **Print PDF**: WeasyPrint in Docker/CI, `BookLayout` (up to 2 per book; basic and advanced settings), 3 fonts, Auto margin passes, sample preview | L | M2 |
| M7 | **Print cover generator** for each layout (spine calculation, wraparound PDF) | M | M4, M6 |
| M8 | **DOCX import** with the chapter-split review step | M–L | M1, M5 |
| Later | PDF/X variant for IngramSpark; per-printer spine factors | S–M | M6, M7 |

M8 can move ahead of M6 if attracting writers who already have a manuscript
matters more than print.

## Why these two additions

1. **Front and back matter and publishing metadata.** Every book needs it,
   whatever kind of book it is. Without a title page, copyright page, contents,
   author name, language and identifier, none of the four requested exports
   is ready to upload. EPUB needs some of these fields just to pass
   validation. It's mostly data and simple UI, and every format reuses it.
2. **DOCX import.** Most writers who are ready to publish have their book in
   Word, Google Docs or a Scrivener export, not in Notebook.ai. Without import,
   the export pipeline only helps books written here from scratch. With it,
   anyone can bring a finished manuscript and leave with store-ready files.
   Much of the work is shared with the DOCX writer.

Runners-up: comments and tracked changes for editors and beta readers;
continuous whole-book reading in the browser; book-wide find & replace and
name-consistency checks.

## Decisions

- **Premium:** EPUB and manuscript DOCX are free. Print PDF (interior and
  sample), the print cover and formatted DOCX are Premium. See
  `BookExport::PREMIUM_FORMATS` under the `BookExport` section.
- **Who can export:** the book owner only (`BookAuthorizer#exportable_by?`).
  Universe contributors can edit a book but can't export it.
- **Print layouts:** up to **2 per book**, built as a normal `has_many` with
  a `MAX_PER_BOOK` constant so the limit can rise later. Each layout has four
  basic settings, with everything else under one collapsed Advanced section.
- **Fonts:** start with 3 bundled OFL fonts (EB Garamond, Crimson Pro,
  Source Serif 4), in keeping with "don't overwhelm with options".
- **PDF/X:** later. KDP doesn't need it; IngramSpark accepts standard PDFs
  with embedded fonts but prefers PDF/X-1a.

*Printer figures (KDP margins, spine factors, cover pixel sizes, page-count
limits) were correct at the time of writing. Check them against the current
KDP and IngramSpark guides when implementing, and keep them in one constants
file with source links.*
