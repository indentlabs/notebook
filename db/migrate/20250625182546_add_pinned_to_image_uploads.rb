class AddPinnedToImageUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :image_uploads, :pinned, :boolean, default: false
    add_index :image_uploads, [:content_type, :content_id, :pinned], name: 'index_image_uploads_on_content_pinned'
  end
end
