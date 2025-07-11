source 'https://rubygems.org'
ruby "~> 3.2"

# Server core
gem 'rails', '~> 6.1'

#gem 'puma', '~> 5.6'
gem 'passenger'

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

# Graphs & Charts
gem 'chartkick'
gem 'd3-rails', '~> 5.9.2' # used for spider charts

# Analytics
gem 'slack-notifier'
gem 'barnes'

# Profiling / error tracking
gem "stackprof"
gem "sentry-ruby"
gem "sentry-rails"

# Apps
#gem 'easy_translate'
#gem 'levenshtein-ffi'

# Forum
gem "html-pipeline", "~> 2.14"   # keep the pre-3.x API that Thredded expects
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

gem 'will_paginate', '~> 4.0'

# Workers
gem 'sidekiq', '~> 7.3.9'
gem 'redis', '~> 5.1.0'

# Exports
gem 'csv'

# Admin
gem 'rails_admin'

# Tech debt & hacks
gem 'binding_of_caller' # see has_changelog.rb

group :test, :development do
  gem 'pry'
  gem 'sqlite3', '~> 1.4'
  
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'dotenv-rails'
  gem 'letter_opener_web'
  gem 'minitest-reporters', '~> 1.1', require: false

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  gem 'uglifier', '>= 1.3.0'
end

group :test, :production do
  gem 'pg', '~> 1.5'

  gem "mini_racer", "~> 0.6.3" # TODO: audit whether we can remove this
end

group :test do
  gem 'codeclimate-test-reporter', require: false # TODO: remove this
  gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'rspec-rails', '~> 5.0'
  gem 'webmock', '~> 3.0'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 5.0'
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'flamegraph'
  gem 'bundler-audit'
end

group :worker do
  # These gems are only used in workers (and just so happen to slow down app startup
  # by quite a bit), so we exclude them from all groups other than RAILS_GROUPS=worker.

  # Document understanding
  gem 'htmlentities'
  gem 'birch', git: 'https://github.com/billthompson/birch.git', branch: 'birch-ruby22'
  gem 'engtagger', github: 'yohasebe/engtagger', ref: 'master' # we might want this in more groups...?
  gem 'ibm_watson'
  gem 'textstat'
end
