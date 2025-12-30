class AddCompositeIndexForDocumentArchiveQueries < ActiveRecord::Migration[6.1]
  def change
    add_index :documents, [:user_id, :archived_at, :deleted_at],
              name: 'index_documents_on_user_archived_deleted'
  end
end
