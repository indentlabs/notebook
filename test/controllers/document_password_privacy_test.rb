require 'test_helper'

# Walks every surface that can show a document, with a password protected one. Nothing
# here has entered the password, so all of them should treat it like a private document,
# including the ones where a public universe or book would normally open it up.
class DocumentPasswordPrivacyTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD     = 'correct horse'
  SECRET_TITLE = 'SECRETTITLE'
  SECRET_BODY  = 'SECRETBODYTEXT'

  setup do
    @author   = users(:one)
    @stranger = users(:two)
    @document = Document.create!(user: @author, title: SECRET_TITLE, body: "<p>#{SECRET_BODY}</p>", synopsis: 'SECRETSYNOPSIS', privacy: 'private', cached_word_count: 12345)
    @document.protect_with_password(PASSWORD)
    # Fixture shares point at nothing, which the feed can't render
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_TITLE
    assert_not_includes response.body, SECRET_BODY
    assert_not_includes response.body, 'SECRETSYNOPSIS'
    assert_not_includes response.body, '12,345'
  end

  def public_universe
    @public_universe ||= Universe.create!(user: @author, name: 'Open Universe', privacy: 'public')
  end

  def public_book
    @public_book ||= Book.create!(user: @author, name: 'Open Book', privacy: 'public')
  end

  def mentioned_character
    character = Character.create!(user: @author, name: 'Mentioned Person', privacy: 'public')
    analysis  = @document.document_analysis.create!
    analysis.document_entities.create!(entity_type: 'Character', entity_id: character.id, text: 'Mentioned Person')
    character
  end

  test "the password outranks a public universe" do
    @document.update!(universe: public_universe)

    assert_not User.new.can_read?(@document)
    assert_not @stranger.can_read?(@document)
    assert_not @document.public_content?
  end

  test "the password outranks a public book" do
    public_book.book_documents.create!(document: @document)

    assert_not User.new.can_read?(@document)
    assert_not @stranger.can_read?(@document)
    assert_not @document.readable_via_public_book?
    assert_not @document.public_content?
  end

  test "the author, site admins and universe members skip the password" do
    universe = Universe.create!(user: @stranger, name: 'Their Universe', privacy: 'private')
    contributor = User.create!(name: 'Contributor', email: 'contributor@example.com', password: 'password123')
    Contributor.create!(universe: universe, user: contributor)
    admin = User.create!(name: 'Admin', email: 'admin@example.com', password: 'password123', site_administrator: true)
    outsider = User.create!(name: 'Outsider', email: 'outsider@example.com', password: 'password123')
    @document.update!(universe: universe)

    assert @author.can_read?(@document)
    assert @stranger.can_read?(@document), "The universe's owner should get in"
    assert contributor.can_read?(@document), "The universe's contributors should get in"
    assert admin.can_read?(@document)
    assert_not outsider.can_read?(@document)
  end

  test "an unclaimed contributor invite doesn't skip the password" do
    universe = Universe.create!(user: @author, name: 'Private Universe', privacy: 'private')
    Contributor.create!(universe: universe, email: 'invited@example.com')
    @document.update!(universe: universe)

    assert_not User.new.can_read?(@document)
  end

  test "analysis pages stay closed" do
    get analysis_document_path(@document)
    assert_no_secrets

    sign_in @stranger

    get analysis_document_path(@document)
    assert_no_secrets
    get "/documents/#{@document.id}/analysis/readability"
    assert_no_secrets
    get "/documents/#{@document.id}/analysis/style"
    assert_no_secrets
    get "/documents/#{@document.id}/analysis/sentiment"
    assert_no_secrets
  end

  test "plaintext and printable views stay closed" do
    sign_in @stranger

    get plaintext_document_path(@document)
    assert_no_secrets
    get printable_document_path(@document)
    assert_no_secrets
  end

  test "revisions stay closed" do
    revision = @document.document_revisions.create!(title: SECRET_TITLE, body: "<p>#{SECRET_BODY}</p>", cached_word_count: 1)
    sign_in @stranger

    get document_document_revisions_path(@document)
    assert_no_secrets
    get document_document_revision_path(@document, revision)
    assert_no_secrets
  end

  test "a public book lists the chapter without its title or length" do
    public_book.book_documents.create!(document: @document)

    get book_path(public_book)

    assert_response :success
    assert_no_secrets
    assert_includes response.body, 'Password protected chapter'
    assert_includes response.body, document_path(@document)
  end

  test "a public book's reading time leaves out locked chapters" do
    public_book.book_documents.create!(document: @document)
    open_chapter = Document.create!(user: @author, title: 'Open chapter', privacy: 'private', cached_word_count: 400)
    public_book.book_documents.create!(document: open_chapter)

    get book_path(public_book)

    assert_includes response.body, 'Open chapter'
    assert_equal [open_chapter.id], controller.instance_variable_get(:@unlocked_book_documents).map(&:document_id)
    assert_equal 400, controller.instance_variable_get(:@total_words)
  end

  test "a public book doesn't reveal which characters appear in a locked chapter" do
    character = mentioned_character
    character.update!(name: 'Spoiler Character')
    public_book.book_documents.create!(document: @document)

    get book_path(public_book)

    assert_not_includes response.body, 'Spoiler Character'
  end

  test "the author still sees the chapter in their public book" do
    public_book.book_documents.create!(document: @document)
    sign_in @author

    get book_path(public_book)

    assert_includes response.body, SECRET_TITLE
    assert_not_includes response.body, 'Password protected chapter'
  end

  test "a public book's warning about private chapters leaves out protected ones" do
    public_book.book_documents.create!(document: @document)
    sign_in @author

    get edit_book_path(public_book)

    assert_response :success
    assert_not_includes response.body, 'private chapter'
    assert_not_includes response.body, 'Readable via book'
  end

  test "a public universe's documents tab and count leave it out" do
    @document.update!(universe: public_universe)
    Document.create!(user: @author, title: 'Open document', universe: public_universe, privacy: 'private')

    get universe_path(public_universe)

    assert_response :success
    assert_no_secrets
    assert_includes response.body, 'Open document'
    assert_equal 1, controller.instance_variable_get(:@documents_count)
  end

  test "a public universe's documents tab still shows it to the author" do
    @document.update!(universe: public_universe)
    sign_in @author

    get universe_path(public_universe)

    assert_includes response.body, SECRET_TITLE
    assert_equal 1, controller.instance_variable_get(:@documents_count)
  end

  test "a universe's documents tab keeps documents with no privacy value" do
    @document.update!(universe: public_universe)
    no_privacy = Document.create!(user: @author, title: 'No privacy value', universe: public_universe)
    no_privacy.update_column(:privacy, nil)

    assert_includes public_universe.documents_listable_by(nil), no_privacy
    assert_not_includes public_universe.documents_listable_by(nil), @document
  end

  test "pages that mention it don't list it" do
    character = mentioned_character

    get character_path(character)
    assert_no_secrets

    sign_in @stranger
    get references_character_path(character)
    assert_no_secrets
  end

  test "a page that mentions it still lists it for the author" do
    character = mentioned_character
    sign_in @author

    get character_path(character)

    assert_includes response.body, SECRET_TITLE
  end

  test "the name lookup and content links hide its title" do
    get "/api/internal/Document/#{@document.id}/name"
    assert_equal 'Page not found', response.body

    assert_not_includes ContentFormatterService.show(text: "[[Document-#{@document.id}]]", viewing_user: User.new), SECRET_TITLE
    assert_not_includes ContentFormatterService.show(text: "[[Document-#{@document.id}]]", viewing_user: @stranger), SECRET_TITLE

    sign_in @stranger
    get '/api/v1/page_name', params: { type: 'Document', id: @document.id }
    assert_response :forbidden
    assert_no_secrets
  end

  test "old shares stop previewing it" do
    public_document = Document.create!(user: @author, title: 'Was shared', body: "<p>#{SECRET_BODY}</p>", privacy: 'public')
    share = ContentPageShare.create!(user: @author, content_page: public_document, message: 'hi', shared_at: DateTime.current)
    public_document.remove_password_protection('private')
    public_document.protect_with_password(PASSWORD)

    get user_content_page_share_path(@author, share)
    assert_no_secrets
    assert_not_includes response.body, 'Was shared'

    sign_in @stranger
    get stream_world_path
    assert_no_secrets
    assert_not_includes response.body, 'Was shared'
  end

  test "it can't be shared by anyone, including its author" do
    [@stranger, @author].each do |user|
      sign_in user

      assert_no_difference 'ContentPageShare.count' do
        post user_content_page_shares_path(user), params: { content_page_share: { content_page: "Document-#{@document.id}", message: 'hi' } }
      end

      assert @document.reload.password_protected?
      sign_out user
    end
  end

  test "sharing it directly fails too" do
    share = ContentPageShare.new(user: @author, content_page: @document, shared_at: DateTime.current)

    assert_not share.save
    assert_includes share.errors.full_messages.to_sentence, "can't be shared"
  end

  test "it can't be submitted to a collection" do
    collection = PageCollection.create!(user: @author, title: 'Mine', privacy: 'public')
    sign_in @author

    assert_no_difference 'PageCollectionSubmission.count' do
      post page_collection_submissions_path, params: { page_collection_submission: { content: "Document-#{@document.id}", page_collection_id: collection.id } }
    end

    assert @document.reload.password_protected?
  end

  test "its tags don't reach the author's public tag pages" do
    @document.page_tags.create!(tag: 'Secret Tag', slug: 'secret-tag', user: @author)

    get user_id_tag_path(@author, 'secret-tag')
    assert_no_secrets

    get browse_tag_path('secret-tag')
    assert_no_secrets
  end

  test "generic updates can't change its privacy" do
    sign_in @author

    patch document_path(@document), params: { document: { privacy: 'public' } }
    assert @document.reload.password_protected?

    other_document = Document.create!(user: @author, title: 'Other', privacy: 'private')
    patch document_path(other_document), params: { document: { privacy: 'password' } }
    assert_equal 'private', other_document.reload.privacy
  end

  test "autosaves still work" do
    sign_in @author

    patch document_path(@document), params: { document: { body: '<p>Autosaved</p>' } }

    assert_response :success
    assert_includes @document.reload.body, 'Autosaved'
  end

  test "the editor and hub show the right label to the author" do
    sign_in @author

    get edit_document_path(@document)
    assert_response :success
    assert_includes response.body, 'Password protected'
    assert_includes response.body, 'vpn_key'

    # The hub only lists recent documents, and can't render fixture users' completed analyses
    other_author = User.create!(name: 'Other Author', email: 'other-author@example.com', password: 'password123')
    Document.create!(user: other_author, title: 'Theirs').protect_with_password(PASSWORD)
    sign_in other_author

    get analysis_hub_path
    assert_response :success
    assert_includes response.body, 'Password protected'
  end
end
