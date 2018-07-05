class AddDeletedAtToScenes < ActiveRecord::Migration[4.2]
  def change
    add_column :scenes, :deleted_at, :datetime
    add_index :scenes, :deleted_at
  end
end
