class AddArchivedAtToContentPages < ActiveRecord::Migration[5.2]
  def change
    add_column :content_pages, :archived_at, :datetime
  end
end
