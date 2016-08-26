require 'test_helper'

# Tests scenarios related to interacting with Locations
class LocationStoriesTest < ActionDispatch::IntegrationTest

  setup do
    @user = log_in_as_user
    @location = create(:location, user: @user)
  end

  test 'location is displayed on locations list' do
    visit locations_path
    assert page.has_content?(@location.name),
      "Page body didn't contain location name: "\
      "#{@location.name} not found in \n#{page.body}"
  end

  test 'location list edit button edits location' do
    visit location_path(@location)
    click_on 'Edit this location'
    assert_equal edit_location_path(@location), current_path
  end

  test 'location list view button shows location' do
    visit locations_path
    within(:css, ".collection-item:first") do
      click_on @location.name
    end
    assert_equal location_path(@location), current_path,
      "Not on location path for location #{@location.name}: "\
      "#{@location.name} not found in \n#{page.body}"
  end

  test 'a user can create a new location' do
    new_location = build(:location)
    visit locations_path
    click_on 'Create another location'
    fill_in 'location_name', with: new_location.name
    click_on 'Create Location'

    assert_equal location_path(Location.where(name: new_location.name).first),
                 current_path
  end
end
