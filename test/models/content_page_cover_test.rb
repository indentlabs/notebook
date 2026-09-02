require 'test_helper'

# User#content returns generic ContentPage rows; they must resolve covers too.
class ContentPageCoverTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
    @character.update!(user: @user)
    UserContentTypeActivator.find_or_create_by!(user: @user, content_type: 'Character')
    image_uploads(:pinned).update_columns(src_file_name: 'pinned.png')
  end

  test "a generic ContentPage row resolves the same cover as the real record" do
    rows = @user.content(content_types: ['Character'], universe_id: nil)['Character']
    row = rows.find { |page| page.id == @character.id }

    assert_kind_of ContentPage, row
    assert_equal 'Character', row.page_type
    assert_equal image_uploads(:pinned).id, row.cover_image(include_private: true).id
    assert row.cover_image?(include_private: true)
    assert_includes row.cover_image_url(:card, include_private: true), '/'
  end

  test "preloaded galleries are used without further queries" do
    row = @user.content(content_types: ['Character'], universe_id: nil)['Character'].find { |page| page.id == @character.id }
    row.preload_gallery([image_uploads(:regular).tap { |u| u.src_file_name = 'r.png' }], [])

    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') { |*, payload| queries << payload[:sql] unless payload[:name] == 'SCHEMA' }
    cover = row.cover_image(include_private: true)
    ActiveSupport::Notifications.unsubscribe(subscriber)

    assert_equal image_uploads(:regular).id, cover.id
    assert_empty queries.select { |sql| sql.include?('image_uploads') }
  end
end
