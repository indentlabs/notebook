class AddArchivedAtToContinents < ActiveRecord::Migration[6.0]
  def change
    add_column :continents, :archived_at, :datetime
  end
end
