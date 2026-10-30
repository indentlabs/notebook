# Basil images were stored with S3's hex ETag as their ActiveStorage
# checksum. ActiveStorage expects a base64 MD5 and raises IntegrityError when
# it downloads the original to build a variant, so every resized or cropped
# Basil image on a page came back broken. Convert the stored values.
class FixBasilBlobChecksums < ActiveRecord::Migration[6.1]
  class Blob < ActiveRecord::Base
    self.table_name = 'active_storage_blobs'
  end

  HEX_MD5 = /\A\h{32}\z/

  def up
    Blob.where(service_name: 'amazon_basil').where('LENGTH(checksum) = 32').find_each do |blob|
      next unless blob.checksum.match?(HEX_MD5)

      blob.update_column(:checksum, Base64.strict_encode64([blob.checksum].pack('H*')))
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
