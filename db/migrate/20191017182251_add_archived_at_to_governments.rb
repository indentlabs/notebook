class AddArchivedAtToGovernments < ActiveRecord::Migration[5.2]
  def change
    add_column :governments, :archived_at, :datetime
  end
end
