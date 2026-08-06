require 'test_helper'

# Regression coverage for content#show tab navigation:
# - the tab hash whitelist only includes universe-only views (in_this_universe,
#   documents, books) on Universe pages, and never the edit-page 'details' key
# - the Timelines tab empty state links to the routed /plan/timelines paths
class ContentShowTabNavigationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "universe show page whitelists universe-only tab hashes" do
    universe = Universe.create!(name: 'Test Universe', user: @user, privacy: 'private')

    get "/plan/universes/#{universe.id}"
    assert_response :success
    assert_includes response.body, "validViews.push('in_this_universe', 'documents', 'books')"
    refute_includes response.body, "'details'"
  end

  test "character show page omits universe-only tab hashes and links timelines correctly" do
    character = Character.create!(name: 'Test Character', user: @user, privacy: 'private')

    get "/plan/characters/#{character.id}"
    assert_response :success
    refute_includes response.body, "validViews.push('in_this_universe'"
    refute_includes response.body, "'details'"

    # Timelines tab empty state: routed paths, not the old dead "/timelines" links
    assert_includes response.body, 'href="/plan/timelines"'
    refute_match %r{href="/timelines"}, response.body
    refute_match %r{href="/timelines/new"}, response.body
  end
end
