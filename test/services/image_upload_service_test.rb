require 'test_helper'

class ImageUploadServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
    @character.update!(user: @user)
    @user.update!(upload_bandwidth_kb: 500)
  end

  test "stores the image, charges the quota and defaults to public" do
    result = ImageUploadService.upload(user: @user, content: @character, file: png_upload)

    assert result.success?, result.error
    assert result.image.persisted?
    assert_equal 'Character', result.image.content_type
    assert_equal @character.id, result.image.content_id
    assert_equal @user, result.image.user
    assert_equal 'public', result.image.privacy
    assert_equal 500 - (png_upload.size / 1000.0).ceil, @user.reload.upload_bandwidth_kb
  end

  test "honours a private privacy setting and ignores unknown values" do
    private_result = ImageUploadService.upload(user: @user, content: @character, file: png_upload, privacy: 'private')
    assert_equal 'private', private_result.image.privacy

    odd_result = ImageUploadService.upload(user: @user, content: @character, file: png_upload, privacy: 'friends')
    assert_equal 'public', odd_result.image.privacy
  end

  test "refuses uploads that exceed the remaining quota without charging" do
    @user.update!(upload_bandwidth_kb: 0)

    result = ImageUploadService.upload(user: @user, content: @character, file: png_upload)

    assert_not result.success?
    assert_match(/upload bandwidth/, result.error)
    assert_equal 0, @user.reload.upload_bandwidth_kb
  end

  test "refunds the quota when the file is rejected" do
    result = ImageUploadService.upload(user: @user, content: @character, file: text_upload)

    assert_not result.success?
    assert_match(/not_an_image\.txt/, result.error)
    assert_equal 500, @user.reload.upload_bandwidth_kb
  end

  test "fails cleanly when no file is given" do
    result = ImageUploadService.upload(user: @user, content: @character, file: nil)

    assert_not result.success?
    assert_equal 'No file was sent.', result.error
  end

  private

  def png_upload
    Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/gallery_test.png'), 'image/png')
  end

  def text_upload
    Rack::Test::UploadedFile.new(Rails.root.join('test/fixtures/files/not_an_image.txt'), 'text/plain')
  end
end
