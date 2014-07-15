ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def log_in_user(user_fixture)
    session[:user] = users(user_fixture).id
  end
end
