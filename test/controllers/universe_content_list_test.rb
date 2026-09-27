require 'test_helper'

class UniverseContentListTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @universe = Universe.create!(user: @user, name: 'Listed Universe', privacy: 'public')
    Location.create!(user: @user, name: 'Public Location', privacy: 'public', universe: @universe)
  end

  test "renders a universe's content list for a signed-out visitor" do
    get locations_universe_path(@universe)

    assert_response :success
    assert_match 'Public Location', response.body
    assert_match 'Back to Listed Universe Hub', response.body
  end

  test "renders a universe's content list for its owner" do
    sign_in @user

    get characters_universe_path(@universe)

    assert_response :success
    assert_match 'Back to Listed Universe Hub', response.body
  end
end
