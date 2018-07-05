class AddDeletedAtToFloras < ActiveRecord::Migration[4.2]
  def change
    add_column :floras, :deleted_at, :datetime
    add_index :floras, :deleted_at
  end
end
