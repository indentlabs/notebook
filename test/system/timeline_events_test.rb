require "application_system_test_case"

class TimelineEventsTest < ApplicationSystemTestCase
  setup do
    @timeline_event = timeline_events(:one)
  end

  test "visiting the index" do
    visit timeline_events_url
    assert_selector "h1", text: "Timeline Events"
  end

  test "creating a Timeline event" do
    visit timeline_events_url
    click_on "New Timeline Event"

    click_on "Create Timeline event"

    assert_text "Timeline event was successfully created"
    click_on "Back"
  end

  test "updating a Timeline event" do
    visit timeline_events_url
    click_on "Edit", match: :first

    click_on "Update Timeline event"

    assert_text "Timeline event was successfully updated"
    click_on "Back"
  end

  test "destroying a Timeline event" do
    visit timeline_events_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Timeline event was successfully destroyed"
  end
end
