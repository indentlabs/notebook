class AddArchivedAtToUniverses < ActiveRecord::Migration[5.2]
  def change
    add_column :universes, :archived_at, :datetime
  end
end
