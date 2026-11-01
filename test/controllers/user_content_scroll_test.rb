require 'test_helper'

class UserContentScrollTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user.update!(private_profile: false)
    sign_in @user
    @user.characters.destroy_all
    21.times do
      @user.characters.create!(name: 'Same name', privacy: 'public')
    end
    @user.characters.create!(name: 'Private character', privacy: 'private')
  end

  test 'HTML offers a fallback and JSON returns bounded batches in both layouts' do
    get "/users/#{@user.id}/characters"
    assert_response :success
    assert_select '#content-grid .content-card', count: 20
    assert_select '#content-load-more'

    get "/users/#{@user.id}/characters", headers: { 'Accept' => 'application/json' }
    assert_response :success
    batch = response.parsed_body
    html = Nokogiri::HTML.fragment(batch.fetch('html'))
    assert_equal 20, html.css('#content-grid .content-card').size
    assert_equal 20, html.css('#content-list > div').size
    assert_not_includes batch.fetch('html'), 'Private character'
    assert_not_includes batch.fetch('html'), '<script>'
    first_links = html.css('.content-card-link').map { |link| link['href'] }

    get batch.fetch('next_url'), headers: { 'Accept' => 'application/json' }
    assert_response :success
    last_batch = response.parsed_body
    last_html = Nokogiri::HTML.fragment(last_batch.fetch('html'))
    assert_equal 1, last_html.css('#content-grid .content-card').size
    assert_nil last_batch['next_url']
    assert_empty first_links & last_html.css('.content-card-link').map { |link| link['href'] }
  end

  test 'JSON requests still respect private profiles' do
    @user.update!(private_profile: true)
    get "/users/#{@user.id}/characters", headers: { 'Accept' => 'application/json' }
    assert_response :redirect
  end
end
