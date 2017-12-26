class AddDeletedAtToRaces < ActiveRecord::Migration
  def change
    add_column :races, :deleted_at, :datetime
    add_index :races, :deleted_at
  end
end
