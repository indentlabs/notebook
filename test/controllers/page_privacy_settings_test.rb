require 'test_helper'

# The privacy picker on a page's edit and show pages, now with password protection.
class PagePrivacySettingsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD = 'correct horse'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    @page     = Character.create!(user: @owner, name: 'My character', privacy: 'private')
  end

  def privacy_state
    JSON.parse(css_select('#page-privacy-settings').first['x-data'][/\((.*)\)\z/m, 1])
  end

  test "the edit page offers password protection to the owner" do
    sign_in @owner

    get edit_character_path(@page)

    assert_response :success
    assert_select '#page-privacy-password'
    assert_select '#page-password-input'
    assert_select '#page-password-input[name]', count: 0
    assert_select 'form #page-password-input', count: 0
    assert_equal password_character_path(@page), privacy_state['passwordUrl']
    assert_equal true, privacy_state['canManagePassword']
    assert_equal 'private', privacy_state['selectedPrivacy']
  end

  test "the show page's privacy view offers it too" do
    sign_in @owner

    get character_path(@page)

    assert_select '#page-privacy-password'
    assert_select '#page-password-input'
  end

  test "a protected page shows its state and the link to share" do
    @page.protect_with_password(PASSWORD)
    sign_in @owner

    get edit_character_path(@page)

    assert_equal 'password', privacy_state['selectedPrivacy']
    assert_select '#page-privacy-password[checked]'
    assert_select '#page-share-link-url[value=?]', character_url(@page)
    assert_not_includes response.body, @page.reload.page_password.password_digest
  end

  test "universes can be protected from their own settings" do
    universe = Universe.create!(user: @owner, name: 'My universe', privacy: 'private')
    sign_in @owner

    get edit_universe_path(universe)

    assert_select '#page-privacy-password'
    assert_equal password_universe_path(universe), privacy_state['passwordUrl']
  end

  test "collaborators see the setting but can't manage the password" do
    universe = Universe.create!(user: @owner, name: 'Shared universe', privacy: 'private')
    contributor = User.create!(name: 'Contributor', email: 'contributor@example.com', password: 'password123')
    Contributor.create!(universe: universe, user: contributor)
    @page.update!(universe: universe)
    @page.protect_with_password(PASSWORD)
    sign_in contributor

    get edit_character_path(@page)

    assert_response :success
    assert_equal false, privacy_state['canManagePassword']
    assert_select '#page-password-input', count: 0
    assert_includes CGI.unescapeHTML(response.body), "Only this page's owner can change the password"
  end

  test "readers who aren't editors don't get the privacy settings at all" do
    @page.update!(privacy: 'public')

    get character_path(@page)
    assert_select '#page-privacy-settings', count: 0

    @page.protect_with_password(PASSWORD)
    post unlock_character_path(@page), params: { password: PASSWORD }
    get character_path(@page)
    assert_select '#page-privacy-settings', count: 0
  end

  test "a password protected universe is labelled as one on its pages" do
    universe = Universe.create!(user: @owner, name: 'Locked universe', privacy: 'private')
    universe.protect_with_password(PASSWORD)
    @page.update!(universe: universe)
    sign_in @owner

    get edit_character_path(@page)

    assert_includes CGI.unescapeHTML(response.body), "The universe's password only opens the universe's own page"
    assert_equal 'password', privacy_state['universePrivacy']
  end

  test "the sidebars show the protected label" do
    @page.protect_with_password(PASSWORD)
    sign_in @owner

    get character_path(@page)
    assert_select 'button[title="Click to manage privacy settings"]', text: /Password protected/

    get edit_character_path(@page)
    assert_select 'button', text: /vpn_key\s*Privacy & Sharing/
  end

  test "a document's universe tab doesn't offer to flip a protected universe" do
    universe = Universe.create!(user: @owner, name: 'Locked universe', privacy: 'private')
    universe.protect_with_password(PASSWORD)
    document = Document.create!(user: @owner, universe: universe, title: 'Chapter', privacy: 'private')
    sign_in @owner

    get edit_document_path(document)

    assert_response :success
    assert_select '#universe-privacy-form', count: 0
    assert_includes response.body, 'Password protected'
  end

  test "protected pages aren't offered for collection submissions" do
    collection = PageCollection.create!(user: @stranger, title: 'Open', privacy: 'public', page_types: ['Character'], allow_submissions: true)
    @page.protect_with_password(PASSWORD)
    other = Character.create!(user: @owner, name: 'Submittable', privacy: 'public')
    UserContentTypeActivator.create!(user: @owner, content_type: 'Character')
    sign_in @owner

    get page_collection_path(collection)

    assert_response :success
    assert_select "option[value=?]", "Character-#{other.id}"
    assert_select "option[value=?]", "Character-#{@page.id}", count: 0
  end
end
