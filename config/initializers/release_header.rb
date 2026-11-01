# Say which commit is serving each response, in an X-Release header. The
# staging smoke check (.github/workflows/staging_smoke.yml) waits for a PR's
# Railway environment to serve the PR's latest commit before crawling it.
# The repository is public, so the commit SHA isn't a secret.
release = ENV['RAILWAY_GIT_COMMIT_SHA'].presence || ENV['SENTRY_RELEASE'].presence
Rails.application.config.action_dispatch.default_headers['X-Release'] = release if release
