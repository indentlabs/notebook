class AddSrcToImageUploads < ActiveRecord::Migration[4.2]
  def self.up
    add_column  :image_uploads, :src, :string
  end
end
