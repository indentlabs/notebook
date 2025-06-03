ENV['RAILS_ENV']    ||= 'test'
ENV['RAILS_GROUPS'] ||= 'test'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new]

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class SmokeTest
  def self.urls(list_of_urls)
    # puts "Smoke testing URLs:"
    list_of_urls.each do |url_name|
      url = Rails.application.routes.url_helpers.send(url_name) rescue "INVALID URL: #{url_name}"

      # puts "#{url_name}: #{url}"
      ActionDispatch::IntegrationTest.test "should get #{url_name}" do
        get(url)
        assert_response(:success)
      end
    end
  end
end