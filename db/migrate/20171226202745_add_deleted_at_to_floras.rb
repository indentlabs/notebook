class AddDeletedAtToFloras < ActiveRecord::Migration
  def change
    add_column :floras, :deleted_at, :datetime
    add_index :floras, :deleted_at
  end
end
