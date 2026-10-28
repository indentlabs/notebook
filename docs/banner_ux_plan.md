# Page banners: review and plan

Follow-up to `docs/gallery_ux_plan.md`. This started from a report that banner images on `content#show` no longer fill the width of the page on desktop, and leave a dark strip on the right.

## 1. What was wrong

The framing work (8c6c5d5, 2026-09-02) gave the hero a 3:1 shape on tablet and up, with a height cap:

```
md:h-auto md:aspect-banner md:max-h-96
```

When a box has `aspect-ratio` and an automatic width, CSS sends the `max-height` cap back through the ratio and shrinks the width to match. So once the content column is wider than 1152 px (384 px × 3), the box stops at 1152 px wide and the rest of the row is empty `bg-gray-900`. In Chromium, at a 1920 px viewport the box renders 1152×384 without `width: 100%` and 1904×384 with it.

**Fixed:** `content/_hero_header.html.erb` now adds `w-full`. The bug only affected screens wider than about 1400 px with the sidebar open, which is why it went unnoticed. It wasn't related to the image itself or to Basil, and every upload is affected the same way.

No other banner uses this pattern. The universe hubs and table of contents use fixed heights, and so does `books/show`.

## 2. Should we stretch images to fill?

No. Every banner already uses `object-fit: cover`, which scales the image to fill the box without distorting it, then trims whatever overflows. Stretching (`object-fill`) would squash faces and is never what writers want. Cover is already the default for all uploads and generated images.

What we *should* fix is the part that cover trims on wide screens:

| Viewport (sidebar open) | Hero box | Shape | Share of the 3:1 banner crop that's visible |
|---|---|---|---|
| 768–1150 px | full width × width/3 | 3:1 | 100% |
| 1440 px | ~1215 × 384 | ~3.2:1 | ~95% of the height |
| 1920 px | ~1690 × 384 | ~4.4:1 | ~68% of the height |
| 2560 px | ~2330 × 384 | ~6:1 | ~49% of the height |

So on a big monitor, the writer's carefully framed 3:1 banner loses its top and bottom. Cover centres the image, which ignores the focal point they set, and the 1500 px derivative is upscaled.

## 3. Plan

Ordered by value for effort. Steps 1–3 are the core and take about a day together.

### Step 1: Keep the focal point in view on wide screens (0.5 day)

When `content_image_tag` serves a cropped banner derivative, set `object-position` from the focal point's position *inside the banner crop* rather than leaving it centred. For crop rect `{x, y, w, h}` and focal point `(fx, fy)`, the vertical position is `(fy - y) / h`, clamped to 0–1, and the horizontal one works the same way. Add `HasImageFraming#object_position_within(preset)` and use it in the helper's derivative branch. The fallback branch already uses `object_position_css`.

### Step 2: Sharper banners on large and retina screens (0.5 day + backfill)

Raise the banner preset to 2400×800 (keeping 750×250 small, adding 1500×500 as a middle srcset entry). The srcset already exists, so phones keep getting small files. Run the `gallery:backfill_*` task afterwards. Skip upscaling: when the source is narrower than 2400 px, cap the derivative at the source width. That needs a check in the Cropper processor.

### Step 3: Show writers what wide screens cut (0.5 day)

In the image editor's banner tab, shade the top and bottom bands that drop out at about 5:1. Add a "Wide screens" preview tile next to the existing mini hero, so the preview matches what desktop visitors see. Without this, a writer can frame a face perfectly at 3:1 and still lose the eyes on a 1440p monitor.

### Step 4: Move the title bar off the subject (0.5 day)

The blue title pill sits centred at the bottom (`max-w-4xl mx-auto`), which on portrait and character art lands right over the chin and mouth, as in the reported screenshot. Options, in order of preference:

- Left-align it and narrow it to fit the title (`inline-flex`, max ~60% width), with a soft bottom gradient scrim for legibility instead of the full-width frosted bar.
- Or place the title below the banner on `md` and up, and only overlay it on phones.

Either way, the gallery editor's banner preview should render the same bar so writers can frame around it.

### Step 5: Warn on low-resolution banners (0.25 day)

The image dimensions are already stored. When an image's banner crop is under about 1200 px wide, show a "Looks soft on large screens" hint in the editor and on the gallery card's banner chip. Don't block anything.

### Step 6: Generated (Basil) images made for banners (0.5–1 day, depends on the Basil API)

Basil requests send no size, so images come back at the server default (square). A 3:1 crop of a square keeps only the middle third of its height, so generated character art usually loses the head or the feet. Options:

- If the Basil endpoint supports `width`/`height` or an aspect hint, add a "Wide (banner)" shape choice to the commission form and send it.
- Otherwise, when Basil saves a square image as a page's first image, place the default focal point a little above centre (`focal_y ≈ 0.35`) for characters and creatures, where the face usually is.

### Step 7: One hero partial (0.5 day)

`books/show.html.erb` copies the old hero markup with fixed heights. Point it at `content/_hero_header` (with `height_classes` if needed) so fixes like this one land everywhere at once. The edit page already shares the partial.

### Step 8: Regression guard (0.25 day)

Add a system test (or a Playwright check in `script/`) that loads a show page at 1920 px and asserts the hero's width equals its container's. This exact bug is invisible in narrower CI viewports.

## 4. Decisions to make

1. **Height cap on wide screens:** keep `max-h-96` (384 px, more cropping, more content above the fold) or allow up to `max-h-[28rem]`-equivalent (448 px; needs a `tailwind.config.js` entry, because the project doesn't use arbitrary values)? The plan assumes we keep 384 px.
2. **Title placement:** overlay, left-aligned (recommended), or below the banner on desktop.
3. **Basil aspect:** depends on what the generation endpoint accepts.
