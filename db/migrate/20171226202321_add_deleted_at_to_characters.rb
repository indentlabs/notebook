class AddDeletedAtToCharacters < ActiveRecord::Migration[4.2]
  def change
    add_column :characters, :deleted_at, :datetime
    add_index :characters, :deleted_at
  end
end
