require 'test_helper'

# Linking a page to a document shows the page's details in the document,
# so a writer can only link pages they can read.
class DocumentLinkAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET = 'SECRETTEXT'

  setup do
    @victim   = users(:one)
    @attacker = users(:two)
    @document = Document.create!(user: @attacker, title: 'Mine', body: 'text')
    sign_in @attacker
  end

  def link(entity_type, entity_id, document_entity_id: -1, document_analysis_id: -1)
    post '/documents/link_entity.json', params: {
      entity_type: entity_type, entity_id: entity_id, document_id: @document.id,
      document_entity_id: document_entity_id, document_analysis_id: document_analysis_id
    }
  end

  test "nobody can read a private document by linking it" do
    secret = Document.create!(user: @victim, title: SECRET, body: "<p>#{SECRET}</p>", privacy: 'private')

    link('Document', secret.id)

    assert_response :forbidden
    assert_not_includes response.body, SECRET
    assert_not DocumentEntity.exists?(entity_type: 'Document', entity_id: secret.id)
  end

  test "nobody can read a private page by linking it" do
    secret = Character.create!(user: @victim, name: SECRET, privacy: 'private')

    link('Character', secret.id)

    assert_response :forbidden
    assert_not_includes response.body, SECRET
    assert_not DocumentEntity.exists?(entity_type: 'Character', entity_id: secret.id)
  end

  test "nobody can repoint an existing link at a private page" do
    mine   = Character.create!(user: @attacker, name: 'Mine', privacy: 'private')
    secret = Character.create!(user: @victim, name: SECRET, privacy: 'private')
    link('Character', mine.id)
    linked = DocumentEntity.find_by(entity_type: 'Character', entity_id: mine.id)

    link('Character', secret.id, document_entity_id: linked.id, document_analysis_id: linked.document_analysis_id)

    assert_response :forbidden
    assert_equal mine.id, linked.reload.entity_id
  end

  test "writers can link their own pages and public ones" do
    mine   = Character.create!(user: @attacker, name: 'Mine', privacy: 'private')
    public = Character.create!(user: @victim, name: 'Public', privacy: 'public')

    link('Character', mine.id)
    assert_response :success
    assert DocumentEntity.exists?(entity_type: 'Character', entity_id: mine.id)

    link('Character', public.id)
    assert_response :success
    assert DocumentEntity.exists?(entity_type: 'Character', entity_id: public.id)
  end
end
