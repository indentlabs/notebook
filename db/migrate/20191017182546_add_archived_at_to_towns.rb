class AddArchivedAtToTowns < ActiveRecord::Migration[5.2]
  def change
    add_column :towns, :archived_at, :datetime
  end
end
