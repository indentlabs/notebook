class AddStatusToDocuments < ActiveRecord::Migration[6.1]
  def change
    add_column :documents, :status, :integer, default: 0
    add_index :documents, :status
  end
end
