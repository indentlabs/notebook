source 'https://rubygems.org'
ruby "~> 2.5"

gem 'rails', '~> 5.2'
gem 'puma', '~> 3.12'
gem 'puma-heroku'

# Storage
gem 'aws-sdk', '~> 3.0'
gem 'aws-sdk-s3'
gem 'filesize'

# Image processing
gem 'paperclip'
gem 'rmagick'

# Authentication
gem 'devise'
gem 'authority'

# Billing
gem 'stripe'
gem 'stripe_event'

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

# Form enhancements
gem 'redcarpet' #markdown formatting
gem 'acts_as_list' #sortables
gem 'tribute' # @mentions

# SEO
gem 'meta-tags'

# Smarts
# gem 'serendipitous', :path => "../serendipitous-gem"
gem 'serendipitous', git: 'https://github.com/indentlabs/serendipitous-gem.git'

# Editor
gem 'medium-editor-rails'

# Graphs & Charts
gem 'chartkick'
gem 'highcharts-rails'
# gem 'highstock-rails'

# Analytics
gem 'mixpanel-ruby'
gem 'barnes'
gem 'slack-notifier'

# Apps
#gem 'easy_translate'
#gem 'levenshtein-ffi'

# Forum
gem 'thredded'
gem 'rails-ujs'

# Workers
gem 'sidekiq'
gem 'redis'

# Exports
gem 'csv'

# Admin
gem 'rails_admin', '~> 1.3'

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
  gem 'pg', '~> 1.1'
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
  gem 'ruby-prof', '0.18.0'
  gem 'shoulda-matchers', '~> 4.0'
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
  # by quite a bit), so we exclude them from all environments other than RAILS_ENV=worker.

  # Document understanding
  gem 'htmlentities'
  gem 'birch', github: 'billthompson/birch', branch: 'birch-ruby22'
  gem 'treat'#, :git => 'https://github.com/indentlabs/treat-gem.git'
  gem 'engtagger'
  gem 'ibm_watson'

  # These are unfortunately necessary as a hack to get treat running properly
  gem 'rubyzip', '>= 1.0.0' # will load new rubyzip version
  gem 'zip-zip' # will load compatibility for old rubyzip API.
end
