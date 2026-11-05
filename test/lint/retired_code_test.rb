require 'test_helper'

# Methods, helpers and constants we've removed, so nothing can call them again.
#
# Ruby only notices a call to a missing method when that line runs, which is
# often a page nobody tested, in production. When you delete or rename a
# method, helper, route name or constant, add its old name here with what to
# use instead. Copy-paste from an old branch then fails CI instead of 500ing.
class RetiredCodeTest < ActiveSupport::TestCase
  RETIRED = {
    # The image helpers that predate ContentImage / content_image_tag were
    # retired in the gallery rework (docs/gallery_ux_plan.md, section 7.8).
    'Use cover_image / cover_image_url / content_image_tag instead' => %w[
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
    ],

    # Route helpers that don't exist (see `bin/rails routes`).
    'The API docs live at api_documentation_path (/api/docs)'     => %w[api_docs_path api_docs_url],
    'Application integration routes are api_applications_path / api_application_path' =>
      %w[application_integrations_path application_integrations_url application_integration_path application_integration_url],
    'Revisions are read-only: index, show, diff, restore and destroy' =>
      %w[new_document_document_revision_path edit_document_document_revision_path],

    # Thread announcements on approval moved from the topic to its first post, so approving a
    # reported first post (which doesn't change the topic) announces the thread too.
    'Use Thredded::Post#announce_thread_on_first_post_approval' => %w[notify_discord_of_approval],

    # The easy_translate gem was removed along with the Babel lab.
    'The easy_translate gem is no longer installed' => %w[EasyTranslate],
  }.freeze

  SEARCHED_FILES = 'app/**/*.{rb,erb,builder,js,scss,jbuilder}'.freeze

  test "no application code uses retired methods, helpers or constants" do
    offenders = []
    Dir[Rails.root.join(SEARCHED_FILES)].each do |path|
      content = File.read(path)
      RETIRED.each do |hint, names|
        names.each do |name|
          next unless content.match?(/\b#{Regexp.escape(name)}\b/)

          offenders << "#{path.sub("#{Rails.root}/", '')}: #{name} (#{hint})"
        end
      end
    end

    assert_empty offenders, "These were removed and will raise at runtime:\n  #{offenders.join("\n  ")}"
  end

  test "retired route helpers really are gone" do
    helpers = Rails.application.routes.url_helpers
    still_defined = RETIRED.values.flatten.select { |name| name.end_with?('_path', '_url') && helpers.respond_to?(name) }

    assert_empty still_defined, "These route helpers exist again, so take them off RetiredCodeTest::RETIRED: #{still_defined.join(', ')}"
  end
end
