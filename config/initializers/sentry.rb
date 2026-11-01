Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Tag every error with the commit that's running, so Sentry can say which
  # deploy introduced a new error ("first seen in release abc123") and alert
  # on regressions right after a deploy. The Docker image doesn't include .git,
  # so Sentry can't work this out by itself: Railway provides the commit SHA,
  # and SENTRY_RELEASE overrides it anywhere else.
  config.release = ENV['SENTRY_RELEASE'].presence || ENV['RAILWAY_GIT_COMMIT_SHA'].presence

  # Keep staging's errors apart from production's.
  config.environment = ENV['SENTRY_ENVIRONMENT'].presence || ENV['RAILWAY_ENVIRONMENT_NAME'].presence || Rails.env

  # Add data like request headers and IP for users,
  # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
  config.send_default_pii = true

  # Errors are always all reported; these only control performance tracing
  # and profiling. Tracing every request at our traffic is costly and buries
  # the signal, so sample a slice by default. Raise these with environment
  # variables (no deploy needed) when digging into a slow page.
  config.traces_sample_rate   = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.05').to_f
  config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', '0.05').to_f
end
