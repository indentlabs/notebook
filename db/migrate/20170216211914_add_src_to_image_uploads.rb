class AddSrcToImageUploads < ActiveRecord::Migration[4.2]
  def self.up
  	add_attachment :image_uploads, :src
  end

  def self.down
  	remove_attachment :image_uploads, :src
  end
end
