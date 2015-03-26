require 'test_helper'

class CharacterStoriesTest < ActionDispatch::IntegrationTest
  fixtures :characters

  test 'a user can click the characters button from the dashboard to open the characters list' do
    log_in_as_user
    visit dashboard_path
    click_on 'Characters'
    assert_equal character_list_path, current_path
  end

  test 'a user can click edit from the characters list to open the character editor' do
    log_in_as_user
    visit character_list_path
    click_on 'Edit'
    assert_equal character_edit_path(characters(:frodo)), current_path
  end

  test 'a user can click view from the characters list to open the character view' do
    log_in_as_user
    visit character_list_path
    click_on 'View'
    assert_equal character_path(characters(:frodo)), current_path
  end

  test 'a user can click the edit button from character view to open the character editor' do
    log_in_as_user
    visit character_path(characters(:frodo))
    click_on 'Edit'
    assert_equal character_edit_path(characters(:frodo)), current_path
  end
end
