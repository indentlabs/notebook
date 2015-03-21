source 'https://rubygems.org'

gem 'rails', '4.1.0'
gem 'jquery-rails'
gem 'paperclip', '~> 4.2.0'

group :production do
  gem 'less-rails'
  gem 'less-rails-fontawesome'
  gem 'sass-rails', '~> 4.0.3'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.0.0'
  gem 'bootplus-rails'
  gem 'rmagick'
  gem 'aws-sdk', '~> 1.50'
end

group :test, :production do
  gem 'pg'
  gem 'therubyracer',  platforms: :ruby
end

group :test, :development do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'coveralls', require: false
  gem 'simplecov', :require => false
  gem 'sqlite3'
  gem 'tzinfo-data' # addresses a bug when working on Windows
end
