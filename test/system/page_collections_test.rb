require "application_system_test_case"

class PageCollectionsTest < ApplicationSystemTestCase
  setup do
    @page_collection = page_collections(:one)
  end

  test "visiting the index" do
    visit page_collections_url
    assert_selector "h1", text: "Page Collections"
  end

  test "creating a Page collection" do
    visit page_collections_url
    click_on "New Page Collection"

    click_on "Create Page collection"

    assert_text "Page collection was successfully created"
    click_on "Back"
  end

  test "updating a Page collection" do
    visit page_collections_url
    click_on "Edit", match: :first

    click_on "Update Page collection"

    assert_text "Page collection was successfully updated"
    click_on "Back"
  end

  test "destroying a Page collection" do
    visit page_collections_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Page collection was successfully destroyed"
  end
end
