class AddSrcToImageUploads < ActiveRecord::Migration
  def self.up
  	add_attachment :image_uploads, :src
  end

  def self.down
  	remove_attachment :image_uploads, :src
  end
end
