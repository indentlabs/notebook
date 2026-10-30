require 'test_helper'
require 'minitest/mock'

class RemainingAccessTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  SECRET = 'SECRETNAME'

  setup do
    @owner    = users(:one)
    @stranger = users(:two)
    ContentPageShare.update_all(deleted_at: Time.current)
  end

  def with_env(values)
    original = values.keys.map { |key| [key, ENV[key]] }.to_h
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    original.each { |key, value| ENV[key] = value }
  end

  def basic_auth(username, password)
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
  end

  test "the API doesn't show a private timeline to other people" do
    ApplicationIntegration.create!(user: @owner, name: 'Integration')
    timeline = Timeline.create!(user: @owner, name: SECRET, privacy: 'private')
    timeline.timeline_events.first.update!(title: SECRET)
    sign_in @stranger

    get "/api/v1/timeline/#{timeline.id}"

    assert_not_includes response.body, SECRET
  end

  test "the API still shows a timeline to its owner and handles a missing one" do
    ApplicationIntegration.create!(user: @owner, name: 'Integration')
    timeline = Timeline.create!(user: @owner, name: SECRET, privacy: 'private')
    sign_in @owner

    get "/api/v1/timeline/#{timeline.id}"
    assert_includes response.body, SECRET

    get '/api/v1/timeline/0'
    assert_response :success
  end

  test "a private universe's page lists are only for people who can read the universe" do
    universe = Universe.create!(user: @owner, name: SECRET, privacy: 'private')

    get locations_universe_path(universe)
    assert_redirected_to root_path
    assert_not_includes response.body, SECRET

    sign_in @stranger
    get locations_universe_path(universe)
    assert_redirected_to root_path
    assert_not_includes response.body, SECRET
    sign_out @stranger

    sign_in @owner
    get locations_universe_path(universe)
    assert_response :success
    assert_includes response.body, SECRET
    sign_out @owner

    Contributor.create!(universe: universe, user: @stranger, email: @stranger.email)
    # A fresh copy, since the earlier request remembered which universes this user could contribute to
    sign_in User.find(@stranger.id)
    get locations_universe_path(universe)
    assert_response :success
  end

  test "the character export only includes private images for the character's owner" do
    character = Character.create!(user: @owner, name: 'Public', privacy: 'public')
    included_private = nil
    character.define_singleton_method(:cover_image_url) do |*_args, **options|
      included_private = options[:include_private]
      nil
    end

    Character.stub(:find, character) do
      sign_in @stranger
      post export_character_path(character), params: { name: 'Public', description: 'Someone' }
      assert_equal false, included_private

      sign_out @stranger
      sign_in @owner
      post export_character_path(character), params: { name: 'Public', description: 'Someone' }
      assert_equal true, included_private
    end
  end

  test "the Sidekiq dashboard has no default password" do
    with_env('SIDEKIQ_USERNAME' => nil, 'SIDEKIQ_PASSWORD' => nil) do
      get '/sidekiq', headers: basic_auth('admin', 'password')
      assert_response :unauthorized

      get '/sidekiq', headers: basic_auth('', '')
      assert_response :unauthorized
    end
  end

  test "the Sidekiq dashboard works with the configured password" do
    with_env('SIDEKIQ_USERNAME' => 'configured', 'SIDEKIQ_PASSWORD' => 'secret') do
      get '/sidekiq', headers: basic_auth('admin', 'password')
      assert_response :unauthorized

      begin
        get '/sidekiq', headers: basic_auth('configured', 'secret')
        assert_not_equal 401, response.status
      rescue RedisClient::CannotConnectError
        # The dashboard needs Redis, so getting as far as connecting means the password was accepted
      end
    end
  end

  test "searching the stream doesn't match email addresses" do
    skip 'The stream search uses ILIKE, which only Postgres has' unless ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

    page = Character.create!(user: @owner, name: 'SHAREDPAGENAME', privacy: 'public')
    ContentPageShare.create!(user: @owner, content_page: page, message: 'SEARCHABLEMESSAGE', shared_at: DateTime.current)
    sign_in @stranger

    get stream_world_path, params: { search: @owner.email }
    assert_response :success
    assert_not_includes response.body, 'SHAREDPAGENAME'

    sign_in @stranger
    get stream_world_path, params: { search: 'SEARCHABLEMESSAGE' }
    assert_includes response.body, 'SHAREDPAGENAME'
  end
end
