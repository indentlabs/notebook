require 'test_helper'

# Guards against the per-card image queries that list pages used to make.
class Content::IndexQueryCountTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @user.update!(upload_bandwidth_kb: 50_000)
    UserContentTypeActivator.find_or_create_by!(user: @user, content_type: 'Character')
    @uploads = []
    @characters = 12.times.map do |i|
      character = Character.create!(name: "Query Test #{i}", user: @user, privacy: 'private')
      @uploads << ImageUpload.create!(
        user: @user, content_type: 'Character', content_id: character.id, privacy: 'public',
        src: Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
      )
      character
    end
    sign_in @user
  end

  teardown do
    @uploads.each(&:destroy)
  end

  test "the character index loads images with a fixed number of queries" do
    queries = capture_queries { get characters_path }

    assert_response :success
    @characters.each { |c| assert_includes response.body, c.name }

    image_queries = queries.count { |sql| sql.include?('"image_uploads"') }
    basil_queries = queries.count { |sql| sql.include?('"basil_commissions"') }
    assert image_queries <= 3, "expected the image uploads to be preloaded, got #{image_queries} queries:\n#{queries.select { |q| q.include?('"image_uploads"') }.join("\n")}"
    assert basil_queries <= 3, "expected basil commissions to be preloaded, got #{basil_queries} queries"
  end

  test "the dashboard loads card images with a fixed number of queries" do
    queries = capture_queries { get '/my/dashboard' }

    assert_response :success
    image_queries = queries.count { |sql| sql.include?('"image_uploads"') }
    assert image_queries <= 6, "expected preloaded image uploads on the dashboard, got #{image_queries} queries"
  end

  private

  def capture_queries
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _finish, _id, payload|
      next if payload[:name] == 'SCHEMA' || payload[:cached]
      queries << payload[:sql]
    end
    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
