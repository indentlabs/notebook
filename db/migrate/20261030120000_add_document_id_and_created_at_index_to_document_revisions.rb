class AddDocumentIdAndCreatedAtIndexToDocumentRevisions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  # SaveDocumentRevisionJob looks up a document's latest revision after every autosave. With only an
  # index on document_id, Postgres has to read and sort every revision of the document to find it.
  def up
    if connection.adapter_name == 'PostgreSQL'
      add_index :document_revisions,
                [:document_id, :created_at],
                name: 'index_document_revisions_on_document_id_and_created_at',
                algorithm: :concurrently,
                if_not_exists: true
    else
      add_index :document_revisions,
                [:document_id, :created_at],
                name: 'index_document_revisions_on_document_id_and_created_at',
                if_not_exists: true
    end
  end

  def down
    if connection.adapter_name == 'PostgreSQL'
      remove_index :document_revisions,
                   name: 'index_document_revisions_on_document_id_and_created_at',
                   algorithm: :concurrently,
                   if_exists: true
    else
      remove_index :document_revisions,
                   name: 'index_document_revisions_on_document_id_and_created_at',
                   if_exists: true
    end
  end
end
