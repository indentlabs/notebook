require 'test_helper'

# Tests scenarios related to interacting with Characters
class CharacterStoriesTest < ActionDispatch::IntegrationTest
  fixtures :characters

  test 'characters button shows characters list' do
    log_in_as_user
    visit dashboard_path
    click_on 'Characters'
    assert_equal characters_path, current_path
  end

  test 'character list edit button edits character' do
    log_in_as_user
    visit characters_path
    click_on 'Edit'
    assert_equal edit_character_path(characters(:frodo)), current_path
  end

  test 'view button shows character list' do
    log_in_as_user
    visit characters_path
    click_on 'View'
    assert_equal character_path(characters(:frodo)), current_path
  end

  test 'character view edit button edits character' do
    log_in_as_user
    visit character_path(characters(:frodo))
    click_on 'Edit'
    assert_equal edit_character_path(characters(:frodo)), current_path
  end
  
  test 'a user can create a new character' do
    log_in_as_user
    visit characters_path
    click_on 'Create another character'
    fill_in 'character_name', with: 'Elrond'
    fill_in 'character_universe', with: 'Middle-Earth'
    click_on 'Create Character'

    assert_equal character_path(Character.where(name: 'Elrond').first),
                 current_path
  end
end
