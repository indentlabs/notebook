class AddDeletedAtToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :deleted_at, :datetime
  end
end
