class AddArchivedAtToPlanets < ActiveRecord::Migration[5.2]
  def change
    add_column :planets, :archived_at, :datetime
  end
end
