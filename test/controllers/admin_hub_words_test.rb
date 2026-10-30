require 'test_helper'
require 'minitest/mock'

class AdminHubWordsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "hub shows community words written from the precomputed stats" do
    Rails.cache.clear
    CommunityDailyStat.create!(date: Date.current, metric: 'words', key: 'Documents', value: 4_321)
    user = users(:one)
    user.update_columns(site_administrator: true)
    sign_in user

    # The hub also shows Sidekiq stats, which would need a live Redis
    sidekiq_stats = Struct.new(:enqueued, :processed, :failed).new(0, 0, 0)
    Sidekiq::Stats.stub(:new, sidekiq_stats) { get admin_hub_path }
    assert_response :success
    assert_includes response.body, '4,321'
  ensure
    Rails.cache.clear
  end
end
