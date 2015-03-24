require 'test_helper'

class LocationStoriesTest < ActionDispatch::IntegrationTest
  fixtures :locations
  
  test 'a user can click the locations button from the dashboard to open the locations list' do
    log_in_as_user
    visit dashboard_path
    click_on 'Locations'
    assert_equal location_list_path, current_path
  end
  
  test 'a user can click edit from the locations list to open the location editor' do
    log_in_as_user
    visit location_list_path
    click_on 'Edit'
    assert_equal location_edit_path(locations(:shire)), current_path
  end
  
  test 'a user can click view from the locations list to open the location view' do
    log_in_as_user
    visit location_list_path
    click_on 'View'
    assert_equal location_path(locations(:shire)), current_path
  end
  
  test 'a user can click the edit button from location view to open the location editor' do
    log_in_as_user
    visit location_path(locations(:shire))
    click_on 'Edit'
    assert_equal location_edit_path(locations(:shire)), current_path
  end
  
  test 'a user can create a new location' do
    log_in_as_user
    visit location_list_path
    click_on 'New location'
    fill_in 'location_name', :with => 'Mordor'
    fill_in 'location_universe', :with => 'Middle-Earth'
    click_on 'Create Location'
    assert_equal location_path(Location.where(:name => 'Mordor').first), current_path
  end
  
  test 'a user can upload a map to an existing location' do
    log_in_as_user
    visit location_list_path
    click_on 'Edit'
    click_on 'show_map'
    attach_file 'location_map', 'test/integration/shire_map.jpg'
    click_on 'Update Location'
    assert_equal location_path(locations(:shire)), current_path
  end
end