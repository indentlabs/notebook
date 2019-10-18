class AddArchivedAtToSports < ActiveRecord::Migration[5.2]
  def change
    add_column :sports, :archived_at, :datetime
  end
end
