require 'test_helper'

class ContentControllerDestroyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @character = characters(:one)
    sign_in @user
  end

  test "deleting your own page soft-deletes it" do
    delete character_path(@character)

    assert_redirected_to characters_path
    assert_nil Character.find_by(id: @character.id)
  end

  test "deleting an already-deleted page redirects instead of erroring" do
    @character.destroy

    delete character_path(@character)

    assert_redirected_to characters_path
    assert_equal "That page doesn't exist or has already been deleted.", flash[:notice]
  end

  test "deleting a page that never existed redirects instead of erroring" do
    delete character_path(id: 999_999_999)

    assert_redirected_to characters_path
  end

  test "deleting someone else's page is refused" do
    other = characters(:two)

    delete character_path(other), headers: { 'HTTP_REFERER' => "http://www.example.com#{character_path(other)}" }

    assert_response :redirect
    assert_equal character_path(other), URI(response.location).path
    assert_equal "You don't have permission to do that!", flash[:notice]
    assert Character.find_by(id: other.id).present?
  end

  test "the edit page's delete button only submits once" do
    get edit_character_path(@character)

    assert_response :success
    assert_includes response.body, "if (deleting) return;"
  end
end
