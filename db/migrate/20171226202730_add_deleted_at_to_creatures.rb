class AddDeletedAtToCreatures < ActiveRecord::Migration
  def change
    add_column :creatures, :deleted_at, :datetime
    add_index :creatures, :deleted_at
  end
end
