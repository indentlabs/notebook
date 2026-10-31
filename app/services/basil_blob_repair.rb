# Repairs the stored checksum of a Basil image blob so it matches the PNG
# that is actually in S3.
#
# ActiveStorage verifies a blob's checksum each time it downloads the
# original to build a variant (resized, cropped or WebP), and raises
# ActiveStorage::IntegrityError on a mismatch. For Basil images the stored
# checksum was never a real fingerprint of the file: for years it was copied
# from S3's ETag, which is hex rather than base64, and for multipart uploads
# isn't an MD5 at all. FixBasilBlobChecksums converted the plain hex ETags,
# but it couldn't fix the rest without downloading every image, so those
# variants still failed with a 500 and showed a broken image.
#
# Basil images are written by us and never changed, so the object in S3 is
# the source of truth. Before trusting a download we check it against what
# S3 reports for the object (size, and MD5 when the ETag is one), so a
# corrupted transfer is never written into the database as the new checksum.
class BasilBlobRepair
  # Storage services whose blobs this may repair. Uploads from users keep
  # ActiveStorage's normal behaviour: there a mismatch means real corruption.
  mattr_accessor :services, default: %w(amazon_basil)

  BASE64_MD5 = %r{\A[A-Za-z0-9+/]{22}==\z}
  HEX_MD5    = /\A\h{32}\z/

  def self.repairable?(blob)
    services.include?(blob.service_name.to_s)
  end

  # True if +checksum+ can't be a valid ActiveStorage checksum, which means
  # the blob will certainly fail its integrity check.
  def self.malformed_checksum?(checksum)
    !checksum.to_s.match?(BASE64_MD5)
  end

  def self.repair!(blob)
    new(blob).repair!
  end

  def initialize(blob)
    @blob = blob
  end

  # Downloads the object and, if the stored checksum doesn't match it,
  # rewrites the checksum (and byte size). Returns true when the blob was
  # changed, false when it already matched or the download couldn't be
  # trusted.
  def repair!
    return false unless self.class.repairable?(@blob)

    data = @blob.service.download(@blob.key)
    return false unless matches_stored_object?(data)

    checksum = Digest::MD5.base64digest(data)
    return false if checksum == @blob.checksum && data.bytesize == @blob.byte_size

    Rails.logger.warn(
      "[BasilBlobRepair] blob #{@blob.id} (#{@blob.key}): checksum #{@blob.checksum.inspect} -> #{checksum.inspect}, " \
      "byte_size #{@blob.byte_size} -> #{data.bytesize}"
    )
    @blob.update_columns(checksum: checksum, byte_size: data.bytesize)
    true
  end

  private

  # Compares the downloaded bytes with S3's own record of the object. Other
  # services (Disk in tests) have nothing to compare against.
  def matches_stored_object?(data)
    return true unless @blob.service.respond_to?(:bucket)

    object = @blob.service.bucket.object(@blob.key)
    return false unless object.content_length == data.bytesize

    etag = object.etag.to_s.delete('"')
    !etag.match?(HEX_MD5) || etag == Digest::MD5.hexdigest(data)
  end
end
