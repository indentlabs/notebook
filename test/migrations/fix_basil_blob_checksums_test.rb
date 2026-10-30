require "test_helper"
require Rails.root.join("db/migrate/20260928120000_fix_basil_blob_checksums")

class FixBasilBlobChecksumsTest < ActionDispatch::IntegrationTest
  setup do
    @data = File.binread(Rails.root.join("test/fixtures/files/gallery_test.png"))
  end

  # A Basil commission whose blob was stored the old way: checksum = S3 ETag.
  def basil_commission_with_etag_checksum
    key = "job-#{SecureRandom.hex(4)}.png"
    ActiveStorage::Blob.service.upload(key, StringIO.new(@data))
    blob = ActiveStorage::Blob.create!(
      key: key, filename: key, content_type: "image/png", byte_size: @data.bytesize,
      checksum: Digest::MD5.hexdigest(@data), service_name: ActiveStorage::Blob.service.name
    )
    commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: "x", job_id: SecureRandom.hex(3))
    commission.image.attach(blob)
    commission
  end

  # The migration only looks at blobs on the Basil service; the test service
  # serves the files, so flip the name just around the migration.
  def migrate_as_basil(blob)
    blob.update_column(:service_name, "amazon_basil")
    FixBasilBlobChecksums.new.tap { |m| m.verbose = false }.migrate(:up)
    blob.reload.update_column(:service_name, ActiveStorage::Blob.service.name)
  end

  test "rewrites hex checksums on Basil blobs and leaves others alone" do
    commission = basil_commission_with_etag_checksum
    blob = commission.image.blob
    other = ActiveStorage::Blob.create!(key: "other", filename: "o.png", content_type: "image/png",
                                        byte_size: 1, checksum: Digest::MD5.hexdigest("x"),
                                        service_name: ActiveStorage::Blob.service.name)

    migrate_as_basil(blob)

    assert_equal Digest::MD5.base64digest(@data), blob.reload.checksum
    assert_equal Digest::MD5.hexdigest("x"), other.reload.checksum, "non-Basil blobs are untouched"

    migrate_as_basil(blob)
    assert_equal Digest::MD5.base64digest(@data), blob.reload.checksum, "running twice is harmless"
  end

  test "a repaired Basil image serves its resized variant" do
    commission = basil_commission_with_etag_checksum

    assert_raises(ActiveStorage::IntegrityError) do
      get ContentImage.wrap(commission).url(:large)
      follow_redirect! while response.redirect?
    end

    migrate_as_basil(commission.image.blob)

    get ContentImage.wrap(commission.reload).url(:large)
    follow_redirect! while response.redirect?
    assert_response :success
  end
end
