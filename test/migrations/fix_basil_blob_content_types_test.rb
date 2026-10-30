require "test_helper"
require Rails.root.join("db/migrate/20260928130000_fix_basil_blob_content_types")

class FixBasilBlobContentTypesTest < ActiveSupport::TestCase
  def blob(service:, filename:, content_type:)
    ActiveStorage::Blob.create!(key: SecureRandom.hex(6), filename: filename, content_type: content_type,
                                byte_size: 1, checksum: "x", service_name: ActiveStorage::Blob.service.name)
                       .tap { |b| b.update_column(:service_name, service) }
  end

  test "Basil PNGs stored as binary/octet-stream become image/png" do
    octet   = blob(service: "amazon_basil", filename: "job-1.png", content_type: "binary/octet-stream")
    already = blob(service: "amazon_basil", filename: "job-2.png", content_type: "image/png")
    other   = blob(service: "amazon", filename: "doc.png", content_type: "binary/octet-stream")

    FixBasilBlobContentTypes.new.tap { |m| m.verbose = false }.migrate(:up)

    assert_equal "image/png", octet.reload.content_type
    assert_equal "image/png", already.reload.content_type
    assert_equal "binary/octet-stream", other.reload.content_type, "non-Basil blobs are untouched"
  end
end
