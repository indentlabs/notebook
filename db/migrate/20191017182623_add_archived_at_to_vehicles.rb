class AddArchivedAtToVehicles < ActiveRecord::Migration[5.2]
  def change
    add_column :vehicles, :archived_at, :datetime
  end
end
