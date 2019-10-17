class AddArchivedAtToLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :locations, :archived_at, :datetime
  end
end
