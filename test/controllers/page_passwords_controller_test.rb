require 'test_helper'

# Setting, removing and entering passwords on worldbuilding pages. Mirrors
# DocumentPasswordsControllerTest, since pages follow the same rules.
class PagePasswordsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  PASSWORD    = 'correct horse'
  SECRET_NAME = 'SECRETPAGENAME'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    @page     = Character.create!(user: @owner, name: SECRET_NAME, privacy: 'private')
    @page.protect_with_password(PASSWORD)
    Rack::Attack.reset!
  end

  teardown do
    Rack::Attack.reset!
  end

  def assert_locked(page = @page)
    assert_response :success
    assert_includes response.body, "This #{page.class.name.downcase} is password protected"
    assert_not_includes response.body, page.name
    assert_not_includes response.body, page.reload.page_password.password_digest
  end

  def assert_unlocked(page = @page)
    assert_response :success
    assert_includes response.body, page.name
    assert_not_includes response.body, 'is password protected'
  end

  def unlock(page = @page, password: PASSWORD, **options)
    post send("unlock_#{page.class.name.downcase}_path", page), params: { password: password }, **options
  end

  test "the lock screen gives nothing away" do
    get character_path(@page)

    assert_locked
    assert_includes response.body, @owner.display_name
    assert_select 'title', /Password protected character/
    assert_select 'meta[name=robots][content*=noindex]'
    assert_includes response.headers['Cache-Control'], 'no-store'
  end

  test "signed-in strangers get the lock screen too" do
    sign_in @stranger

    get character_path(@page)

    assert_locked
  end

  test "the lock screen shows up in a public universe" do
    universe = Universe.create!(user: @owner, name: 'Open Universe', privacy: 'public')
    @page.update!(universe: universe)

    get character_path(@page)

    assert_locked
  end

  test "every page type gets the lock screen and opens with the password" do
    Rails.application.config.content_types[:all].each do |page_type|
      page = page_type.create!(user: @owner, name: "Secret #{page_type.name}", privacy: 'private')
      page.protect_with_password(PASSWORD)
      Rack::Attack.reset!

      get polymorphic_path(page)
      assert_locked(page)

      unlock(page)
      assert_redirected_to polymorphic_path(page)
      follow_redirect!
      assert_unlocked(page)
    end
  end

  test "private pages still turn people away" do
    private_page = Character.create!(user: @owner, name: 'Just private', privacy: 'private')

    get character_path(private_page)

    assert_redirected_to root_path
    follow_redirect!
    assert_not_includes response.body, 'password protected'
    assert_not_includes response.body, 'Just private'
  end

  test "the right password opens the page" do
    unlock

    assert_redirected_to character_path(@page)
    follow_redirect!
    assert_unlocked
  end

  test "an unlocked page stays out of caches and search engines" do
    unlock
    follow_redirect!

    assert_includes response.headers['Cache-Control'], 'no-store'
    assert_select 'meta[name=robots][content*=noindex]'
  end

  test "an unlocked reader can't share the page" do
    unlock
    follow_redirect!

    assert_select '#page-share-button', count: 0
  end

  test "the wrong password explains itself and doesn't open anything" do
    unlock(password: 'wrong password')

    assert_redirected_to character_path(@page)
    follow_redirect!
    assert_locked
    assert_includes CGI.unescapeHTML(response.body), "That password isn't right"
  end

  test "a missing or odd password param doesn't open anything" do
    post unlock_character_path(@page)
    follow_redirect!
    assert_locked

    post unlock_character_path(@page), params: { password: { nested: PASSWORD } }
    follow_redirect!
    assert_locked

    post unlock_character_path(@page), params: { password: [PASSWORD] }
    follow_redirect!
    assert_locked
  end

  test "unlocking one page doesn't unlock another" do
    other = Character.create!(user: @owner, name: 'OTHERPAGE', privacy: 'private')
    other.protect_with_password(PASSWORD)
    same_id_location = Location.create!(user: @owner, name: 'OTHERLOCATION', privacy: 'private')
    same_id_location.protect_with_password(PASSWORD)

    unlock

    get character_path(other)
    assert_locked(other)

    get location_path(same_id_location)
    assert_locked(same_id_location)
  end

  test "changing the password locks out everyone who entered the old one" do
    unlock

    Character.find(@page.id).protect_with_password('a brand new password')

    get character_path(@page)
    assert_locked
  end

  test "taking protection off and on again doesn't reuse old unlocks" do
    unlock

    page = Character.find(@page.id)
    page.remove_password_protection('private')
    get character_path(@page)
    assert_redirected_to root_path

    page.reload.protect_with_password(PASSWORD)
    get character_path(@page)
    assert_locked
  end

  test "signing out forgets unlocks" do
    sign_in @stranger
    unlock
    get character_path(@page)
    assert_unlocked

    get destroy_user_session_path

    get character_path(@page)
    assert_locked
  end

  test "unlocking only opens the page itself" do
    sign_in @stranger
    unlock
    get character_path(@page)
    assert_unlocked

    [
      character_path(@page, format: :json),
      references_character_path(@page),
      changelog_character_path(@page),
      edit_character_path(@page),
      "/api/internal/Character/#{@page.id}/name",
      "/api/v1/character/#{@page.id}",
      characters_user_path(@owner),
      user_path(@owner)
    ].each do |path|
      get path
      assert_not_includes response.body, SECRET_NAME, "#{path} showed the page"
    end

    assert_not_includes ContentFormatterService.show(text: "[[Character-#{@page.id}]]", viewing_user: @stranger), SECRET_NAME
  end

  test "an unlocked reader can't change anything" do
    sign_in @stranger
    unlock

    patch password_character_path(@page), params: { password: 'a brand new password' }, as: :json
    assert_response :forbidden

    delete password_character_path(@page), params: { privacy: 'public' }, as: :json
    assert_response :forbidden

    patch character_path(@page), params: { character: { name: 'vandalized' } }
    assert_equal SECRET_NAME, @page.reload.name
    assert @page.password_protected?
  end

  test "an unlocked page doesn't link to the pages that only its members can open" do
    unlock
    follow_redirect!

    assert_not_includes response.body, references_character_path(@page)
    assert_not_includes response.body, changelog_character_path(@page)
  end

  test "the session only remembers the most recent unlocks, alongside documents" do
    pages = Array.new(PageUnlocks::MAX_REMEMBERED_UNLOCKS + 1) do |index|
      Character.create!(user: @owner, name: "Unlocked page #{index}", privacy: 'private').tap { |page| page.protect_with_password(PASSWORD) }
    end
    documents = Array.new(DocumentUnlocks::MAX_REMEMBERED_UNLOCKS) do |index|
      Document.create!(user: @owner, title: "Doc #{index}", privacy: 'private').tap { |document| document.protect_with_password(PASSWORD) }
    end

    (pages + documents).each_with_index do |page, index|
      Rack::Attack.reset! if (index % 5).zero?
      post(page.is_a?(Document) ? unlock_document_path(page) : unlock_character_path(page), params: { password: PASSWORD })
    end

    assert_equal PageUnlocks::MAX_REMEMBERED_UNLOCKS, session[:unlocked_pages].size
    assert_equal DocumentUnlocks::MAX_REMEMBERED_UNLOCKS, session[:unlocked_documents].size
    assert_operator cookies['_notebook_session'].bytesize, :<, 3500

    get character_path(pages.last)
    assert_unlocked(pages.last)

    get character_path(pages.first)
    assert_locked(pages.first)
  end

  test "unlocking a missing or unprotected page goes nowhere" do
    post "/plan/characters/0/unlock", params: { password: PASSWORD }
    assert_response :not_found

    public_page = Character.create!(user: @owner, name: 'Public', privacy: 'public')
    unlock(public_page)
    assert_redirected_to character_path(public_page)
    assert_nil session[:unlocked_pages]
  end

  test "an expired form asks the reader to try again instead of silently failing" do
    with_forgery_protection do
      post unlock_character_path(@page), params: { password: PASSWORD }

      assert_redirected_to character_path(@page)
      follow_redirect!
      assert_locked
      assert_includes response.body, 'Your session expired'
    end
  end

  test "the lock screen's own form works with forgery protection on" do
    with_forgery_protection do
      get character_path(@page)
      token = css_select('form[action$="/unlock"] input[name=authenticity_token]').first['value']

      post unlock_character_path(@page), params: { password: PASSWORD, authenticity_token: token }
      follow_redirect!

      assert_unlocked
    end
  end

  test "owners can set a password" do
    page = Character.create!(user: @owner, name: 'Mine', privacy: 'public')
    sign_in @owner

    patch password_character_path(page), params: { password: 'a good password' }, as: :json

    assert_response :success
    assert_equal({ 'privacy' => 'password', 'label' => 'Password protected', 'icon' => 'vpn_key' }, response.parsed_body)
    assert page.reload.authenticate_page_password('a good password')
  end

  test "universe owners can protect their universe" do
    universe = Universe.create!(user: @owner, name: 'My universe', privacy: 'public')
    sign_in @owner

    patch password_universe_path(universe), params: { password: 'a good password' }, as: :json

    assert_response :success
    assert universe.reload.authenticate_page_password('a good password')
  end

  test "a password that's too short comes back as a readable error" do
    page = Character.create!(user: @owner, name: 'Mine', privacy: 'public')
    sign_in @owner

    ['abcd', ''].each do |password|
      patch password_character_path(page), params: { password: password }, as: :json

      assert_response :unprocessable_entity
      assert_equal 'Password must be at least 5 characters', response.parsed_body['error']
      assert_equal 'public', page.reload.privacy
    end
  end

  test "owners can take a password off" do
    sign_in @owner

    delete password_character_path(@page), params: { privacy: 'private' }, as: :json

    assert_response :success
    assert_equal 'private', response.parsed_body['privacy']
    assert_nil @page.reload.page_password
  end

  test "taking a password off needs a real privacy value" do
    sign_in @owner

    ['password', 'nonsense', nil].each do |privacy|
      delete password_character_path(@page), params: { privacy: privacy }, as: :json

      assert_response :unprocessable_entity
      assert @page.reload.password_protected?
    end
  end

  test "only the owner can set or remove a password" do
    patch password_character_path(@page), params: { password: 'a brand new password' }, as: :json
    assert_response :unauthorized

    sign_in @stranger

    patch password_character_path(@page), params: { password: 'a brand new password' }, as: :json
    assert_response :forbidden

    delete password_character_path(@page), params: { privacy: 'public' }, as: :json
    assert_response :forbidden

    assert @page.reload.authenticate_page_password(PASSWORD)
  end

  test "contributors and universe owners read the page but can't change its password" do
    universe = Universe.create!(user: @stranger, name: 'Their Universe', privacy: 'private')
    contributor = User.create!(name: 'Contributor', email: 'contributor@example.com', password: 'password123')
    Contributor.create!(universe: universe, user: contributor)
    Contributor.create!(universe: universe, user: @owner)
    @page.update!(universe: universe)

    [@stranger, contributor].each do |member|
      sign_in member

      get character_path(@page)
      assert_unlocked

      patch password_character_path(@page), params: { password: 'a brand new password' }, as: :json
      assert_response :forbidden

      delete password_character_path(@page), params: { privacy: 'public' }, as: :json
      assert_response :forbidden

      sign_out member
    end

    assert @page.reload.authenticate_page_password(PASSWORD)
  end

  test "the owner views their page without the password" do
    sign_in @owner

    get character_path(@page)

    assert_unlocked
  end

  test "passwords stay out of the logs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    assert_not_includes filter.filter('password' => PASSWORD).to_s, PASSWORD
  end

  # Universes

  test "a protected universe's page shows only what's public on its own" do
    universe = Universe.create!(user: @owner, name: 'SECRETUNIVERSE', privacy: 'private')
    universe.protect_with_password(PASSWORD)
    private_page = Character.create!(user: @owner, universe: universe, name: 'PRIVATEINSIDE', privacy: 'private')
    public_page  = Character.create!(user: @owner, universe: universe, name: 'PUBLICINSIDE', privacy: 'public')
    private_doc  = Document.create!(user: @owner, universe: universe, title: 'PRIVATEDOCUMENT', privacy: 'private')

    get universe_path(universe)
    assert_locked(universe)

    unlock(universe)
    follow_redirect!
    assert_unlocked(universe)
    assert_not_includes response.body, 'PRIVATEINSIDE'
    assert_not_includes response.body, 'PRIVATEDOCUMENT'
    assert_equal 1, controller.instance_variable_get(:@in_this_universe_count)
    assert_equal 0, controller.instance_variable_get(:@documents_count)

    # The universe's password opens the universe page, and nothing in it
    get character_path(private_page)
    assert_redirected_to root_path
    get characters_universe_path(universe)
    assert_not_includes response.body, 'PUBLICINSIDE'
    assert_not_includes response.body, 'PRIVATEINSIDE'
    get document_path(private_doc)
    assert_response :not_found

    get character_path(public_page)
    assert_unlocked(public_page)
  end

  test "a protected page in a protected universe needs its own password" do
    universe = Universe.create!(user: @owner, name: 'Locked universe', privacy: 'private')
    universe.protect_with_password(PASSWORD)
    @page.update!(universe: universe)

    unlock(universe)
    get character_path(@page)
    assert_locked

    unlock
    get character_path(@page)
    assert_unlocked
  end

  # Rate limits

  test "guessing is limited per visitor" do
    10.times do
      unlock(password: 'wrong password')
      assert_redirected_to character_path(@page)
    end

    unlock
    assert_redirected_to character_path(@page, too_many_attempts: 1)

    follow_redirect!
    assert_locked
    assert_includes response.body, 'Too many attempts'
    assert_nil session[:unlocked_pages]
  end

  test "a visitor's limit covers documents and pages together" do
    document = Document.create!(user: @owner, title: 'Doc', privacy: 'private')
    document.protect_with_password(PASSWORD)

    5.times { post unlock_document_path(document), params: { password: 'wrong password' } }
    5.times { unlock(password: 'wrong password') }

    unlock
    assert_redirected_to character_path(@page, too_many_attempts: 1)
  end

  test "guessing is limited per page, however many addresses it comes from" do
    30.times do |index|
      unlock(password: 'wrong password', env: { 'REMOTE_ADDR' => "203.0.113.#{index + 1}" })
      assert_redirected_to character_path(@page)
    end

    unlock(env: { 'REMOTE_ADDR' => '203.0.113.200' })

    assert_redirected_to character_path(@page, too_many_attempts: 1)
    assert_nil session[:unlocked_pages]
  end

  test "pages of different types with the same id have their own limits" do
    location = Location.create!(user: @owner, name: 'Elsewhere', privacy: 'private')
    location.update_column(:id, @page.id) unless location.id == @page.id
    location = Location.find(@page.id)
    location.protect_with_password(PASSWORD)

    30.times do |index|
      unlock(password: 'wrong password', env: { 'REMOTE_ADDR' => "203.0.113.#{index + 1}" })
    end

    unlock(location, env: { 'REMOTE_ADDR' => '198.51.100.1' })
    assert_redirected_to location_path(location)
  end

  test "guessing is limited across the whole site, documents included" do
    pages = Array.new(11) do |index|
      Character.create!(user: @owner, name: "Page #{index}", privacy: 'private').tap { |page| page.protect_with_password(PASSWORD) }
    end
    document = Document.create!(user: @owner, title: 'Doc', privacy: 'private')
    document.protect_with_password(PASSWORD)

    300.times do |index|
      unlock(pages[index % pages.size], password: 'wrong password', env: { 'REMOTE_ADDR' => "203.0.#{index / 200}.#{index % 200 + 1}" })
    end

    post unlock_document_path(document), params: { password: PASSWORD }, env: { 'REMOTE_ADDR' => '198.51.100.1' }
    assert_redirected_to document_path(document, too_many_attempts: 1)
  end

  test "other spellings of the unlock path can't dodge the limits" do
    id = @page.id

    [
      "/plan/characters/#{id}/unlock.json",
      "/plan/characters/#{id}/unlock/",
      "//plan/characters/#{id}/unlock",
      "/plan//characters/#{id}/unlock",
      "/plan/characters/0#{id}/unlock",
      "/plan/characters/#{id}abc/unlock",
      "/plan/characters/%3#{id.to_s[0]}#{id.to_s[1..]}/unlock",
      "/plan/characters/#{id}/%75nlock",
      "/PLAN/CHARACTERS/#{id}/UNLOCK"
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
        assert_nil session[:unlocked_pages], "#{path} got past the limits"
      rescue ActionController::RoutingError
        pass
      end
    end
  end

  test "the limits only look at unlock requests" do
    [
      ['/plan/characters/1', 'GET'],
      ['/plan/characters/1', 'PATCH'],
      ['/plan/characters/1/unlock', 'GET'],
      ['/plan/characters/1/password', 'PATCH'],
      ['/characters/1/unlock', 'POST'],
      ['/users/sign_in', 'POST']
    ].each do |path, method|
      request = Rack::Attack::Request.new(Rack::MockRequest.env_for(path, method: method))
      assert_nil Rack::Attack.page_unlock_key(request), "#{method} #{path} would touch Redis"
      assert_not Rack::Attack.unlock_attempt?(request), "#{method} #{path} would touch Redis"
    end

    request = Rack::Attack::Request.new(Rack::MockRequest.env_for('/plan/universes/7/unlock', method: 'POST'))
    assert_equal 'universes/7', Rack::Attack.page_unlock_key(request)
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
