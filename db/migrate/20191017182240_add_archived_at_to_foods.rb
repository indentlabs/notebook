class AddArchivedAtToFoods < ActiveRecord::Migration[5.2]
  def change
    add_column :foods, :archived_at, :datetime
  end
end
