class AddDeletedAtToReligions < ActiveRecord::Migration
  def change
    add_column :religions, :deleted_at, :datetime
    add_index :religions, :deleted_at
  end
end
