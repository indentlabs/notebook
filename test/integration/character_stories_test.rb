require 'test_helper'

# Tests scenarios related to interacting with Characters
class CharacterStoriesTest < ActionDispatch::IntegrationTest
  fixtures :characters

  test 'characters button shows characters list' do
    log_in_as_user
    visit dashboard_path
    click_on 'Characters'
    assert_equal character_list_path, current_path
  end

  test 'character list edit button edits character' do
    log_in_as_user
    visit character_list_path
    click_on 'Edit'
    assert_equal character_edit_path(characters(:frodo)), current_path
  end

  test 'view button shows character list' do
    log_in_as_user
    visit character_list_path
    click_on 'View'
    assert_equal character_path(characters(:frodo)), current_path
  end

  test 'character view edit button edits character' do
    log_in_as_user
    visit character_path(characters(:frodo))
    click_on 'Edit'
    assert_equal character_edit_path(characters(:frodo)), current_path
  end
end
