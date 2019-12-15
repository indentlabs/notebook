class AddArchivedAtToFloras < ActiveRecord::Migration[5.2]
  def change
    add_column :floras, :archived_at, :datetime
  end
end
