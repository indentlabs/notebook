require 'test_helper'

# Tests for the Serendipitous cards on content pages
class SerendipitousCardTest < ActionDispatch::IntegrationTest
  test 'changing character info' do
    @user = log_in_as_user
    @character = create(:character, user: @user)
    @character.save

    visit character_path(@character)
    modified_field_name = find(:css, '.content-question-input')[:id].split('_', 2)[1]

    find(:css, '.content-question-input').set('Content Question Answer')
    find(:css, '.content-question-submit').click

    assert @character.changed?,
           'Character was not changed when Serendipitous question was answered'
    assert_includes @character.previous_changes, modified_field_name,
                    "Answered a Serendipitous question about #{modified_field_name}, but #{@character.previous_changes} was changed"
  end
end
