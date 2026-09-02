require 'test_helper'

class ContentCoverServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @character = characters(:one)
    @character.update!(user: @user)
    @first  = image_uploads(:regular)
    @pinned = image_uploads(:pinned)
    @basil  = BasilCommission.create!(user: @user, entity: @character, prompt: 'x', job_id: 'j', saved_at: Time.current)
  end

  test "pinning an image unpins every other image of the page" do
    result = ContentCoverService.toggle!(@first)

    assert result.pinned
    assert @first.reload.pinned
    assert_not @pinned.reload.pinned
  end

  test "unpinning leaves other images alone" do
    result = ContentCoverService.toggle!(@pinned)

    assert_not result.pinned
    assert_not @pinned.reload.pinned
  end

  test "a shape role moves between images, one holder per shape" do
    ContentCoverService.toggle!(@first, preset: :banner)
    assert_equal ['banner'], @first.reload.cover_for

    result = ContentCoverService.toggle!(@basil, preset: 'banner')
    assert result.active
    assert_equal ['banner'], @basil.reload.cover_for
    assert_equal [], @first.reload.cover_for, 'the previous banner holder is cleared'
  end

  test "toggling a held role off removes only that role" do
    @first.update_columns(cover_for: %w[banner square])

    result = ContentCoverService.toggle!(@first, preset: :banner)

    assert_not result.active
    assert_equal ['square'], @first.reload.cover_for
    assert_equal ['square'], result.cover_for
  end

  test "roles do not touch the pin and the pin does not touch roles" do
    @first.update_columns(cover_for: ['square'])

    ContentCoverService.toggle!(@first)
    assert_equal ['square'], @first.reload.cover_for
    assert @first.pinned

    ContentCoverService.toggle!(@pinned, preset: :card)
    assert_not @pinned.reload.pinned
    assert @first.reload.pinned
  end

  test "unknown shapes are rejected" do
    assert_raises(ArgumentError) { ContentCoverService.toggle!(@first, preset: :hexagon) }
  end
end
