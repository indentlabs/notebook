require 'test_helper'

class DocumentEditorWordsmithTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "document editor includes the Wordsmith panel" do
    user = users(:one)
    document = Document.create!(title: 'Draft', body: '<p>She ran constantly.</p>', user: user)

    sign_in user
    get edit_document_path(document)

    assert_response :success
    assert_select '[data-tooltip="Wordsmith"]', 2 # desktop + mobile toggle tabs
    assert_equal 2, response.body.scan('Find the right word').size # panel in desktop + mobile sidebars
  end
end
