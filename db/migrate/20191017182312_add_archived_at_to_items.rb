class AddArchivedAtToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :archived_at, :datetime
  end
end
