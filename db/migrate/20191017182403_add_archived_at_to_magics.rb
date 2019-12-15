class AddArchivedAtToMagics < ActiveRecord::Migration[5.2]
  def change
    add_column :magics, :archived_at, :datetime
  end
end
