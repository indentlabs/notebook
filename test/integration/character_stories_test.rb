require 'test_helper'

# Tests scenarios related to interacting with Characters
class CharacterStoriesTest < ActionDispatch::IntegrationTest
  
  setup do
    @user = log_in_as_user
  end
  
  test 'a user can create a new character' do
    character = build(:character)
    visit new_character_path
    fill_in 'character_name', with: character.name
    fill_in 'character_universe_id', with: character.universe
    click_on 'Create Character'

    assert_equal character_path(Character.where(name: character.name).first), current_path
  end
end
