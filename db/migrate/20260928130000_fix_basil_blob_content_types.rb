# Basil images attached from S3 by BasilController#complete_commission (and
# the old data_migrations:attach_s3_images_to_basil_commissions task) copied
# S3's content type, which was binary/octet-stream. ActiveStorage only builds
# variants for image/* types, so those images were served as full-size
# originals and ignored any crop. Every Basil image is a PNG.
class FixBasilBlobContentTypes < ActiveRecord::Migration[6.1]
  class Blob < ActiveRecord::Base
    self.table_name = 'active_storage_blobs'
  end

  def up
    Blob.where(service_name: 'amazon_basil')
        .where("content_type IS NULL OR content_type NOT LIKE 'image/%'")
        .where("filename LIKE '%.png'")
        .update_all(content_type: 'image/png')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
