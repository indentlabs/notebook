class AddArchivedAtToConditions < ActiveRecord::Migration[5.2]
  def change
    add_column :conditions, :archived_at, :datetime
  end
end
