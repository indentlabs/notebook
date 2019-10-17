class AddArchivedAtToBuildings < ActiveRecord::Migration[5.2]
  def change
    add_column :buildings, :archived_at, :datetime
  end
end
