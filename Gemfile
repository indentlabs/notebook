source 'https://rubygems.org'
ruby "~> 3.2"

# Server core
gem 'rails', '~> 7.0'
gem 'puma', '~> 5.6'
# gem 'bootsnap', require: false
gem 'sprockets', '~> 4.2.0'
gem 'terser'

group :production do
  gem 'puma-heroku'
end

# Storage
gem 'aws-sdk', '~> 3.1'
gem 'aws-sdk-s3'
gem 'filesize'

# Image processing
gem 'paperclip' # TODO: we want to migrate off this game to ActiveStorage
gem 'rmagick'
gem 'image_processing'
gem 'active_storage_validations'

# Authentication
gem 'devise'
gem 'authority'

# Billing
gem 'stripe'
gem 'stripe_event'
gem 'paypal_client' # TODO: audit whether this is still used
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

# Editor
gem 'medium-editor-rails'

# Graphs & Charts
gem 'chartkick'
gem 'd3-rails', '~> 5.9.2' # used for spider charts

# Analytics
gem 'slack-notifier'
gem 'barnes'

# Apps
#gem 'easy_translate'
#gem 'levenshtein-ffi'

# Forum
gem 'thredded', git: 'https://github.com/indentlabs/thredded.git', branch: 'feature/report-posts'
# gem 'thredded', path: "../thredded"

# gem 'thredded'
# gem 'thredded', git: 'https://github.com/sudara/thredded', branch: 'master'

gem 'rails-ujs'
gem 'language_filter'
gem 'onebox', git: 'https://github.com/indentlabs/onebox.git', branch: 'notebook-engine'
gem 'discordrb'

# Smarts
gem 'word_count_analyzer'

# Workers
gem 'sidekiq'
gem 'redis'

# Exports
gem 'csv'

# Admin
gem 'rails_admin'

# Tech debt & hacks
gem 'binding_of_caller' # see has_changelog.rb

group :test, :development do
  gem 'pry'
  gem 'sqlite3'
end

group :production do
  gem 'uglifier', '>= 1.3.0'
  gem 'newrelic_rpm'
end

group :test, :production do
  gem 'pg', '~> 1.5'

  gem "mini_racer", "~> 0.6.3" # TODO: audit whether we can remove this
end

group :test do
  gem 'codeclimate-test-reporter', require: false # TODO: remove this
  gem 'database_cleaner'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console'
  gem 'listen'
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
  gem 'textstat'
end
