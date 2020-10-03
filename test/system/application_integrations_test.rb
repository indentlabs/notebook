require "application_system_test_case"

class ApplicationIntegrationsTest < ApplicationSystemTestCase
  setup do
    @application_integration = application_integrations(:one)
  end

  test "visiting the index" do
    visit application_integrations_url
    assert_selector "h1", text: "Application Integrations"
  end

  test "creating a Application integration" do
    visit application_integrations_url
    click_on "New Application Integration"

    click_on "Create Application integration"

    assert_text "Application integration was successfully created"
    click_on "Back"
  end

  test "updating a Application integration" do
    visit application_integrations_url
    click_on "Edit", match: :first

    click_on "Update Application integration"

    assert_text "Application integration was successfully updated"
    click_on "Back"
  end

  test "destroying a Application integration" do
    visit application_integrations_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Application integration was successfully destroyed"
  end
end
