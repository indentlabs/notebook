# Page banners: review and changes

Follow-up to `docs/gallery_ux_plan.md`. It started from a report that banner images on `content#show` no longer filled the width of the page on desktop, and left a dark strip on the right.

## 1. The bug

The framing work (8c6c5d5, 2026-09-02) gave the hero a 3:1 shape on tablet and up, with a height cap:

```
md:h-auto md:aspect-banner md:max-h-96
```

When a box has `aspect-ratio` and an automatic width, CSS sends the `max-height` cap back through the ratio and shrinks the width to match. Once the content column was wider than 1152 px (384 px × 3), the box stopped at 1152 px and the rest of the row showed bare `bg-gray-900`. In Chromium, at a 1920 px viewport the box rendered 1152×384 without `width: 100%`, and 1904×384 with it.

**Fix:** `w-full`. The banner box classes now live in one place, `ImagePresets::BANNER_BOX_CLASSES`, which explains why the `w-full` matters. `content/_hero_header` and `books/show` both use it, so the book page now has the same banner shape as content pages instead of its own fixed heights. (The edit page still passes its own shorter `height_classes`.)

## 2. Decisions

- **Keep the 384 px cap** on wide screens.
- **Title bar unchanged.**
- **Basil images are arbitrary images.** The Basil API takes no size or aspect, so a generated image is handled exactly like an upload of unknown resolution. There's no Basil-specific code.
- **Never stretch.** Every banner uses `object-fit: cover`: it scales to fill without distorting, and trims the overflow.

## 3. How a banner handles an image of any size

1. **Crop to 3:1.** The writer's banner crop, or else the automatic crop: the largest 3:1 rectangle centred on the focal point (`HasImageFraming.auto_rect`).
2. **Shrink, never enlarge.** The banner derivative is now up to 2400×800, which is sharp on large and high-density screens. A crop smaller than that keeps its own resolution: enlarging only makes the file bigger, and the browser scales it anyway. The same applies to every shape, for uploads (`Paperclip::Cropper` resizes with `>`) and Basil variants (`resize_to_limit` after the crop).
3. **Honest sizes.** `ContentImage#preset_dimensions` reports the size the file really has, so `width`/`height` and the `srcset` are accurate. When a small source would make `banner_sm` and `banner` the same file, the `srcset` is left out.
4. **Trim around the focal point.** On screens wider than about 1150 px the box is wider than 3:1 (about 4.4:1 at 1920 px, 6:1 at 2560 px), so cover trims the top and bottom. `ContentImage#preset_object_position` sets `object-position` from where the focal point sits *inside the crop*, so the trim keeps it in view. When a custom crop leaves the focal point out, the crop is the better guide, and the image stays centred. This runs in `content_image_tag`, so cards, universe headers and every other shape benefit as well.

| Viewport (sidebar open) | Box | Visible share of the 3:1 crop's height |
|---|---|---|
| 768–1150 px | 3:1 | 100% |
| 1440 px | ~3.2:1 | ~95% |
| 1920 px | ~4.4:1 | ~68% |
| 2560 px | ~6:1 | ~49% |

## 4. Editor

- A second banner preview at 5:1 shows what wide screens keep, using the same focal-point trim as the site. Every preview now trims that way, and all of them redraw when the focal point moves.
- A hint appears under the banner previews when the crop is under 1200 px wide: the banner may look soft on large screens, and a larger image or wider crop will look sharper. It's advice, not a block.

## 5. Rolling out

No backfill. With about a million uploads in S3, regenerating would mean roughly 13 million S3 writes (every style is rebuilt, not only the banner) and weeks of ImageMagick time, all to sharpen banners on old pages, mostly ones nobody visits.

- The width fix and the focal-point trim are applied when the page renders, so they reach every image as soon as this is deployed.
- Existing uploads keep their 1500×500 banner files, which look the same as before. `preset_dimensions` may describe one of these as 2400 px wide. That only steers which `srcset` entry the browser picks, and there is no larger file to pick, so nothing changes visibly.
- New uploads, new Basil images and any image a writer reframes get the 2400×800 banner from the jobs that already run on upload and on reframe. Basil variants have new variant keys, so they regenerate on first view.

If old banners ever need upgrading, do it lazily rather than in bulk: when a banner is rendered for an upload whose `crops_generated_at` predates this change and whose source is wider than 1500 px, enqueue a banner-only reprocess (`reprocess!(:banner, :banner_sm)`), at most once per image. Only pages people actually visit would pay the cost.

## 6. Left alone

- `books/show` has a gradient overlay using `from-gray-900/60`. Slash opacity isn't supported in this project's Tailwind setup, so it renders nothing today. It was left as is to keep the book page's look unchanged.
