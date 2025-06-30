class AddPaperclipColumnsToImageUploads < ActiveRecord::Migration[6.1]
  # This is a super janky, sus migration. Paperclip is already working just fine in production,
  # but errors on multiple new development machines due to allegedly not having these columns in
  # the DB schema. So... we're adding them here, but only if they don't already exist.

  def up
    # Only add columns if they don't already exist
    add_column :image_uploads, :src_file_name, :string unless column_exists?(:image_uploads, :src_file_name)
    add_column :image_uploads, :src_content_type, :string unless column_exists?(:image_uploads, :src_content_type)
    add_column :image_uploads, :src_file_size, :integer unless column_exists?(:image_uploads, :src_file_size)
    add_column :image_uploads, :src_updated_at, :datetime unless column_exists?(:image_uploads, :src_updated_at)
  end

  def down
    # Only remove columns if they exist
    remove_column :image_uploads, :src_file_name if column_exists?(:image_uploads, :src_file_name)
    remove_column :image_uploads, :src_content_type if column_exists?(:image_uploads, :src_content_type)
    remove_column :image_uploads, :src_file_size if column_exists?(:image_uploads, :src_file_size)
    remove_column :image_uploads, :src_updated_at if column_exists?(:image_uploads, :src_updated_at)
  end
end
