require 'test_helper'

# Tests scenarios related to interacting with Universes
class UniverseStoriesTest < ActionDispatch::IntegrationTest
  setup do
    @user = log_in_as_user
    @universe = create(:universe, user: @user)
  end

  test 'universe is displayed on universes list' do
    visit universes_path
    assert page.has_content?(@universe.name),
           "Page body didn't contain universe name: "\
           "#{@universe.name} not found in \n#{page.body}"
  end

  test 'universe list edit button edits universe' do
    visit universe_path(@universe)
    click_on 'Edit this universe'
    assert_equal edit_universe_path(@universe), current_path
  end

  test 'universe list view button shows universe' do
    visit universes_path
    within(:css, '.collection-item:first') do
      click_on @universe.name
    end
    assert_equal universe_path(@universe), current_path,
                 "Not on universe path for universe #{@universe.name}: "\
                 "#{@universe.name} not found in \n#{page.body}"
  end

  test 'a user can create a new universe' do
    new_universe = build(:universe)
    visit universes_path
    click_on 'Create another universe'
    fill_in 'universe_name', with: new_universe.name
    click_on 'Create Universe'

    assert_equal universe_path(Universe.where(name: new_universe.name).first),
                 current_path
  end
end
