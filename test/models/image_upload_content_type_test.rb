require 'test_helper'

class ImageUploadContentTypeTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
  end

  def upload_for(path, content_type)
    ImageUpload.new(
      user: @user,
      content_type: 'Character',
      content_id: @character.id,
      privacy: 'public',
      src: Rack::Test::UploadedFile.new(path, content_type)
    )
  end

  # Paperclip 6.1 hands its options hash to ActiveModel::Errors#add positionally,
  # which Ruby 3 no longer converts to keyword arguments. Before we patched the
  # validators (config/initializers/paperclip_ruby3_compat.rb), *recording* this
  # rejection raised ArgumentError, so uploading a non-image 500'd the whole page
  # update rather than failing the one attachment.
  test "rejecting a non-image records a validation error instead of raising" do
    Tempfile.create(['not-an-image', '.pdf']) do |file|
      file.write('%PDF-1.4 definitely not an image')
      file.rewind

      upload = upload_for(file.path, 'application/pdf')

      assert_nothing_raised { upload.valid? }
      assert_not upload.valid?, "A PDF should not pass the image content type validation"
      assert_includes upload.errors[:src].join(' '), 'must be an image file'
    end
  end

  # ContentController#upload_files reads errors[:src] to tell the user which file
  # was turned away and why, so the message has to land on that attribute.
  test "the rejection message is readable enough to show the uploader" do
    Tempfile.create(['not-an-image', '.pdf']) do |file|
      file.write('%PDF-1.4 definitely not an image')
      file.rewind

      upload = upload_for(file.path, 'application/pdf')
      upload.valid?

      assert_equal "must be an image file (like a jpg, png, gif, or webp)", upload.errors[:src].first
    end
  end

  test "an image still passes the content type validation" do
    # Style generation would shell out to ImageMagick, which this test doesn't
    # need — only the content type check is under test here.
    original = Paperclip::Attachment.default_options[:post_processing]
    Paperclip::Attachment.default_options[:post_processing] = false

    # A 1x1 transparent GIF.
    Tempfile.create(['an-image', '.gif'], binmode: true) do |file|
      file.write(Base64.decode64('R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7'))
      file.rewind

      assert upload_for(file.path, 'image/gif').valid?, "A GIF should pass the image content type validation"
    end
  ensure
    Paperclip::Attachment.default_options[:post_processing] = original
  end
end
