# Password protected worldbuilding pages: plan

Status: proposal, nothing built yet.

Goal: give characters, locations, items, universes and every other page type in
`Rails.application.config.content_types[:all]` (29 types) the same third privacy option that
documents gained in indentlabs/notebook#1492 and indentlabs/notebook#1493: **Password protected**. The page is private everywhere
on the site, except that anyone with the link and the password can read its own page.

Books and timelines are out of scope for now (see the end of this plan).

---

## 1. How document passwords work today

### Storage and model (`app/models/documents/document.rb`)

- `documents.privacy` takes a third value, `'password'`. `PRIVACY_LABELS` holds the labels, and
  `privacy_label` / `privacy_icon` read from it, so views stop hardcoding "public vs private".
- `has_secure_password :document_password, validations: false` writes a bcrypt digest into
  `documents.document_password_digest`. The migration sets a 5 second `lock_timeout`, because
  `documents` gets a lot of autosave traffic.
- The password must be 5–72 characters, because bcrypt ignores anything past 72 bytes.
- Protection changes only through `protect_with_password(pw)` and
  `remove_password_protection(new_privacy)`.
  - The `password_protection_changed_explicitly` validation rejects any other save that changes
    privacy to or from `'password'`, or that changes the digest.
  - So a routine `update(privacy: 'public')` can't quietly strip a password. Sharing to the
    stream and submitting to a collection both do that kind of update.
- The privacy inclusion validation runs only when privacy changes, so rows with unexpected
  values can still be autosaved.
- `password_fingerprint` is `HMAC(secret_key_base, "id/digest")` cut to 16 hex characters.
  Readers' sessions store this instead of anything derived from the password. A new password
  changes the digest, so everyone who unlocked with the old one is locked out again.
- The digest stays out of `serializable_hash` and out of RailsAdmin.

### Who can read (`app/authorizers/document_authorizer.rb`)

- The owner, site admins, and the universe owner or contributors can always read the document.
- For `password_protected?` documents, the authorizer stops there. **A password outranks the
  public universe and public book rules**, so a protected document inside a public universe is
  *not* readable by the public.
- `readable_by?` never looks at the session. As far as every other part of the site is
  concerned, a protected document is just private.

### Unlocking (`DocumentPasswordsController`, `DocumentUnlocks`)

- `POST /documents/:id/unlock` checks the password and stores
  `session[:unlocked_documents][id] = fingerprint`.
  - It keeps only the 20 most recent unlocks, because the session is a shared 4KB cookie.
  - Signing out clears them along with the rest of the session.
- `PATCH` / `DELETE /documents/:id/password` are owner-only JSON endpoints used by the privacy
  modal.
- The controller raises on a CSRF failure instead of nulling the session. Otherwise a stale
  form would silently drop the unlock.
- `DocumentsController#show`:
  - A protected document gets the lock screen (`documents/locked.html.erb`) instead of the
    "doesn't exist" redirect.
  - Readers who have unlocked it get the normal page, with `Cache-Control: no-store` and
    `noindex`.
  - Only the reading page honors an unlock. Analysis, plaintext, revisions, sharing and editing
    stay closed.
- The lock screen shows only the author and a password field: no title, text, length or dates.

### Rate limiting (`config/initializers/rack_attack.rb`)

- Limits: 10/min per visitor IP (taken from `CF-Connecting-IP`), 30/min per document, and
  300/min site-wide. Each bcrypt check holds a Puma thread, which is why there's a site-wide
  limit.
- The path is unescaped and `/` runs are squeezed before matching. The route is strict
  (`format: false`, `id: /\d+/`), so other spellings of the path can't get around the limits.
- A visitor who hits a limit is sent back to the lock screen with `?too_many_attempts=1`.

### Places outside the document page that were made password-aware

- Book pages:
  - Locked chapters appear as "Password protected chapter" with no title or length.
  - Locked chapters are left out of word count and reading time, and their characters aren't
    listed as appearing in the book.
  - The private-chapter warning doesn't count protected chapters.
- Universe documents tab and count use `Universe#documents_listable_by`.
- References and "mentioned in" use `public_or_owned_by`.
- Shares: `ContentPageShare` validation stops anyone from sharing a protected document, and old
  shares stop previewing it.
- Collections refuse documents of any kind.
- Tag pages only show `privacy = 'public'` pages, so protected documents' tags stay off them.
- The privacy modal has a third radio option, an inline password form, and a copy-link box.

### Tests

About 90 tests across `test/models/document_password_test.rb`,
`test/controllers/document_password_privacy_test.rb`,
`test/controllers/document_passwords_controller_test.rb` and
`test/controllers/document_share_link_test.rb`. They cover the leak checks, the unlock and
session behavior, every rate limit, CSRF, and keeping passwords out of the logs.

### Design principle worth keeping

**Fail closed.** `'password'` is a new value that every existing `privacy == 'public'` check
already treats as private. The work is mostly in two places: the few paths that grant access by
some *other* route (a public universe, a public book), and the one page that deliberately lets
an unlocked reader in.

---

## 2. What is different about worldbuilding pages

These findings come from a sweep of every place that shows page data to someone other than its
owner or contributors.

1. **Universe inheritance happens in many places, and each one compares against the literal
   `'public'`.** Today a public universe makes all its pages public. Each of these needs a
   "unless the page is password protected" exception:
   - `HasPrivacy.is_public` scope (`app/models/concerns/has_privacy.rb:7-13`). It feeds
     profiles, universe content lists, the table of contents and favorites.
   - `HasPrivacy#public_content?`.
   - `ContentAuthorizer#readable_by?` (`content_authorizer.rb:5`). This is the instance read
     check for Character, Location, Item and every premium type.
   - `CoreContentAuthorizer.readable_by?` (the class-level check).
   - `AttributeAuthorizer#readable_by?` (`attribute_authorizer.rb:15`). Without a fix here,
     **attribute values of a protected page in a public universe would stay readable**.
   - `PermissionService.content_is_in_a_public_universe?` /
     `content_is_publicly_visible?`. The share and collection permission checks use these.
2. **There are 29 tables, not one.** Adding a digest column to each means 29 `add_column`s,
   plus a leak risk on each table:
   - Raw `render json: @content` in `ContentController` (index, edit and update)
   - RailsAdmin, which shows every column of every content type
   - `ContentSerializer` and `ApiContentSerializer`
   - The export service
3. **The show page is a composite.** Documents have one body. A content page's show page has
   attribute values, a gallery, associations, documents, timelines, shares, collections, and
   for universes an "in this universe" section, and each partial does its own `readable_by?` /
   `can_read?` checks. `ContentController#show` also builds the serializer and all the counts
   *before* it checks access (`content_controller.rb:115-210`).
4. **Contributors can change page privacy** (`updatable_by?` includes them). For documents only
   the author can.
5. **Some paths publish a page automatically**:
   - `ContentPageSharesController#create` runs `update(privacy: 'public')` when you share your
     own page.
   - `PageCollectionSubmission#mark_related_content_public` does the same when you submit your
     own page to a public collection.

   Once the explicit-change validation exists, those updates fail *silently*. In the
   collection case the submission is still created. Both flows need to refuse protected pages
   up front.
6. **The privacy UI is binary in about 10 places**, and the React `PrivacyToggle.js` flips
   anything that isn't `'public'` to `'public'`.
7. **Foods, Schools and Sports don't permit `:privacy`** in their controllers. Their privacy UI
   already does nothing. Password protection goes through its own controller, so it isn't
   affected, but it's worth fixing on the way past.

---

## 3. Proposed design

### 3.1 Storage: one polymorphic `page_passwords` table

```ruby
create_table :page_passwords do |t|
  t.references :page, polymorphic: true, null: false, index: { unique: true }
  t.string :password_digest, null: false
  t.timestamps
end
```

- The `privacy` column on each content table holds `'password'`, as documents do. Every
  existing `privacy == 'public'` check keeps failing closed without any change.
- The digest lives in a separate model:
  `PagePassword belongs_to :page, polymorphic: true; has_secure_password validations: false`.
  So `render json: @content`, serializers, exports, changelog events and RailsAdmin can't leak
  it, because it isn't a column on any of them. It also means one migration instead of 29, and
  no lock on the big tables.
- `has_one :page_password, as: :page, dependent: :destroy`, added through the new concern.
- **Documents stay on their column for now.** Moving them onto `page_passwords` later is a
  separate, optional cleanup: copy the digests, then switch the concern over.

### 3.2 Model concern: `HasPasswordProtection`

Include it from `IsContentPage`, so every type in `content_types[:all]` gets it. Model it on
`Document`:

- `PRIVACY_LABELS`, `privacy_label`, `privacy_icon`, `password_protected?`
- `protect_with_password(pw)` and `remove_password_protection(new_privacy)`, wrapped in a
  transaction (privacy column plus the `PagePassword` row)
- The `password_protection_changed_explicitly` validation, so generic updates, PATCH requests
  from contributors, the share and collection auto-publish paths, and RailsAdmin can't set or
  remove `'password'`
- A `page_password` presence validation when privacy is `'password'`
- An inclusion validation only when privacy changes, so rows with unexpected legacy values can
  still be saved
- `password_fingerprint`: `HMAC(secret, "#{self.class.name}/#{id}/#{digest}")`
- Length rule `5..72`, shared with `Document::PASSWORD_LENGTH`

It may make sense to put the shared pieces (fingerprint, length rule, the explicit-change guard)
into one module that `Document` also includes, behind a small `password_digest_value` /
`assign_password` interface. Worth doing if it stays small; otherwise accept a little
duplication.

### 3.3 Authorization: password outranks a public universe

These checks change: `ContentAuthorizer`, `CoreContentAuthorizer.readable_by?`,
`AttributeAuthorizer`, `HasPrivacy#public_content?`, the `is_public` scope and
`PermissionService.content_is_in_a_public_universe?`.

**Readers who skip the password.** Owner, universe owner, universe contributors and site admins
read the page without it. That matches today's private-page rules and `DocumentAuthorizer`.

**Everyone else.** A public universe grants nothing to a password-protected page.

`is_public` becomes roughly this:

```sql
pages.privacy = 'public'
OR (universes.privacy = 'public' AND (pages.privacy IS NULL OR pages.privacy != 'password'))
```

**A password-protected universe.** Its own privacy isn't `'public'`, so its pages no longer
inherit anything. Each page falls back to its own setting, which is the fail-closed outcome
(but see open question 2).

**The session stays out of `readable_by?`.** Same as documents: everything outside the show
page treats a protected page as private.

### 3.4 Unlocking

- **Generalize `DocumentUnlocks` into `PageUnlocks`.**
  - Keep a single session hash keyed `"Document-12"` / `"Character-5"`, holding the last 20–30
    unlocks across both kinds (about 40 bytes per entry). Keep reading the old
    `:unlocked_documents` key for one release, so existing readers aren't locked out.
  - Add the retired name to `RetiredCodeTest::RETIRED`.
- **New `PagePasswordsController`**, routed on every content type in the existing `/plan` loop
  in `config/routes.rb`:

  ```
  PATCH  /plan/characters/:id/password   # owner sets or changes
  DELETE /plan/characters/:id/password   # owner removes (with new privacy)
  POST   /plan/characters/:id/unlock     # anyone; format: false, id: /\d+/
  ```

  The page class comes from a route default, not a param, so no `constantize` on user input.
  It keeps `protect_from_forgery with: :exception` and the `InvalidAuthenticityToken` rescue
  from the document controller.
- **`ContentController#show`**:
  - Move the access decision to straight after the `find_by` / blocked-owner checks, before the
    serializer and counts are built.
  - Viewer can read the page: unchanged.
  - Page is protected and the viewer has unlocked it: render the show page (HTML only, no JSON)
    with `Cache-Control: no-store` and `noindex`.
  - Page is protected and still locked: render a new `content/locked.html.erb` (page type icon
    and color, owner, password form). It shows nothing that comes from the page itself: no
    name, cover, counts or dates.
  - Page is private: the existing redirect, unchanged.
- **How the unlock reaches the show page's partials.**
  - Use a request-scoped grant: `Current.unlocked_page = @content` (a `CurrentAttributes`
    attribute, set only in `show`).
  - `ContentAuthorizer` and `AttributeAuthorizer` honor it **for that exact record only**. The
    universe, linked pages and images still go through their own rules.
  - This is the one real departure from documents. Documents could special-case a single view,
    but a content page has dozens of partials that each check readability.
  - Because the grant is cleared after every request, it can't reach any other route.
- **What an unlocked reader sees** (recommended): the page's public attribute fields, public
  gallery images, and linked pages, documents and timelines filtered by their own rules. No
  edit, changelog, references or share actions, and no JSON.

### 3.5 Rate limiting

- Extend `rack_attack.rb`. Build one regex from `content_types[:all]` (plus `documents`):

  ```ruby
  %r{\A/(?:plan/)?(documents|universes|characters|...)/(\d+)/unlock/?\z}i
  ```

- Key the per-page limit on `"type/id"`.
- **Share one site-wide bucket with documents**, because it protects the same Puma threads.
- The throttled responder redirects to the matching page's lock screen.

### 3.6 Closing the paths that would bypass or leak

Each item needs a test asserting a protected page in a **public universe** doesn't leak to a
stranger or an anonymous viewer.

| Surface | Today | Change |
|---|---|---|
| Profile lists, favorites, featured universes, universe content lists, TOC (`is_public`) | page or universe public | fixed by the scope change |
| `users#tag`, `browse#tag`, `users#popular tags` | direct `privacy='public'` | already safe; add tests |
| Stream shares (`ContentPageShare` validation) | uses `try(:password_protected?)` | already blocks pages once the method exists; generalize the "documents" error copy; hide the share button on protected pages |
| `ContentPageSharesController#create` auto-publish | `update(privacy:'public')` | the validation above refuses first; don't attempt the update |
| Collection submissions | owner submission auto-publishes | add a "can't be password protected" error to `submitter_can_publish_content` |
| Collection lists and RSS (`cached_content_name`) | filtered by `hide_unreadable_pages` | verify the editor picks are filtered too; test |
| Name lookups (`/api/internal/.../name`, `/api/v1/page_name`), `[[Type-id]]` tokens, link chips | `readable_by?` | safe (shows "Private character"); test |
| API v1 show endpoints | `readable_by?` | safe, because the request grant is only set in `show`; test |
| Universe show page counts (`@in_this_universe_count`, books, shares) | unfiltered counts | only shown to people who can read the universe; for an unlocked universe, count readable pages only |
| Character chat landing (`ConversationController#ensure_character_privacy`) | `privacy=='public'` only | already safe |
| Timeline linked entities (`TimelineEventsController#link_entity`) | **no readability check** (see 3.7) | fix before shipping |
| Document analysis entity list | cached names, no readability check | filter by `readable_by?` (pre-existing; see 3.7) |
| OG/Twitter meta on show | only after the access check | locked view sets `noindex` with a generic title; unlocked view sets `noindex` |
| Exports | owner only | resolve link-code names only for readable pages (pre-existing; low priority) |
| RailsAdmin | content types editable | the explicit-change validation blocks setting `'password'` there; `PagePassword` isn't in the admin list |

### 3.7 Pre-existing gaps found during the review

These affect **private** pages today, not just future protected ones. Each would undermine
password protection if left alone.

1. **`TimelineEventsController#link_entity`** permits any `entity_type` / `entity_id` with no
   check that the linker can read the entity.
   - The returned card (`shared/_timeline_event_linked_content.html.erb`) and the public
     timeline show page render the entity's name and its **private** cover image
     (`include_private: true`).
   - So any signed-in user can show someone else's private page by ID on their own public
     timeline.
   - Fix: allowlist `entity_type` against the content types, require
     `entity.readable_by?(current_user)`, and drop `include_private` for non-owners.
2. **Private gallery images on public surfaces.** `users/tabs/_content.html.erb:99`,
   `conversation/character_landing.html.erb` and the timeline card above use
   `include_private: true` for viewers who aren't the owner.
3. **Document analysis entities** (`documents/analysis/sections/_entities.html.erb`) show cached
   entity names and `image_uploads.sample`, without checking the entity's own readability.
4. Smaller ones:
   - A private page returns a 302 but a missing page returns a 404, which tells you whether a
     page exists.
   - `DocumentsController#analysis` redirects without `return`.
   - Contributor checks are inconsistent: `universes_controller.rb:32` and
     `main_controller.rb:75` use `Contributor.exists?(user_id:)` only.

I'd ship item 1 as its own PR first, and fold 2 and 3 into the server-side PR below.

### 3.8 UI

- **Edit page privacy panel** (`content/edit/_dynamic_content.html.erb`, plus the JS state in
  `content/edit.html.erb`):
  - Add a third radio option with an inline password form and a copy-link box, modeled on
    `documents/_privacy_modal.html.erb`.
  - The password field sits outside any form and has no `name`, so only the save button can
    send it.
  - Extract the shared password panel into a partial that both modals use.
- **Show page** `_privacy_view`, sidebars, badges and the changelog: switch to
  `privacy_label` / `privacy_icon`.
- **`PrivacyToggle.js`** and `content/_share.html.erb`: treat `'password'` as its own state.
  Don't let a single click turn it into `'public'`; send the owner to the privacy panel instead.
- **Universe privacy panel**: explain that protected pages inside a public universe stay
  protected.
- **Share-to-stream and collection quick-add**: explain that protected pages can't be shared or
  submitted.
- **Help center** (`help/organizing_with_universes`, `help/free_features`): document the option.

---

## 4. Rollout (mirrors how documents shipped)

1. **Timeline linking fix** (3.7 item 1). Small and independent.
2. **Server-side rules.**
   - Migration and `PagePassword`.
   - `HasPasswordProtection`.
   - The authorizer and scope changes from 3.3.
   - The share and collection refusals.
   - Items 2 and 3 from 3.7.
   - No way to set a password yet, so old and new processes can overlap safely during a deploy.
   - Tests: a model test that loops over `content_types[:all]`, and a privacy test like
     `document_password_privacy_test.rb` for a Character and a Universe inside a public universe.
3. **Unlock flow.**
   - `PageUnlocks`, `PagePasswordsController`, routes, the lock screen, the `show` changes and
     the `Current` grant.
   - Rate limits.
   - Controller tests modeled on `document_passwords_controller_test.rb`, run against at least
     a free type, a premium type and Universe.
4. **UI.** The privacy panels, labels and icons, copy-link box and help pages.
5. *(Optional)* Move `Document` onto `page_passwords` and the shared concern.

Per `docs/release_safety.md`:

- The new routes are POST/PATCH/DELETE, so `RouteSmokeTest` needs no new `param_value`.
- Add a password-protected character in a public universe to `test/smoke/smoke_data.rb`, so
  every visitor kind exercises the lock screen.
- Add `DocumentUnlocks` (and any renamed helpers) to `RetiredCodeTest::RETIRED`.
- Use redirects or `RecordNotFound`, never a bare `raise`, for denied or missing pages in the
  new controller.

---

## 5. Open questions

1. **Who can set or remove a page's password?** Today contributors can change a page's privacy.
   *Recommendation:* the page owner only, matching documents. The password is something the
   owner hands out, and contributors don't need it to read the page.
2. **Should unlocking a universe unlock the pages inside it?** This is probably the most
   valuable version for game masters ("one password for my players"). It's also a much bigger
   change: every list, link, gallery and API check inside the universe would have to become
   session-aware.
   *Recommendation:* not in v1. A protected universe protects only its own page, and its pages
   keep their own settings. Revisit as a follow-up, with an explicit "pages inherit the
   universe password" setting.
3. **What does an unlocked reader see on a universe's page?** *Recommendation:* the universe's
   own content, plus only the pages they could already read without the unlock.
4. **Gallery on an unlocked page.** Image files are public S3 URLs with year-long public
   caching. Once a reader has a file URL, a password can't take it back.
   *Recommendation:* show public gallery images to unlocked readers, and say in the UI that
   images can be re-shared.
5. **Books and timelines.** They have their own authorizers and their own privacy UI. Once
   pages are done, adding them should be mostly mechanical, but they aren't in
   `content_types[:all]`, so they're excluded here.
