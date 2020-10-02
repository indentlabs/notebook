require "application_system_test_case"

class DocumentRevisionsTest < ApplicationSystemTestCase
  setup do
    @document_revision = document_revisions(:one)
  end

  test "visiting the index" do
    visit document_revisions_url
    assert_selector "h1", text: "Document Revisions"
  end

  test "creating a Document revision" do
    visit document_revisions_url
    click_on "New Document Revision"

    click_on "Create Document revision"

    assert_text "Document revision was successfully created"
    click_on "Back"
  end

  test "updating a Document revision" do
    visit document_revisions_url
    click_on "Edit", match: :first

    click_on "Update Document revision"

    assert_text "Document revision was successfully updated"
    click_on "Back"
  end

  test "destroying a Document revision" do
    visit document_revisions_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Document revision was successfully destroyed"
  end
end
