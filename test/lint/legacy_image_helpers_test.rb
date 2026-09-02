require 'test_helper'

# The image helpers that predate ContentImage / content_image_tag were
# retired in the gallery rework (docs/gallery_ux_plan.md, section 7.8).
# This keeps them from creeping back in through copy-paste.
class LegacyImageHelpersTest < ActiveSupport::TestCase
  RETIRED = %w[
    random_image_including_private
    pinned_or_random_image_including_private
    random_public_image
    first_public_image
    custom_thumbnail_url
    custom_public_thumbnail_url
    pinned_image_upload
    pinned_public_image
    extract_image_url
    public_image_uploads
    private_image_uploads
    get_preview_image
    combine_and_sort_gallery_images
    random_image_including_private_pool_cache
    random_image_pool_cache
    saved_basil_commissions
  ].freeze

  test "no application code calls a retired image helper" do
    offenders = []
    Dir[Rails.root.join('app/**/*.{rb,erb,builder,js,scss}')].each do |path|
      content = File.read(path)
      RETIRED.each do |name|
        next unless content.match?(/\b#{Regexp.escape(name)}\b/)
        offenders << "#{path.sub(Rails.root.to_s + '/', '')}: #{name}"
      end
    end

    assert_empty offenders, "Use cover_image / cover_image_url / content_image_tag instead:\n  #{offenders.join("\n  ")}"
  end
end
