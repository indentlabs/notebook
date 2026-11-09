# SaveDocumentRevisionJob keeps the newest revision up to date while a stretch of writing goes on.
# closed_at marks a revision it must never change again: one it has moved on from, a backup made by
# a restore, or anything else that should stay exactly as it was saved. Existing rows keep NULL;
# the job only ever updates a revision that is also less than five minutes old.
class AddClosedAtToDocumentRevisions < ActiveRecord::Migration[6.1]
  # Adding a nullable column rewrites nothing, but it does need a brief exclusive lock on a table that
  # autosave writes to. If a long query or backup is holding the table, everything else would queue
  # behind this migration while it waits, so give up quickly instead and let the deploy be retried.
  def up
    set_lock_timeout
    add_column :document_revisions, :closed_at, :datetime
  end

  def down
    set_lock_timeout
    remove_column :document_revisions, :closed_at
  end

  private

  def set_lock_timeout
    execute "SET LOCAL lock_timeout = '5s'" if connection.adapter_name == 'PostgreSQL'
  end
end
