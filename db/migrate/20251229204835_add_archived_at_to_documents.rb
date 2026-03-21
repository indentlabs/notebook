class AddArchivedAtToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :archived_at, :datetime, default: nil
    add_index :documents, :archived_at
  end
end
