require "application_system_test_case"

class TimelinesTest < ApplicationSystemTestCase
  setup do
    @timeline = timelines(:one)
  end

  test "visiting the index" do
    visit timelines_url
    assert_selector "h1", text: "Timelines"
  end

  test "creating a Timeline" do
    visit timelines_url
    click_on "New Timeline"

    click_on "Create Timeline"

    assert_text "Timeline was successfully created"
    click_on "Back"
  end

  test "updating a Timeline" do
    visit timelines_url
    click_on "Edit", match: :first

    click_on "Update Timeline"

    assert_text "Timeline was successfully updated"
    click_on "Back"
  end

  test "destroying a Timeline" do
    visit timelines_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Timeline was successfully destroyed"
  end
end
