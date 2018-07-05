class AddDeletedAtToMagics < ActiveRecord::Migration[4.2]
  def change
    add_column :magics, :deleted_at, :datetime
    add_index :magics, :deleted_at
  end
end
