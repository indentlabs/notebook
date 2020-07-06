require "application_system_test_case"

class ShareCommentsTest < ApplicationSystemTestCase
  setup do
    @share_comment = share_comments(:one)
  end

  test "visiting the index" do
    visit share_comments_url
    assert_selector "h1", text: "Share Comments"
  end

  test "creating a Share comment" do
    visit share_comments_url
    click_on "New Share Comment"

    click_on "Create Share comment"

    assert_text "Share comment was successfully created"
    click_on "Back"
  end

  test "updating a Share comment" do
    visit share_comments_url
    click_on "Edit", match: :first

    click_on "Update Share comment"

    assert_text "Share comment was successfully updated"
    click_on "Back"
  end

  test "destroying a Share comment" do
    visit share_comments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Share comment was successfully destroyed"
  end
end
