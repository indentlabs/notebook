source 'https://rubygems.org'

ruby '2.2.3'

gem 'rails'
gem 'jquery-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'paperclip', '~> 4.2.0'
#gem 'rmagick', '2.13.4'
#gem 'aws-sdk', '~> 1.50'
gem 'devise'
gem 'material_icons'

group :production do
  gem 'less-rails'
  gem 'less-rails-fontawesome'
  gem 'uglifier', '>= 1.3.0'
  gem 'bootplus-rails'
  #gem 'rails_12factor'
end

group :test, :production do
  gem 'pg'
  gem 'therubyracer',  platforms: :ruby
end

group :test, :development do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'rubocop', require: false
  gem 'sqlite3'
  gem 'tzinfo-data' # addresses a bug when working on Windows

  gem 'guard'
  gem 'guard-minitest'
  gem 'guard-rubocop'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
end

# Please be sure to update the experimental buildfiles in the gemfiles folder
