require 'test_helper'

# Tests for the Serendipitous cards on content pages
class SerendipitousCardTest < ActionDispatch::IntegrationTest
  test 'changing character info' do
    @user = log_in_as_user
    @character = create(:character, user: @user)
    @character.save

    visit character_path(@character)

    modified_field_name = find(:css, '.content-question-input')[:id].split('_', 2)[1]
    @character[modified_field_name] = 'Previous Value'
    @character.save
    previous_field_value = @character[modified_field_name]

    find(:css, '.content-question-input').set('Content Question Answer')
    find('.content-question-submit').click

    # We can't use @character.changed? because after the form is submitted,
    # the changes were saved.

    @character.reload
    assert_equal 'Content Question Answer', @character[modified_field_name],
                 "expected field #{modified_field_name} to change from '#{previous_field_value}' to 'Content Question Answer', but it was '#{@character[modified_field_name]}'"
  end
end
