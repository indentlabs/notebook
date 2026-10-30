require 'test_helper'

# Privacy changes save on their own, so the modal has to say what's really been saved, and
# closing it can't leave an unsaved choice looking like the real setting.
class DocumentPrivacyStatusTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Rack::Attack.reset!
    @author   = users(:one)
    @document = Document.create!(user: @author, title: 'Mine', body: '<p>Text</p>', privacy: 'public')
    sign_in @author
  end

  # The raw markup, since the HTML parser mangles Alpine's @ attributes
  def privacy_modal
    response.body[/id="document-privacy-modal".*?<script>/m]
  end

  test "the modal's footer has a place to say what was saved" do
    get edit_document_path(@document)

    assert_select '#document-privacy-modal #document-privacy-status[role=status]'
  end

  test "the reading page's modal has it too" do
    get document_path(@document)

    assert_select '#document-privacy-modal #document-privacy-status[role=status]'
  end

  test "no way of closing the modal skips checking for unsaved changes" do
    get edit_document_path(@document)

    assert_not_includes privacy_modal, 'open = false'
    assert_includes privacy_modal, '@click="open = !documentPrivacyCanClose()"'
    assert_includes privacy_modal, '@keydown.escape.window="open = open && !documentPrivacyCanClose()"'
    assert_includes privacy_modal, '@click.away="open = open && !documentPrivacyCanClose()"'
  end

  test "saving an empty password gives a readable error" do
    patch password_document_path(@document), params: { password: '' }, as: :json

    assert_response :unprocessable_entity
    assert_equal 'Password must be at least 5 characters', response.parsed_body['error']
    assert_equal 'public', @document.reload.privacy
  end

  test "saving a short password gives a readable error" do
    patch password_document_path(@document), params: { password: 'abcd' }, as: :json

    assert_response :unprocessable_entity
    assert_equal 'Password must be at least 5 characters', response.parsed_body['error']
  end

  test "saving a long password gives a readable error" do
    patch password_document_path(@document), params: { password: 'x' * 73 }, as: :json

    assert_response :unprocessable_entity
    assert_equal 'Password must be at most 72 characters', response.parsed_body['error']
  end
end
