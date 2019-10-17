class AddArchivedAtToDeities < ActiveRecord::Migration[5.2]
  def change
    add_column :deities, :archived_at, :datetime
  end
end
