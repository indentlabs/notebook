ENV['RAILS_ENV']    ||= 'test'
ENV['RAILS_GROUPS'] ||= 'test'

# Without AWS credentials, the AWS SDK asks the EC2 metadata service for some
# when an S3 client is built (e.g. when BasilCommission loads its
# amazon_basil storage). Off EC2 that times out, and once WebMock is loaded it
# raises instead, leaving BasilCommission half-defined for every later test.
ENV['AWS_EC2_METADATA_DISABLED'] = 'true'

require 'minitest/reporters'
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new]

require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors) # Temporarily disabled to fix test issues

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class SmokeTest
  # Defines a "should get <url>" test on +test_class+ for each named route.
  # Define them on the calling class: tests defined on
  # ActionDispatch::IntegrationTest itself are inherited by, and rerun in,
  # every integration test.
  def self.urls(test_class, list_of_urls)
    # puts "Smoke testing URLs:"
    list_of_urls.each do |url_name|
      url = Rails.application.routes.url_helpers.send(url_name) rescue "INVALID URL: #{url_name}"

      # puts "#{url_name}: #{url}"
      test_class.test "should get #{url_name}" do
        get(url)
        # Root URL redirects authenticated users to /my/dashboard
        if url_name.to_s == 'root_url' && response.status == 302
          assert_redirected_to 'http://notebook.ai/my/dashboard'
        else
          assert_response(:success)
        end
      end
    end
  end
end