require 'test_helper'

class WordsmithControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  FIXTURES = Rails.root.join('test', 'fixtures', 'files', 'wordsmith')

  test "requires sign in" do
    get wordsmith_lookup_path(q: 'grief')
    assert_redirected_to new_user_session_path
  end

  test "reports when the dictionary hasn't been imported" do
    sign_in users(:one)
    get wordsmith_lookup_path(q: 'grief')

    assert_response :success
    assert_equal({ 'available' => false }, response.parsed_body)
  end

  test "looks up words" do
    Wordsmith::Importer.new(
      wordnet_dir: FIXTURES.join('dict').to_s,
      cmu_file:    FIXTURES.join('cmu.js').to_s,
      moby_file:   FIXTURES.join('moby.txt').to_s,
      logger:      Logger.new(nil)
    ).import!

    sign_in users(:one)
    get wordsmith_lookup_path(q: 'Grief')

    assert_response :success
    body = response.parsed_body
    assert body['available']
    assert body['found']
    assert_equal 'grief', body['word']
    assert_equal %w(heartache heartbreak), body['senses'].first['synonyms']
  end
end
