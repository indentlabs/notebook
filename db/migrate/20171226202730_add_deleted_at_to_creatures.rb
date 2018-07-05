class AddDeletedAtToCreatures < ActiveRecord::Migration[4.2]
  def change
    add_column :creatures, :deleted_at, :datetime
    add_index :creatures, :deleted_at
  end
end
