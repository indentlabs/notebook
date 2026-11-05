require 'test_helper'

# User#image_url is on nearly every page (100 times on a followers page), so it must build the avatar URL without
# going to storage. The resized avatar is made when the browser first asks for it.
class UserAvatarUrlTest < ActionDispatch::IntegrationTest
  setup do
    @user = create_user_without_follows(email: 'avatar-url@example.com')
  end

  test "an uploaded avatar's URL is built without touching storage, and serves the resized avatar" do
    @user.avatar.attach(io: file_fixture('gallery_test.png').open, filename: 'avatar.png', content_type: 'image/png')
    @user.reload

    url = nil
    storage_calls = storage_events { url = @user.image_url(size: 80) }

    assert_empty storage_calls, 'building the URL should not check or process the variant'
    assert_match %r{\A/rails/active_storage/representations/}, url

    get url
    assert_response :redirect, 'the representation endpoint makes the variant on first request'
    assert @user.avatar.variant(resize_to_fill: [80, 80]).send(:processed?)
  end

  test "users without an avatar get their Gravatar" do
    assert_match %r{\Ahttps://www\.gravatar\.com/avatar/\h{32}\?d=identicon&s=80\z}, @user.image_url(size: 80)
  end

  test "an avatar that can't be resized falls back to Gravatar instead of raising" do
    # Uploads are limited to images now, so attach it the way an older upload would have been stored
    blob = ActiveStorage::Blob.create_and_upload!(io: file_fixture('not_an_image.txt').open, filename: 'avatar.txt', content_type: 'text/plain')
    ActiveStorage::Attachment.create!(record: @user, name: 'avatar', blob: blob)

    assert_match %r{\Ahttps://www\.gravatar\.com/avatar/}, @user.reload.image_url
  end

  private

  def storage_events
    events = []
    callback = ->(name, *) { events << name }
    ActiveSupport::Notifications.subscribed(callback, /active_storage\z/) { yield }
    events
  end
end
