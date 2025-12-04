class AddPositionToImageUploads < ActiveRecord::Migration[6.1]
  def change
    add_column :image_uploads, :position, :integer
    add_index :image_uploads, [:content_type, :content_id, :position]
    
    # Backfill existing image_uploads with positions based on creation date
    reversible do |dir|
      dir.up do
        if connection.adapter_name.downcase.include?('postgres')
          # PostgreSQL-specific approach using window functions
          execute <<-SQL
            UPDATE image_uploads
            SET position = t.seq
            FROM (
              SELECT id, ROW_NUMBER() OVER (
                PARTITION BY content_type, content_id
                ORDER BY created_at ASC, id ASC
              ) as seq
              FROM image_uploads
            ) as t
            WHERE image_uploads.id = t.id
          SQL
        else
          # Database-agnostic approach using Ruby
          say_with_time("Backfilling positions for ImageUploads") do
            ImageUpload.all.group_by { |img| [img.content_type, img.content_id] }.each do |group_key, images|
              ordered_images = images.sort_by { |img| [img.created_at || Time.current, img.id] }
              ordered_images.each_with_index do |img, idx|
                img.update_column(:position, idx + 1)
              end
            end
          end
        end
      end
    end
  end
end
