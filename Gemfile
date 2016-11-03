source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'puma', '~> 3.6.0'
gem 'puma-heroku'
gem 'rack-timeout'

# Storage
gem 'aws-sdk', '~> 1.50'

# Image processing
gem 'paperclip', '~> 4.2.0'
gem 'rmagick', '2.13.4'

# Authentication
gem 'bcrypt'
gem 'devise'

# Design
gem 'material_icons'
gem 'sass-rails'

# Quality of Life
gem 'cocoon'
gem 'dateslices'

# Javascript
gem 'coffee-rails'
gem 'rails-jquery-autocomplete'

# SEO
gem 'meta-tags'

# Smarts
# gem 'serendipitous', :path => "~/git/serendipitous-gem"
gem 'serendipitous', git: 'https://github.com/indentlabs/serendipitous-gem.git'

# Editor
gem 'medium-editor-rails'

# Graphs & Charts
gem 'chartkick'
gem 'slack-notifier'

# Form enhancements
gem 'redcarpet' #markdown formatting

group :production do
  gem 'rails_12factor'
  gem 'uglifier', '>= 1.3.0'
  gem 'scout_apm'
end

group :test, :production do
  gem 'pg'
  gem 'therubyracer', platforms: :ruby
end

group :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: false
  gem 'coveralls', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'pry'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'sqlite3'
  gem 'tzinfo-data' # addresses a bug when working on Windows
  gem 'rails-perftest'
  gem 'rspec-prof'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'ruby-prof', '0.15.9'
  gem 'shoulda-matchers', '~> 3.1'
end
