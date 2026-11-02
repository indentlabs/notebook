# Keeping deploys from breaking the site

Most of the bugs we've shipped were pages that 500 because they called a
method, helper, route or constant that had been renamed or removed. Ruby only
notices that when the line runs, which is often on a page no test visits.
These checks are there to catch that before users do.

## What runs on every pull request

`.github/workflows/tests.yml` runs on every PR and every push to `master`:

1. **The whole app is loaded up front.** GitHub sets `CI=true`, which turns on
   `eager_load` in `config/environments/test.rb`, the way production boots.
   A syntax error or a bad constant in a class body fails the build, even in a
   file no test touches. `test/lint/eager_load_test.rb` checks the same thing
   when you run the suite locally.
2. **`bin/rails test`**, which includes:
   - **`test/smoke/route_smoke_test.rb`.** This requests *every* GET route,
     forum pages included, as five kinds of visitor: the owner, a collaborator
     on their universe, a signed-in stranger, a logged-out visitor and an
     admin. It fails on any response production would serve as a 5xx, and
     lists every broken page with the exception and the line it came from.
     The data comes from `test/smoke/smoke_data.rb`: one premium writer's
     world with a page of every content type, documents, books, timelines,
     collections and forum topics. Some of it is deliberately messy (a bare
     page, an orphaned tag, a share of a deleted page, a post by a deleted
     user).
   - **`test/lint/retired_code_test.rb`**, which fails if anything in `app/`
     still uses a method, helper, route or constant we removed.
   - **`test/lint/stripe_api_version_test.rb`** (see Stripe below).
3. **`bundle exec rspec`**, for the older specs in `spec/`.

### When you add a route

Usually nothing: the smoke test picks it up automatically. If the route has a
path parameter it hasn't seen before (`:widget_id`, say), *every GET route is
smoke tested or explicitly skipped* fails and tells you so. Teach
`RouteSmokeTest#param_value` (or `#id_for` for a new controller's `:id`) where
to find a value, adding the record to `SmokeData` if needed.

If a route can't be requested safely in a test (it signs you out or hands off
to a payment provider, for example), add it to `RouteSmokeTest::SKIPPED_ROUTES`
with the reason.

### When you remove or rename something

Add the old name to `RetiredCodeTest::RETIRED` with a hint about what to use
instead. A stale call from another branch, or from copy-paste, then fails CI
instead of production.

### When the smoke test fails

The message lists every broken page, the visitor it broke for, the exception,
and the first line of our code in its backtrace. Run just that visitor with:

    bin/rails test test/smoke/route_smoke_test.rb -n "/stranger/"

Pages that reach for Stripe or other outside HTTP (blocked by WebMock), or for
Redis (not running in CI), aren't counted as failures; they need their own
tests with stubs.

## Branch protection (set once, in GitHub)

CI only helps if a red build can't be merged. In **Settings → Branches → Add
branch protection rule** (or **Rules → Rulesets**) for `master`:

- Require a pull request before merging.
- Require status checks to pass, and pick the **test** check from the Tests
  workflow.
- Do not allow bypassing the above settings (or limit it to admins, for
  emergencies).

After that, push to a branch and open a PR instead of pushing to `master`.

## Before and after a deploy

`script/smoke_check.rb` crawls a running copy of the site and exits non-zero
if any page returns a 5xx. It only needs Ruby, not the app.

    # Public pages
    ruby script/smoke_check.rb https://staging.notebook.ai

    # Signed in, as the test account (db/seeds.rb creates it on staging;
    # it already exists in production)
    SMOKE_EMAIL=test.test@test.test SMOKE_PASSWORD=... \
      ruby script/smoke_check.rb https://staging.notebook.ai

The signed-in crawl reaches more pages when the account owns some content
(a universe, a few pages, a document).

It starts at the main pages and follows links on the same host (up to
`SMOKE_MAX_PAGES`, default 300, with `SMOKE_DELAY` seconds between requests).
It never follows links that change data with a GET (sign out, unfollow,
delete, billing and so on); see `NEVER_FOLLOW` in the script.

### On every pull request, automatically

Railway deploys each PR to `https://notebook-notebook-pr-<number>.up.railway.app`
once its tests pass. `.github/workflows/staging_smoke.yml` then waits for that
environment to serve the PR's latest commit (every response carries it in an
`X-Release` header, from `config/initializers/release_header.rb`), crawls it
with `script/smoke_check.rb`, and reports **Staging smoke check** on the PR.

It runs master's copy of the workflow and the script, so it starts working for
PRs once it's merged. Add the test account's password on PR environments as
the `SMOKE_PASSWORD` Actions secret; without it, only public pages are crawled.
`SMOKE_EMAIL` is optional and defaults to `test.test@test.test`. To make the
check block merging, add **Staging smoke check** to the required status checks.

The release flow, then:

1. Merge to `master` once the tests and the staging smoke check are green.
2. Deploy to staging; run `script/smoke_check.rb` against it, signed in.
3. Deploy to production; run it against production.
4. Watch Sentry for new issues in the new release for the next 30 minutes.
   If something new and widespread shows up, roll back first and debug after.

## Sentry

`config/initializers/sentry.rb` tags every error with the release (the commit
SHA from `RAILWAY_GIT_COMMIT_SHA`, or `SENTRY_RELEASE` if set) and the
environment (`RAILWAY_ENVIRONMENT_NAME`, or `SENTRY_ENVIRONMENT`). That lets
Sentry say which deploy introduced an error. In Sentry, set up:

- an alert on **new issues** in production, and
- an alert on **regressions** (a resolved issue coming back),

both sent somewhere you'll see them right after a deploy.

Performance tracing and profiling sample 5% of requests by default. Change
`SENTRY_TRACES_SAMPLE_RATE` / `SENTRY_PROFILES_SAMPLE_RATE` (0.0–1.0) to
sample more without a deploy. Errors are always reported in full.

## Stripe

`config/initializers/stripe.rb` pins the Stripe API version our billing code
is written against. Stripe changes the shape of its responses between versions,
and the stripe gem moves to a new version with each major release, which has
broken the billing pages before. When an upgrade changes the version,
`stripe_api_version_test.rb` fails. Read Stripe's changelog for the versions in
between, update the pin, and click through the billing pages on staging.
Dependabot no longer opens PRs for major stripe releases.
