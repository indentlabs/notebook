require "test_helper"

class GalleryCardTest < ActionView::TestCase
  setup do
    @character = characters(:one)
  end

  def render_card(privacy:, pinned: false, cover_for: [])
    upload = ImageUpload.create!(
      user_id: @character.user_id,
      content_type: "Character",
      content_id: @character.id,
      privacy: privacy,
      pinned: pinned,
      cover_for: cover_for
    )
    render partial: "content/edit/gallery/card", locals: { image: upload, content: @character }
    Nokogiri::HTML.fragment(rendered)
  end

  def hidden?(html, target)
    html.at_css("[data-gallery-target='#{target}']")["class"].split.include?("hidden")
  end

  test "public images show no private chip or cover warning" do
    html = render_card(privacy: "public", pinned: true)
    assert hidden?(html, "privacyChip")
    assert hidden?(html, "coverPrivacyWarning")
    assert_nil html.at_css("[data-action='gallery#togglePrivacy']")
  end

  test "private images get a private chip" do
    html = render_card(privacy: "private")
    assert_not hidden?(html, "privacyChip")
    assert hidden?(html, "coverPrivacyWarning")
    assert_equal "true", html.at_css(".gallery-card")["data-supports-privacy"]
  end

  test "a private cover on a public page warns that viewers see a different cover" do
    assert_not hidden?(render_card(privacy: "private", pinned: true), "coverPrivacyWarning")
    assert_not hidden?(render_card(privacy: "private", cover_for: ["banner"]), "coverPrivacyWarning")
  end

  test "a private cover on a private page does not warn" do
    @character.update_columns(privacy: "private", universe_id: nil)
    assert hidden?(render_card(privacy: "private", pinned: true), "coverPrivacyWarning")
  end
end
