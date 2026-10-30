require "application_system_test_case"

class ContentPageSharesTest < ApplicationSystemTestCase
  setup do
    @content_page_share = content_page_shares(:one)
  end

  test "visiting the index" do
    visit content_page_shares_url
    assert_selector "h1", text: "Content Page Shares"
  end

  test "creating a Content page share" do
    visit content_page_shares_url
    click_on "New Content Page Share"

    click_on "Create Content page share"

    assert_text "Thanks for sharing!"
    click_on "Back"
  end

  test "updating a Content page share" do
    visit content_page_shares_url
    click_on "Edit", match: :first

    click_on "Update Content page share"

    assert_text "Content page share was successfully updated"
    click_on "Back"
  end

  test "destroying a Content page share" do
    visit content_page_shares_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Content page share was successfully destroyed"
  end
end
