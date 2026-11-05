require 'test_helper'

# The help center's privacy guide, and the pages that point to it.
class HelpPrivacyPagesTest < ActionDispatch::IntegrationTest
  test "the privacy guide is public and covers every setting" do
    get help_privacy_and_sharing_path

    assert_response :success
    %w[privacy-settings universes-and-books password-protection collaborators where-public-content-appears
       automatic-publishing images private-notes profile].each do |section|
      assert_select "section##{section}"
    end
    assert_includes response.body, 'Password protected'
  end

  test "the help center links to it" do
    get help_center_path

    assert_select "a[href=?]", help_privacy_and_sharing_path
  end

  test "the getting started guide only offers settings that exist" do
    get help_your_first_universe_path

    assert_not_includes response.body, 'Collaborators Only'
    assert_includes response.body, 'Password protected'
    assert_select "a[href=?]", help_privacy_and_sharing_path
  end

  test "troubleshooting has a privacy section that its links point to" do
    get help_troubleshooting_path

    assert_select 'section#privacy'
    assert_select 'a[href="#privacy"]'
  end

  test "the guide's links to other help pages land on real sections" do
    get help_organizing_with_universes_path
    assert_select 'section#collaboration'

    get help_privacy_and_sharing_path
    assert_select "a[href=?]", help_troubleshooting_path(anchor: 'privacy')
    assert_select "a[href=?]", help_organizing_with_universes_path(anchor: 'collaboration')
  end
end
