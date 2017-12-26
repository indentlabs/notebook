source 'https://rubygems.org'
ruby "~> 2.3.0"

gem 'rails', '4.2.7.1'
gem 'puma', '~> 3.6.0'
gem 'puma-heroku'
gem 'rack-timeout'

# Storage
gem 'aws-sdk', '~> 1.5'
gem 'filesize'

# Image processing
gem 'paperclip'
gem 'rmagick'

# Authentication
gem 'bcrypt'
gem 'devise'
gem 'authority'

# Billing
gem 'stripe'

# Design
gem 'material_icons'
gem 'sass-rails'

# Quality of Life
gem 'cocoon'
gem 'dateslices'
gem 'paranoia'

# Javascript
gem 'coffee-rails'
gem 'rails-jquery-autocomplete'

# SEO
gem 'meta-tags'

# Smarts
# gem 'serendipitous', :path => "../serendipitous-gem"
gem 'serendipitous', git: 'https://github.com/indentlabs/serendipitous-gem.git'

# Editor
gem 'medium-editor-rails'

# Graphs & Charts
gem 'chartkick'
gem 'slack-notifier'

# Form enhancements
gem 'redcarpet' #markdown formatting

# Analytics
gem 'raygun4ruby'
gem 'mixpanel-ruby'

# Sharing
gem 'social-share-button'

# Apps
#gem 'easy_translate'
gem 'levenshtein-ffi'

# Forum
gem 'thredded', '~> 0.13.2'
gem 'rails-ujs'
gem 'delayed_job_active_record'

# Tech debt & hacks
gem 'binding_of_caller' # see has_changelog.rb

group :production do
  gem 'rails_12factor'
  gem 'uglifier', '>= 1.3.0'

  gem 'newrelic_rpm'
end

group :test, :production do
  gem 'pg'
  gem 'therubyracer', platforms: :ruby
end

group :test do
  gem 'better_errors'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: false
  gem 'coveralls', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'sqlite3'
  gem 'tzinfo-data' # addresses a bug when working on Windows
  gem 'rails-perftest'
  gem 'rspec-prof'
  gem 'rspec-rails'
  gem 'webmock'
  gem 'rubocop', require: false
  gem 'ruby-prof', '0.15.9'
  gem 'shoulda-matchers', '~> 3.1'
end

group :test, :development do
  gem 'pry'
end
