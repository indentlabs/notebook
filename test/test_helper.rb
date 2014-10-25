ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'
require 'coveralls'
Coveralls.wear_merged!('rails')

class ActiveSupport::TestCase
  fixtures :all

  def log_in_user(user_fixture)
    session[:user] = users(user_fixture).id
  end
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  
  def register_as(name, email, password)
    visit homepage_path
    click_on 'Register'
    fill_in 'user_name', :with => name
    fill_in 'user_email', :with => email
    fill_in 'user_password', :with => password
    click_on 'Create User'
  end
  
  def log_in_as(user, password)
    visit homepage_path
    click_on 'Login'
    within('#new_session') do
      fill_in 'session[username]', :with => user
      fill_in 'session[password]', :with => password
      click_on 'Log in'
    end
  end
  
  def log_in_as_anon
    visit homepage_path
    click_on 'Login'
    click_on 'Be Anonymous'
    click_on 'I understand, create an account for me'
  end
  
  def log_out
    visit logout_path
  end
  
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
