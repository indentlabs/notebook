class AddArchivedAtToTraditions < ActiveRecord::Migration[5.2]
  def change
    add_column :traditions, :archived_at, :datetime
  end
end
