require 'test_helper'

class DocumentPasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD     = 'correct horse'
  SECRET_TITLE = 'SECRETTITLE'
  SECRET_BODY  = 'SECRETBODYTEXT'

  setup do
    @author   = users(:one)
    @stranger = users(:two)
    @document = Document.create!(user: @author, title: SECRET_TITLE, body: "<p>#{SECRET_BODY}</p>", synopsis: 'SECRETSYNOPSIS', privacy: 'private', cached_word_count: 12345)
    @document.protect_with_password(PASSWORD)
    Rack::Attack.reset!
  end

  teardown do
    Rack::Attack.reset!
  end

  def assert_locked
    assert_response :success
    assert_includes response.body, 'This document is password protected'
    assert_no_secrets
  end

  def assert_unlocked
    assert_response :success
    assert_includes response.body, SECRET_BODY
    assert_not_includes response.body, 'This document is password protected'
  end

  def assert_no_secrets
    assert_not_includes response.body, SECRET_TITLE
    assert_not_includes response.body, SECRET_BODY
    assert_not_includes response.body, 'SECRETSYNOPSIS'
    assert_not_includes response.body, '12,345'
    assert_not_includes response.body, @document.document_password_digest
  end

  def unlock(document = @document, password: PASSWORD)
    post unlock_document_path(document), params: { password: password }
  end

  test "the lock screen gives nothing away" do
    get document_path(@document)

    assert_locked
    assert_includes response.body, @author.display_name
    assert_select 'title', /Password protected document/
    assert_select 'meta[name=robots][content*=noindex]'
    assert_includes response.headers['Cache-Control'], 'no-store'
  end

  test "signed-in strangers get the lock screen too" do
    sign_in @stranger

    get document_path(@document)

    assert_locked
  end

  test "the lock screen also shows up in a public universe or book" do
    universe = Universe.create!(user: @author, name: 'Open Universe', privacy: 'public')
    @document.update!(universe: universe)
    get document_path(@document)
    assert_locked

    @document.update!(universe: nil)
    book = Book.create!(user: @author, name: 'Open Book', privacy: 'public')
    book.book_documents.create!(document: @document)
    get document_path(@document)
    assert_locked
  end

  test "private documents still look like they don't exist" do
    private_document = Document.create!(user: @author, title: 'Private', privacy: 'private')

    get document_path(private_document)

    assert_response :not_found
    assert_not_includes response.body, 'password protected'
  end

  test "a blocked author's document isn't shown at all" do
    @author.thredded_user_detail.update!(moderation_state: 'blocked')

    get document_path(@document)

    assert_response :not_found
    assert_not_includes response.body, 'password protected'
  end

  test "the right password opens the document" do
    unlock

    assert_redirected_to document_path(@document)
    follow_redirect!
    assert_unlocked
    assert_includes response.body, SECRET_TITLE
  end

  test "an unlocked document stays out of caches and search engines" do
    unlock
    follow_redirect!

    assert_includes response.headers['Cache-Control'], 'no-store'
    assert_select 'meta[name=robots][content*=noindex]'
  end

  test "an unlocked reader can't share the document" do
    unlock
    follow_redirect!

    assert_not_includes response.body, 'document-share-button'
  end

  test "the wrong password explains itself and doesn't open anything" do
    unlock(password: 'wrong password')

    assert_redirected_to document_path(@document)
    follow_redirect!
    assert_locked
    assert_includes CGI.unescapeHTML(response.body), "That password isn't right"
  end

  test "a missing or odd password param doesn't open anything" do
    post unlock_document_path(@document)
    follow_redirect!
    assert_locked

    post unlock_document_path(@document), params: { password: { nested: PASSWORD } }
    follow_redirect!
    assert_locked

    post unlock_document_path(@document), params: { password: [PASSWORD] }
    follow_redirect!
    assert_locked
  end

  test "unlocking one document doesn't unlock another" do
    other = Document.create!(user: @author, title: 'Other', body: '<p>OTHERBODY</p>', privacy: 'private')
    other.protect_with_password(PASSWORD)

    unlock

    get document_path(other)
    assert_not_includes response.body, 'OTHERBODY'
    assert_includes response.body, 'This document is password protected'
  end

  test "changing the password locks out everyone who entered the old one" do
    unlock

    Document.find(@document.id).protect_with_password('a brand new password')

    get document_path(@document)
    assert_locked
  end

  test "taking protection off and on again doesn't reuse old unlocks" do
    unlock

    document = Document.find(@document.id)
    document.remove_password_protection('private')
    get document_path(@document)
    assert_response :not_found

    document.protect_with_password(PASSWORD)
    get document_path(@document)
    assert_includes response.body, 'This document is password protected'
  end

  test "signing out forgets unlocks" do
    sign_in @stranger
    unlock
    get document_path(@document)
    assert_unlocked

    get destroy_user_session_path

    get document_path(@document)
    assert_locked
  end

  test "unlocking only opens the reading page" do
    sign_in @stranger
    revision = @document.document_revisions.create!(title: SECRET_TITLE, body: "<p>#{SECRET_BODY}</p>", cached_word_count: 1)
    unlock
    get document_path(@document)
    assert_unlocked

    [
      analysis_document_path(@document),
      plaintext_document_path(@document),
      printable_document_path(@document),
      edit_document_path(@document),
      document_document_revisions_path(@document),
      document_document_revision_path(@document, revision),
      "/api/internal/Document/#{@document.id}/name"
    ].each do |path|
      get path
      assert_not_includes response.body, SECRET_BODY, "#{path} showed the text"
      assert_not_includes response.body, SECRET_TITLE, "#{path} showed the title"
    end
  end

  test "an unlocked reader can't change anything" do
    sign_in @stranger
    unlock

    patch password_document_path(@document), params: { password: 'a brand new password' }, as: :json
    assert_response :forbidden

    delete password_document_path(@document), params: { privacy: 'public' }, as: :json
    assert_response :forbidden

    patch document_path(@document), params: { document: { body: 'vandalized' } }
    assert_includes @document.reload.body, SECRET_BODY
    assert @document.password_protected?
  end

  test "an unlocked reader sees the chapter's title in a public book" do
    book = Book.create!(user: @author, name: 'Open Book', privacy: 'public')
    book.book_documents.create!(document: @document)

    get book_path(book)
    assert_not_includes response.body, SECRET_TITLE

    unlock
    get book_path(book)
    assert_includes response.body, SECRET_TITLE
    assert_not_includes response.body, 'Password protected chapter'
  end

  test "the session only remembers the most recent unlocks" do
    documents = Array.new(DocumentUnlocks::MAX_REMEMBERED_UNLOCKS + 1) do |index|
      Document.create!(user: @author, title: "Doc #{index}", body: '<p>Unlocked text</p>', privacy: 'private').tap { |document| document.protect_with_password(PASSWORD) }
    end

    documents.each_with_index do |document, index|
      Rack::Attack.reset! if (index % 5).zero?
      unlock(document)
    end

    assert_equal DocumentUnlocks::MAX_REMEMBERED_UNLOCKS, session[:unlocked_documents].size
    assert_operator cookies['_notebook_session'].bytesize, :<, 3000

    get document_path(documents.last)
    assert_includes response.body, 'Unlocked text'

    get document_path(documents.first)
    assert_includes response.body, 'This document is password protected'
  end

  test "unlocking a missing or unprotected document goes nowhere" do
    post "/documents/0/unlock", params: { password: PASSWORD }
    assert_response :not_found

    public_document = Document.create!(user: @author, title: 'Public', privacy: 'public')
    unlock(public_document)
    assert_redirected_to document_path(public_document)
    assert_nil session[:unlocked_documents]
  end

  test "an expired form asks the reader to try again instead of silently failing" do
    with_forgery_protection do
      post unlock_document_path(@document), params: { password: PASSWORD }

      assert_redirected_to document_path(@document)
      follow_redirect!
      assert_locked
      assert_includes response.body, 'Your session expired'
    end
  end

  test "the lock screen's own form works with forgery protection on" do
    with_forgery_protection do
      get document_path(@document)
      token = css_select('form[action$="/unlock"] input[name=authenticity_token]').first['value']

      post unlock_document_path(@document), params: { password: PASSWORD, authenticity_token: token }
      follow_redirect!

      assert_unlocked
    end
  end

  test "passwords stay out of the logs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    filtered = filter.filter('password' => PASSWORD, 'document_password' => { 'password' => PASSWORD })

    assert_not_includes filtered.to_s, PASSWORD
  end

  test "authors can set a password" do
    document = Document.create!(user: @author, title: 'Mine', privacy: 'public')
    sign_in @author

    patch password_document_path(document), params: { password: 'a good password' }, as: :json

    assert_response :success
    assert_equal({ 'privacy' => 'password', 'label' => 'Password protected', 'icon' => 'vpn_key' }, response.parsed_body)
    assert document.reload.authenticate_document_password('a good password')
  end

  test "a password that's too short comes back as a readable error" do
    document = Document.create!(user: @author, title: 'Mine', privacy: 'public')
    sign_in @author

    patch password_document_path(document), params: { password: 'short' }, as: :json

    assert_response :unprocessable_entity
    assert_includes response.parsed_body['error'], 'at least 8 characters'
    assert_equal 'public', document.reload.privacy
  end

  test "authors can take a password off" do
    sign_in @author

    delete password_document_path(@document), params: { privacy: 'private' }, as: :json

    assert_response :success
    assert_equal 'private', response.parsed_body['privacy']
    assert_nil @document.reload.document_password_digest
  end

  test "taking a password off needs a real privacy value" do
    sign_in @author

    ['password', 'nonsense', nil].each do |privacy|
      delete password_document_path(@document), params: { privacy: privacy }, as: :json

      assert_response :unprocessable_entity
      assert @document.reload.password_protected?
    end
  end

  test "only the author can set or remove a password" do
    patch password_document_path(@document), params: { password: 'a brand new password' }, as: :json
    assert_response :unauthorized

    sign_in @stranger

    patch password_document_path(@document), params: { password: 'a brand new password' }, as: :json
    assert_response :forbidden

    delete password_document_path(@document), params: { privacy: 'public' }, as: :json
    assert_response :forbidden

    assert @document.reload.authenticate_document_password(PASSWORD)
  end

  test "universe contributors can't change the password" do
    universe = Universe.create!(user: @stranger, name: 'Their Universe', privacy: 'private')
    @document.update!(universe: universe)
    sign_in @stranger

    get document_path(@document)
    assert_unlocked

    patch password_document_path(@document), params: { password: 'a brand new password' }, as: :json
    assert_response :forbidden
  end

  test "the owner reads their document without the password" do
    sign_in @author

    get document_path(@document)

    assert_unlocked
  end

  test "the privacy modal offers password protection" do
    document = Document.create!(user: @author, title: 'Mine', privacy: 'private')
    sign_in @author

    get edit_document_path(document)

    assert_response :success
    assert_select '#document-privacy-password'
    assert_select '#document-password-input:not([name])'
    assert_select '#document-privacy-form[data-password-url=?]', password_document_path(document)
  end

  test "guessing is limited per visitor" do
    10.times do
      unlock(password: 'wrong password')
      assert_redirected_to document_path(@document)
    end

    unlock
    assert_redirected_to document_path(@document, too_many_attempts: 1)

    follow_redirect!
    assert_locked
    assert_includes response.body, 'Too many attempts'
    assert_nil session[:unlocked_documents]
  end

  test "guessing is limited per document, however many addresses it comes from" do
    30.times do |index|
      post unlock_document_path(@document), params: { password: 'wrong password' }, env: { 'REMOTE_ADDR' => "203.0.113.#{index + 1}" }
      assert_redirected_to document_path(@document)
    end

    post unlock_document_path(@document), params: { password: PASSWORD }, env: { 'REMOTE_ADDR' => '203.0.113.200' }

    assert_redirected_to document_path(@document, too_many_attempts: 1)
    assert_nil session[:unlocked_documents]
  end

  test "guessing is limited across the whole site" do
    documents = Array.new(11) do |index|
      Document.create!(user: @author, title: "Doc #{index}", privacy: 'private').tap { |document| document.protect_with_password(PASSWORD) }
    end

    300.times do |index|
      post unlock_document_path(documents[index % documents.size]), params: { password: 'wrong password' }, env: { 'REMOTE_ADDR' => "203.0.#{index / 200}.#{index % 200 + 1}" }
      assert_redirected_to document_path(documents[index % documents.size])
    end

    post unlock_document_path(@document), params: { password: PASSWORD }, env: { 'REMOTE_ADDR' => '198.51.100.1' }

    assert_redirected_to document_path(@document, too_many_attempts: 1)
  end

  test "being limited on one document doesn't stop another visitor reading others" do
    10.times { unlock(password: 'wrong password') }
    other = Document.create!(user: @author, title: 'Other', body: '<p>OTHERBODY</p>', privacy: 'private')
    other.protect_with_password(PASSWORD)

    post unlock_document_path(other), params: { password: PASSWORD }, env: { 'REMOTE_ADDR' => '203.0.113.7' }
    get document_path(other), env: { 'REMOTE_ADDR' => '203.0.113.7' }

    assert_includes response.body, 'OTHERBODY'
  end

  test "other spellings of the unlock path can't dodge the limits" do
    id = @document.id

    [
      "/documents/#{id}/unlock.json",
      "/documents/#{id}/unlock.html",
      "/documents/#{id}/unlock/",
      "//documents/#{id}/unlock",
      "/documents//#{id}/unlock",
      "/documents/0#{id}/unlock",
      "/documents/#{id}abc/unlock",
      "/documents/%3#{id.to_s[0]}#{id.to_s[1..]}/unlock",
      "/documents/#{id}/%75nlock",
      "/DOCUMENTS/#{id}/UNLOCK"
    ].each do |path|
      Rack::Attack.reset!
      10.times do
        begin
          post path, params: { password: 'wrong password' }
        rescue ActionController::RoutingError
          # Doesn't route, so it can't reach the password check at all
        end
      end

      begin
        post path, params: { password: PASSWORD }
        assert_nil session[:unlocked_documents], "#{path} got past the limits"
      rescue ActionController::RoutingError
        pass
      end
    end
  end

  test "the limits only look at unlock requests" do
    [
      ['/documents/1', 'GET'],
      ['/documents/1', 'PATCH'],
      ['/documents/1/unlock', 'GET'],
      ['/users/sign_in', 'POST'],
      ['/documents/1/password', 'PATCH']
    ].each do |path, method|
      request = Rack::Attack::Request.new(Rack::MockRequest.env_for(path, method: method))
      assert_nil Rack::Attack.document_unlock_id(request), "#{method} #{path} would touch Redis"
    end
  end

  private

  def with_forgery_protection
    original = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    yield
  ensure
    ActionController::Base.allow_forgery_protection = original
  end
end
