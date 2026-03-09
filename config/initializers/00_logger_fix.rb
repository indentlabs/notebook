# Fix for Ruby 3.2+ with Rails 6.1 and Webpacker
# This resolves: uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger
# Must load before other initializers, hence the 00_ prefix
require 'logger'