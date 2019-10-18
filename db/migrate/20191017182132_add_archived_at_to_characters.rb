class AddArchivedAtToCharacters < ActiveRecord::Migration[5.2]
  def change
    add_column :characters, :archived_at, :datetime
  end
end
