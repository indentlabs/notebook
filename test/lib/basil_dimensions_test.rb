require 'test_helper'
require 'rake'

class BasilDimensionsTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks unless Rake::Task.task_defined?('gallery:backfill_basil_dimensions')
    Rake::Task['gallery:backfill_basil_dimensions'].reenable
    @png = File.binread(Rails.root.join('test/fixtures/files/gallery_test.png'))
  end

  test "png_dimensions reads the size from a PNG header" do
    assert_equal [64, 40], BasilCommission.png_dimensions(@png)
    assert_nil BasilCommission.png_dimensions(File.binread(Rails.root.join('test/fixtures/files/gallery_test.jpg')))
    assert_nil BasilCommission.png_dimensions('')
  end

  test "backfill_basil_dimensions records sizes so saved crops apply" do
    commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: 'x', job_id: 'j', saved_at: Time.current)
    blob = ActiveStorage::Blob.create_and_upload!(io: StringIO.new(@png), filename: 'basil.png',
                                                 content_type: 'image/png', service_name: 'test')
    commission.image.attach(blob)
    commission.update!(crops: { 'banner' => { 'x' => 0, 'y' => 0.2, 'w' => 1, 'h' => 0.5333 } })
    assert_nil commission.reload.crop_pixels_for(:banner), "without a size the crop can't be applied"

    assert_output(/Recorded dimensions for 1 Basil image/) { Rake::Task['gallery:backfill_basil_dimensions'].invoke }

    commission.reload
    assert_equal [64, 40], [commission.width, commission.height]
    assert_equal [0, 8, 64, 21], commission.crop_pixels_for(:banner)
  end
end
