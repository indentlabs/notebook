source 'https://rubygems.org'
ruby "~> 2.6"

# Server
gem 'rails'
gem 'puma', '~> 4.3'
gem 'puma-heroku'
# gem 'bootsnap', require: false
gem 'sprockets', '~> 3.7.2'

# Storage
gem 'aws-sdk', '~> 3.0'
gem 'aws-sdk-s3'
gem 'filesize'

# Image processing
gem 'paperclip'
gem 'rmagick'
gem 'image_processing'
gem 'active_storage_validations'

# Authentication
gem 'devise'
gem 'authority'

# Billing
gem 'stripe'
gem 'stripe_event'
gem 'paypal_client' # todo do we need this gem after all?
gem 'paypal-checkout-sdk'

# Design
gem 'material_icons'
gem 'font-awesome-rails'
gem 'sass-rails'

# Quality of Life
gem 'cocoon'
gem 'dateslices'
gem 'paranoia'

# Javascript
gem 'coffee-rails'
gem 'rails-jquery-autocomplete'
gem 'animate-rails'
gem 'webpacker'
gem 'react-rails'

# Form enhancements
gem 'redcarpet' #markdown formatting
gem 'acts_as_list' #sortables
gem 'tribute' # @mentions

# SEO
gem 'meta-tags'

# Smarts
# gem 'serendipitous', :path => "../serendipitous-gem"
gem 'serendipitous', git: 'https://github.com/indentlabs/serendipitous-gem.git'
gem 'gpt3'

# Editor
gem 'medium-editor-rails'

# Graphs & Charts
gem 'chartkick'
gem 'd3-rails'

# Analytics
gem 'mixpanel-ruby'
gem 'slack-notifier'
gem 'barnes'

# Apps
#gem 'easy_translate'
#gem 'levenshtein-ffi'

# Feature rollout
gem 'flipper'
gem 'flipper-redis'

# Forum
gem 'thredded', git: 'https://github.com/indentlabs/thredded.git', branch: 'feature/report-posts'
gem 'rails-ujs'

# Workers
gem 'sidekiq'
gem 'redis'

# Exports
gem 'csv'

# Admin
gem 'rails_admin', '~> 2.0'

# Tech debt & hacks
gem 'binding_of_caller' # see has_changelog.rb

group :test, :development do
  gem 'pry'
  gem 'sqlite3'
end

group :production do
  gem 'rails_12factor'
  gem 'uglifier', '>= 1.3.0'
  gem 'newrelic_rpm'
end

group :test, :production do
  gem 'mini_racer'
  gem 'pg', '~> 1.2'
end

group :test do
  gem 'better_errors'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'tzinfo-data' # addresses a bug when working on Windows
  gem 'rails-perftest'
  gem 'rspec-prof'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'rubocop', require: false
  gem 'ruby-prof', '1.4.1'
  gem 'shoulda-matchers', '~> 4.3'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console'
  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'flamegraph'
  gem 'stackprof'
  gem 'bundler-audit'
end

group :worker do
  # These gems are only used in workers (and just so happen to slow down app startup
  # by quite a bit), so we exclude them from all groups other than RAILS_GROUPS=worker.

  # Document understanding
  gem 'htmlentities'
  gem 'birch', git: 'https://github.com/billthompson/birch.git', branch: 'birch-ruby22'

  gem 'engtagger'
  gem 'ibm_watson'
end
