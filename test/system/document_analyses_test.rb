require "application_system_test_case"

class DocumentAnalysesTest < ApplicationSystemTestCase
  setup do
    @document_analysis = document_analyses(:one)
  end

  test "visiting the index" do
    visit document_analyses_url
    assert_selector "h1", text: "Document Analyses"
  end

  test "creating a Document analysis" do
    visit document_analyses_url
    click_on "New Document Analysis"

    click_on "Create Document analysis"

    assert_text "Document analysis was successfully created"
    click_on "Back"
  end

  test "updating a Document analysis" do
    visit document_analyses_url
    click_on "Edit", match: :first

    click_on "Update Document analysis"

    assert_text "Document analysis was successfully updated"
    click_on "Back"
  end

  test "destroying a Document analysis" do
    visit document_analyses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Document analysis was successfully destroyed"
  end
end
