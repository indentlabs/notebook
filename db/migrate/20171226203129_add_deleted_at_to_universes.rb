class AddDeletedAtToUniverses < ActiveRecord::Migration[4.2]
  def change
    add_column :universes, :deleted_at, :datetime
    add_index :universes, :deleted_at
  end
end
