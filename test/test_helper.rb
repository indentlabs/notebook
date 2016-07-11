require 'simplecov'
require 'coveralls'
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

module ActiveSupport
  # Helper methods for unit tests
  class TestCase
    include FactoryGirl::Syntax::Methods

    def log_in_user(user_fixture)
      session[:user] = users(user_fixture).id
    end
  end
end

module ActionController
  # Helper methods for controller tests
  class TestCase
    include Devise::TestHelpers
    
    def assert_assigns(method, assigned = {})
      get method
      assert_response :success
      assigned.each do |val|
        assert_not assigns(val).blank?, "#{method} did not assign #{val}"
      end
    end
  end
end

module ActionDispatch
  # Helper methods for integration tests
  class IntegrationTest
    # Make the Capybara DSL available in all integration tests
    include Capybara::DSL
    include FactoryGirl::Syntax::Methods

    def register_as(email, password)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      within '#new_user' do
        click_on 'Sign up'
      end
    end

    def log_in_as(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password

      within '#new_user' do
        click_on 'Log in'
      end
    end

    def log_in_as_user
      user = create(:user)
      log_in_as user.email, user.password
      return user
    end

    def log_out
      visit destroy_user_session_path
    end

    def teardown
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
end
