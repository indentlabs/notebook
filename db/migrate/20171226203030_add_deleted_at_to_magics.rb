class AddDeletedAtToMagics < ActiveRecord::Migration
  def change
    add_column :magics, :deleted_at, :datetime
    add_index :magics, :deleted_at
  end
end
