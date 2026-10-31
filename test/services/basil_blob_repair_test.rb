require "test_helper"

# Basil blobs whose stored checksum doesn't match the PNG (e.g. a multipart
# S3 ETag, which FixBasilBlobChecksums couldn't convert) raise
# ActiveStorage::IntegrityError whenever a variant is built. BasilBlobRepair
# and data_integrity:repair_basil_blob_checksums fix the stored checksum.
class BasilBlobRepairTest < ActionDispatch::IntegrationTest
  setup do
    @data = File.binread(Rails.root.join("test/fixtures/files/gallery_test.png"))
    @services = BasilBlobRepair.services
    # Blobs in tests live on the Disk "test" service; treat it as Basil's.
    BasilBlobRepair.services = [ActiveStorage::Blob.service.name.to_s]
    Rails.application.load_tasks unless Rake::Task.task_defined?("data_integrity:repair_basil_blob_checksums")
    Rake::Task["data_integrity:repair_basil_blob_checksums"].reenable
  end

  teardown do
    BasilBlobRepair.services = @services
    ENV.delete("ALL")
  end

  def commission_with_checksum(checksum)
    key = "job-#{SecureRandom.hex(4)}.png"
    ActiveStorage::Blob.service.upload(key, StringIO.new(@data))
    blob = ActiveStorage::Blob.create!(
      key: key, filename: key, content_type: "image/png", byte_size: @data.bytesize,
      checksum: checksum, service_name: ActiveStorage::Blob.service.name
    )
    commission = BasilCommission.create!(user: users(:one), entity: characters(:one), prompt: "x", job_id: SecureRandom.hex(3))
    commission.image.attach(blob)
    commission
  end

  def get_variant(commission)
    get ContentImage.wrap(commission).url(:large)
    follow_redirect! while response.redirect?
  end

  def run_task(all: false)
    ENV["ALL"] = "1" if all
    capture_io { Rake::Task["data_integrity:repair_basil_blob_checksums"].invoke }.first
  end

  MULTIPART_ETAG = "#{Digest::MD5.hexdigest('parts')}-3"
  WRONG_CHECKSUM = Digest::MD5.base64digest("something else")

  test "a repaired Basil image serves its resized variant" do
    commission = commission_with_checksum(MULTIPART_ETAG)
    assert_raises(ActiveStorage::IntegrityError) { get_variant(commission) }

    assert BasilBlobRepair.repair!(commission.image.blob)

    get_variant(commission.reload)
    assert_response :success
    assert_equal Digest::MD5.base64digest(@data), commission.image.blob.checksum
  end

  test "the task repairs malformed checksums by default and wrong ones with ALL=1" do
    malformed = commission_with_checksum(MULTIPART_ETAG).image.blob
    wrong     = commission_with_checksum(WRONG_CHECKSUM).image.blob

    output = run_task
    assert_equal Digest::MD5.base64digest(@data), malformed.reload.checksum
    assert_equal WRONG_CHECKSUM, wrong.reload.checksum, "well-formed checksums aren't downloaded by default"
    assert_match "repaired 1", output

    Rake::Task["data_integrity:repair_basil_blob_checksums"].reenable
    run_task(all: true)
    assert_equal Digest::MD5.base64digest(@data), wrong.reload.checksum
  end

  test "blobs on other services are left alone" do
    BasilBlobRepair.services = %w(amazon_basil)
    blob = commission_with_checksum(WRONG_CHECKSUM).image.blob

    assert_not BasilBlobRepair.repair!(blob)
    run_task(all: true)
    assert_equal WRONG_CHECKSUM, blob.reload.checksum
  end

  test "repair! leaves a correct blob alone" do
    blob = commission_with_checksum(Digest::MD5.base64digest(@data)).image.blob

    assert_not BasilBlobRepair.repair!(blob)
  end

  test "a broken Basil image still raises rather than being fixed on the fly" do
    commission = commission_with_checksum(WRONG_CHECKSUM)

    assert_raises(ActiveStorage::IntegrityError) { get_variant(commission) }
    assert_equal WRONG_CHECKSUM, commission.image.blob.reload.checksum
  end

  test "malformed_checksum? spots checksums that can never verify" do
    assert BasilBlobRepair.malformed_checksum?(Digest::MD5.hexdigest(@data))
    assert BasilBlobRepair.malformed_checksum?("#{Digest::MD5.hexdigest(@data)}-2")
    assert BasilBlobRepair.malformed_checksum?(nil)
    assert_not BasilBlobRepair.malformed_checksum?(Digest::MD5.base64digest(@data))
  end

  # Stands in for ActiveStorage's S3Service: a download plus S3's own
  # record of the object (size and ETag).
  FakeS3Service = Struct.new(:data, :content_length, :etag) do
    def download(_key) = data
    def bucket = self
    def object(_key) = self
  end

  def repair_with_s3(download:, content_length:, etag:)
    blob = commission_with_checksum(MULTIPART_ETAG).image.blob
    blob.define_singleton_method(:service) { FakeS3Service.new(download, content_length, etag) }
    [BasilBlobRepair.repair!(blob), blob.reload.checksum]
  end

  test "trusts an S3 download that matches the object's ETag and size" do
    repaired, checksum = repair_with_s3(download: @data, content_length: @data.bytesize,
                                        etag: %("#{Digest::MD5.hexdigest(@data)}"))
    assert repaired
    assert_equal Digest::MD5.base64digest(@data), checksum
  end

  test "trusts a download of a multipart object when the size matches" do
    repaired, = repair_with_s3(download: @data, content_length: @data.bytesize, etag: %("#{Digest::MD5.hexdigest('x')}-2"))
    assert repaired
  end

  test "never saves a checksum from a download that doesn't match S3" do
    corrupted = @data.dup.tap { |d| d[-1] = (d[-1].ord ^ 1).chr }

    repaired, checksum = repair_with_s3(download: corrupted, content_length: @data.bytesize,
                                        etag: %("#{Digest::MD5.hexdigest(@data)}"))
    assert_not repaired
    assert_equal MULTIPART_ETAG, checksum

    repaired, = repair_with_s3(download: @data.byteslice(0, 100), content_length: @data.bytesize, etag: %("x-2"))
    assert_not repaired, "a truncated download is rejected"
  end
end
