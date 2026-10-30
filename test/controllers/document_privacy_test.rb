require 'test_helper'

# Every route out of a document that isn't the document page itself. A private document's
# title and text shouldn't be reachable through any of them.
class DocumentPrivacyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET_TITLE = 'SECRETTITLE'
  SECRET_BODY  = 'SECRETBODYTEXT'

  setup do
    @author   = users(:one)
    @stranger = users(:two)
    @document = Document.create!(user: @author, title: SECRET_TITLE, body: "<p>#{SECRET_BODY} live</p>", privacy: 'private')
    @revision = @document.document_revisions.create!(title: SECRET_TITLE, body: "<p>#{SECRET_BODY} revision</p>", cached_word_count: 2)
    # Fixture shares point at nothing, which the feed can't render
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_TITLE
    assert_not_includes response.body, SECRET_BODY
  end

  test "revisions are not available to anonymous visitors" do
    get document_document_revisions_path(@document)
    assert_redirected_to new_user_session_path

    get document_document_revision_path(@document, @revision)
    assert_redirected_to new_user_session_path

    get diff_document_document_revision_path(@document, @revision)
    assert_redirected_to new_user_session_path
  end

  test "revisions are not available to other users" do
    sign_in @stranger

    get document_document_revisions_path(@document)
    assert_no_secrets

    get document_document_revision_path(@document, @revision)
    assert_no_secrets

    get diff_document_document_revision_path(@document, @revision)
    assert_no_secrets
  end

  test "revisions of a public document are still only for its author" do
    @document.update!(privacy: 'public')
    sign_in @stranger

    get document_document_revisions_path(@document)
    assert_no_secrets
  end

  test "only the author can restore a revision" do
    post restore_document_document_revision_path(@document, @revision)
    assert_includes @document.reload.body, 'live'

    sign_in @stranger
    post restore_document_document_revision_path(@document, @revision)
    assert_includes @document.reload.body, 'live'
  end

  test "only the author can delete a revision" do
    delete document_document_revision_path(@document, @revision)
    assert DocumentRevision.exists?(@revision.id)

    sign_in @stranger
    delete document_document_revision_path(@document, @revision)
    assert DocumentRevision.exists?(@revision.id)
  end

  test "a revision can't be reached through another document" do
    other_document = Document.create!(user: @stranger, title: 'Mine', privacy: 'private')
    sign_in @stranger

    assert_raises(ActiveRecord::RecordNotFound) do
      get document_document_revision_path(other_document, @revision)
    end
  end

  test "authors can still use their revisions" do
    sign_in @author

    get document_document_revisions_path(@document)
    assert_response :success

    get diff_document_document_revision_path(@document, @revision)
    assert_response :success
    assert_includes response.body, SECRET_BODY

    post restore_document_document_revision_path(@document, @revision)
    assert_includes @document.reload.body, 'revision'
  end

  test "sharing someone else's private document doesn't publish it" do
    sign_in @stranger

    assert_no_difference 'ContentPageShare.count' do
      post user_content_page_shares_path(@stranger), params: { content_page_share: { content_page: "Document-#{@document.id}", message: 'hi' } }
    end

    assert_equal 'private', @document.reload.privacy
  end

  test "sharing your own private document still publishes it" do
    sign_in @author

    assert_difference 'ContentPageShare.count', 1 do
      post user_content_page_shares_path(@author), params: { content_page_share: { content_page: "Document-#{@document.id}", message: 'hi' } }
    end

    assert_equal 'public', @document.reload.privacy
  end

  test "sharing someone else's public document still works" do
    @document.update!(privacy: 'public')
    sign_in @stranger

    assert_difference 'ContentPageShare.count', 1 do
      post user_content_page_shares_path(@stranger), params: { content_page_share: { content_page: "Document-#{@document.id}", message: 'hi' } }
    end
  end

  test "sharing rejects things that aren't pages" do
    sign_in @stranger

    assert_no_difference 'ContentPageShare.count' do
      post user_content_page_shares_path(@stranger), params: { content_page_share: { content_page: "User-#{@author.id}", message: 'hi' } }
    end
  end

  test "a share can't be repointed at someone else's private document" do
    public_document = Document.create!(user: @stranger, title: 'Mine', privacy: 'public')
    share = ContentPageShare.create!(user: @stranger, content_page: public_document, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    patch user_content_page_share_path(@stranger, share), params: { content_page_share: { content_page: "Document-#{@document.id}", message: 'hi' } }

    assert_equal public_document.id, share.reload.content_page_id
  end

  test "someone else's share can't be edited" do
    share = ContentPageShare.create!(user: @author, content_page: @document, message: 'original', shared_at: DateTime.current)
    public_document = Document.create!(user: @stranger, title: 'Mine', privacy: 'public')
    sign_in @stranger

    patch user_content_page_share_path(@author, share), params: { content_page_share: { content_page: "Document-#{public_document.id}", message: 'stolen' } }

    assert_equal 'original', share.reload.message
    assert_equal @author.id, share.user_id
  end

  test "submitting someone else's private page to a collection doesn't publish it" do
    character  = Character.create!(user: @author, name: 'Private Person', privacy: 'private')
    collection = PageCollection.create!(user: @stranger, title: 'Mine', privacy: 'public')
    sign_in @stranger

    assert_no_difference 'PageCollectionSubmission.count' do
      post page_collection_submissions_path, params: { page_collection_submission: { content: "Character-#{character.id}", page_collection_id: collection.id } }
    end

    assert_equal 'private', character.reload.privacy
  end

  test "submitting your own private page to a public collection still publishes it" do
    character  = Character.create!(user: @author, name: 'My Person', privacy: 'private')
    collection = PageCollection.create!(user: @stranger, title: 'Theirs', privacy: 'public', page_types: ['Character'], allow_submissions: true)
    sign_in @author

    assert_difference 'PageCollectionSubmission.count', 1 do
      post page_collection_submissions_path, params: { page_collection_submission: { content: "Character-#{character.id}", page_collection_id: collection.id } }
    end

    assert_equal 'public', character.reload.privacy
  end

  test "documents can't be submitted to collections" do
    collection = PageCollection.create!(user: @author, title: 'Mine', privacy: 'public')
    sign_in @author

    assert_no_difference 'PageCollectionSubmission.count' do
      post page_collection_submissions_path, params: { page_collection_submission: { content: "Document-#{@document.id}", page_collection_id: collection.id } }
    end

    assert_equal 'private', @document.reload.privacy
  end

  test "documents already in a collection aren't shown by it" do
    collection = PageCollection.create!(user: @author, title: 'Mine', privacy: 'public')
    submission = PageCollectionSubmission.new(content: @document, page_collection: collection, user: @author, accepted_at: DateTime.current, submitted_at: DateTime.current)
    submission.save!(validate: false)

    assert_not_includes collection.accepted_submissions, submission

    get page_collection_path(collection)
    assert_no_secrets
  end

  test "the stream hides the preview of a shared document that has gone private" do
    ContentPageShare.create!(user: @author, content_page: @document, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path

    assert_response :success
    assert_no_secrets
    assert_includes response.body, 'no longer public'
  end

  test "the stream still previews a shared public document" do
    @document.update!(privacy: 'public')
    ContentPageShare.create!(user: @author, content_page: @document, message: 'hi', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path

    assert_includes response.body, SECRET_TITLE
    assert_includes response.body, SECRET_BODY
  end

  test "the share page hides the preview of a shared document that has gone private" do
    share = ContentPageShare.create!(user: @author, content_page: @document, message: 'hi', shared_at: DateTime.current)

    get user_content_page_share_path(@author, share)

    assert_response :success
    assert_no_secrets
  end

  test "another share's page doesn't list a shared document that has gone private" do
    ContentPageShare.create!(user: @author, content_page: @document, message: 'first', shared_at: DateTime.current)
    public_document = Document.create!(user: @author, title: 'Public one', privacy: 'public')
    other_share = ContentPageShare.create!(user: @author, content_page: public_document, message: 'second', shared_at: DateTime.current)

    get user_content_page_share_path(@author, other_share)

    assert_response :success
    assert_no_secrets
  end

  test "the name lookup hides titles the viewer can't read" do
    get "/api/internal/Document/#{@document.id}/name"
    assert_equal 'Page not found', response.body

    sign_in @stranger
    get "/api/internal/Document/#{@document.id}/name"
    assert_equal 'Page not found', response.body
  end

  test "the name lookup still works for the author and for other page types" do
    character = Character.create!(user: @author, name: 'Named Person', privacy: 'private')
    sign_in @author

    get "/api/internal/Document/#{@document.id}/name"
    assert_equal SECRET_TITLE, response.body

    get "/api/internal/Character/#{character.id}/name"
    assert_equal 'Named Person', response.body
  end

  test "content links hide the title of a document the viewer can't read" do
    token = "[[Document-#{@document.id}]]"

    assert_not_includes ContentFormatterService.show(text: token, viewing_user: User.new), SECRET_TITLE
    assert_not_includes ContentFormatterService.show(text: token, viewing_user: @stranger), SECRET_TITLE
    assert_not_includes ContentFormatterService.plaintext_show(text: token.dup, viewing_user: @stranger), SECRET_TITLE
  end

  test "content links still show the title to the author" do
    assert_includes ContentFormatterService.show(text: "[[Document-#{@document.id}]]", viewing_user: @author), SECRET_TITLE
  end

  test "a public page doesn't mention private documents" do
    character = mentioned_character

    get character_path(character)

    assert_response :success
    assert_no_secrets
  end

  test "a public page still mentions public documents and the viewer's own" do
    character = mentioned_character

    sign_in @author
    get character_path(character)
    assert_includes response.body, SECRET_TITLE
    sign_out @author

    @document.update!(privacy: 'public')
    get character_path(character)
    assert_includes response.body, SECRET_TITLE
  end

  test "the references page doesn't list private documents" do
    character = mentioned_character
    sign_in @stranger

    get references_character_path(character)

    assert_response :success
    assert_no_secrets
  end

  test "the references page still lists public documents" do
    character = mentioned_character
    @document.update!(privacy: 'public')
    sign_in @stranger

    get references_character_path(character)

    assert_includes response.body, SECRET_TITLE
  end

  test "an unclaimed contributor invite doesn't open a universe's documents to everyone" do
    universe = Universe.create!(user: @author, name: 'Private universe', privacy: 'private')
    Contributor.create!(universe: universe, email: 'invited@example.com')
    @document.update!(universe: universe)

    assert_not User.new.can_read?(@document)
    assert_not @stranger.can_read?(@document)

    get document_path(@document)
    assert_no_secrets
  end

  private

  def mentioned_character
    character = Character.create!(user: @author, name: 'Mentioned Person', privacy: 'public')
    analysis  = @document.document_analysis.create!
    analysis.document_entities.create!(entity_type: 'Character', entity_id: character.id, text: 'Mentioned Person')
    character
  end
end
