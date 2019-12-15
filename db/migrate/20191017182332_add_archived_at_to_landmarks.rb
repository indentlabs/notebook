class AddArchivedAtToLandmarks < ActiveRecord::Migration[5.2]
  def change
    add_column :landmarks, :archived_at, :datetime
  end
end
