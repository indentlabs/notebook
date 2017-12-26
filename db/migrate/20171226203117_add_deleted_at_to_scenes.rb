class AddDeletedAtToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :deleted_at, :datetime
    add_index :scenes, :deleted_at
  end
end
