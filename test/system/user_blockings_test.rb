require "application_system_test_case"

class UserBlockingsTest < ApplicationSystemTestCase
  setup do
    @user_blocking = user_blockings(:one)
  end

  test "visiting the index" do
    visit user_blockings_url
    assert_selector "h1", text: "User Blockings"
  end

  test "creating a User blocking" do
    visit user_blockings_url
    click_on "New User Blocking"

    click_on "Create User blocking"

    assert_text "User blocking was successfully created"
    click_on "Back"
  end

  test "updating a User blocking" do
    visit user_blockings_url
    click_on "Edit", match: :first

    click_on "Update User blocking"

    assert_text "User blocking was successfully updated"
    click_on "Back"
  end

  test "destroying a User blocking" do
    visit user_blockings_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "User blocking was successfully destroyed"
  end
end
