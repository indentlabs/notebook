class AddArchivedAtToScenes < ActiveRecord::Migration[5.2]
  def change
    add_column :scenes, :archived_at, :datetime
  end
end
