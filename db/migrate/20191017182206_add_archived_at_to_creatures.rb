class AddArchivedAtToCreatures < ActiveRecord::Migration[5.2]
  def change
    add_column :creatures, :archived_at, :datetime
  end
end
