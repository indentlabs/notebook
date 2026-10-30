require 'test_helper'

# Authors change a document's privacy from the edit page, whose address isn't the one
# readers need, so the privacy modal shows them the link to send.
class DocumentShareLinkTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD = 'correct horse'

  setup do
    @author = users(:one)
    sign_in @author
  end

  def document_with(privacy)
    Document.create!(user: @author, title: 'Mine', body: '<p>Text</p>', privacy: 'private').tap do |document|
      document.protect_with_password(PASSWORD) if privacy == 'password'
      document.update!(privacy: privacy) if privacy == 'public'
    end
  end

  test "a public document shows the reading link on the edit page" do
    document = document_with('public')

    get edit_document_path(document)

    assert_response :success
    assert_select '#document-share-link:not(.hidden)'
    assert_select 'input#document-share-link-url[readonly][value=?]', document_url(document)
  end

  test "a password protected document shows the link" do
    document = document_with('password')

    get edit_document_path(document)

    assert_select '#document-share-link:not(.hidden)'
    assert_select 'input#document-share-link-url[value=?]', document_url(document)
  end

  test "a private document keeps the box ready but hidden, since the link wouldn't open for anyone else" do
    document = document_with('private')

    get edit_document_path(document)

    assert_select '#document-share-link.hidden'
    assert_select 'input#document-share-link-url[value=?]', document_url(document)
  end

  test "the link isn't sent with any form" do
    document = document_with('public')

    get edit_document_path(document)

    assert_select 'input#document-share-link-url:not([name])'
    assert_select 'form input#document-share-link-url', count: 0
  end

  test "the author sees it on the reading page too" do
    document = document_with('public')

    get document_path(document)

    assert_select '#document-share-link:not(.hidden)'
    assert_select 'input#document-share-link-url[value=?]', document_url(document)
  end
end
