class AddDocumentPasswordDigestToDocuments < ActiveRecord::Migration[6.1]
  # Adding a nullable column rewrites nothing, but it does need a brief exclusive lock on a table that
  # every autosave writes to. If a long query or backup is holding the table, everything else would queue
  # behind this migration while it waits, so give up quickly instead and let the deploy be retried.
  def up
    set_lock_timeout
    add_column :documents, :document_password_digest, :string
  end

  def down
    set_lock_timeout
    remove_column :documents, :document_password_digest
  end

  private

  def set_lock_timeout
    execute "SET LOCAL lock_timeout = '5s'" if connection.adapter_name == 'PostgreSQL'
  end
end
