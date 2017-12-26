class AddDeletedAtToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :deleted_at, :datetime
    add_index :languages, :deleted_at
  end
end
