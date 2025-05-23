ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "logger" # Fix concurrent-ruby removing logger dependency which Rails itself does not have
require 'bundler/setup'  # Set up gems listed in the Gemfile.
# require 'bootsnap/setup' # Speed up boot time by caching expensive operations.