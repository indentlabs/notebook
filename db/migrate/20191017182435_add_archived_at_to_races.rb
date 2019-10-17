class AddArchivedAtToRaces < ActiveRecord::Migration[5.2]
  def change
    add_column :races, :archived_at, :datetime
  end
end
