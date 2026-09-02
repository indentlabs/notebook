require 'test_helper'

class HasCoverRolesTest < ActiveSupport::TestCase
  setup do
    @image = image_uploads(:regular)
  end

  test "defaults to no roles" do
    assert_equal [], @image.cover_for
    assert_not @image.cover_for?(:banner)
  end

  test "keeps only known shapes, as unique strings" do
    @image.cover_for = [:banner, 'banner', 'square', 'hexagon', nil]

    assert_equal %w[banner square], @image.cover_for
    assert @image.cover_for?('banner')
    assert @image.cover_for?(:square)
    assert_not @image.cover_for?(:card)
  end

  test "survives a JSON string from the database adapter" do
    @image.update_columns(cover_for: '["card"]')

    assert_equal ['card'], @image.reload.cover_for
  end

  test "cover_image prefers the shape-specific choice, then the pin, then the first image" do
    character = characters(:one)
    character.update!(user: users(:one))
    regular = image_uploads(:regular)
    pinned  = image_uploads(:pinned)
    [regular, pinned, image_uploads(:private)].each { |img| img.update_columns(src_file_name: 'x.png') }
    regular.update_columns(cover_for: ['banner'])

    assert_equal regular.id, character.cover_image(preset: :banner).id
    assert_equal pinned.id,  character.cover_image(preset: :square).id
    assert_equal pinned.id,  character.cover_image.id

    pinned.update_columns(pinned: false)
    character.clear_cover_image_cache
    assert_equal regular.id, character.cover_image(preset: :square).id, 'falls back to the first image'
  end

  test "Basil commissions can hold roles too" do
    commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: 'x', job_id: 'j', saved_at: Time.current)
    commission.cover_for = ['card']
    commission.save!

    assert commission.reload.cover_for?(:card)
  end
end
