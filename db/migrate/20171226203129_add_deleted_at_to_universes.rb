class AddDeletedAtToUniverses < ActiveRecord::Migration
  def change
    add_column :universes, :deleted_at, :datetime
    add_index :universes, :deleted_at
  end
end
