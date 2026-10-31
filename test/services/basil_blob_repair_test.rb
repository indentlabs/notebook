require "test_helper"

# Basil blobs whose stored checksum doesn't match the PNG (e.g. a multipart
# S3 ETag, which FixBasilBlobChecksums couldn't convert) are repaired from
# the file the first time a variant is built, instead of raising
# ActiveStorage::IntegrityError and serving a 500.
class BasilBlobRepairTest < ActionDispatch::IntegrationTest
  setup do
    @data = File.binread(Rails.root.join("test/fixtures/files/gallery_test.png"))
    @services = BasilBlobRepair.services
    # Blobs in tests live on the Disk "test" service; treat it as Basil's.
    BasilBlobRepair.services = [ActiveStorage::Blob.service.name.to_s]
  end

  teardown do
    BasilBlobRepair.services = @services
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

  test "a variant of a Basil image with a multipart-ETag checksum is served and the checksum fixed" do
    commission = commission_with_checksum("#{Digest::MD5.hexdigest('parts')}-3")

    get_variant(commission)

    assert_response :success
    assert_equal Digest::MD5.base64digest(@data), commission.image.blob.reload.checksum
  end

  test "a well-formed but wrong checksum is repaired too" do
    commission = commission_with_checksum(Digest::MD5.base64digest("something else"))

    get_variant(commission)

    assert_response :success
    assert_equal Digest::MD5.base64digest(@data), commission.image.blob.reload.checksum
  end

  test "blobs on other services still raise" do
    BasilBlobRepair.services = %w(amazon_basil)
    commission = commission_with_checksum(Digest::MD5.base64digest("something else"))

    assert_raises(ActiveStorage::IntegrityError) { get_variant(commission) }
    assert_equal Digest::MD5.base64digest("something else"), commission.image.blob.reload.checksum
  end

  test "repair! leaves a correct blob alone" do
    blob = commission_with_checksum(Digest::MD5.base64digest(@data)).image.blob

    assert_not BasilBlobRepair.repair!(blob)
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
    blob = commission_with_checksum("#{Digest::MD5.hexdigest('parts')}-3").image.blob
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
    assert_equal "#{Digest::MD5.hexdigest('parts')}-3", checksum

    repaired, = repair_with_s3(download: @data.byteslice(0, 100), content_length: @data.bytesize, etag: %("x-2"))
    assert_not repaired, "a truncated download is rejected"
  end
end
