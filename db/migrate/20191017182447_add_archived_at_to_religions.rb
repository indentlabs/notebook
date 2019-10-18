class AddArchivedAtToReligions < ActiveRecord::Migration[5.2]
  def change
    add_column :religions, :archived_at, :datetime
  end
end
