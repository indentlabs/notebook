class AddNotesToImageUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :image_uploads, :notes, :text
  end
end
