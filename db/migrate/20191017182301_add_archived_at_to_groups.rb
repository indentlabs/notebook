class AddArchivedAtToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :archived_at, :datetime
  end
end
