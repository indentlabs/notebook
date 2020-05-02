require "application_system_test_case"

class PageCollectionSubmissionsTest < ApplicationSystemTestCase
  setup do
    @page_collection_submission = page_collection_submissions(:one)
  end

  test "visiting the index" do
    visit page_collection_submissions_url
    assert_selector "h1", text: "Page Collection Submissions"
  end

  test "creating a Page collection submission" do
    visit page_collection_submissions_url
    click_on "New Page Collection Submission"

    click_on "Create Page collection submission"

    assert_text "Page collection submission was successfully created"
    click_on "Back"
  end

  test "updating a Page collection submission" do
    visit page_collection_submissions_url
    click_on "Edit", match: :first

    click_on "Update Page collection submission"

    assert_text "Page collection submission was successfully updated"
    click_on "Back"
  end

  test "destroying a Page collection submission" do
    visit page_collection_submissions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Page collection submission was successfully destroyed"
  end
end
