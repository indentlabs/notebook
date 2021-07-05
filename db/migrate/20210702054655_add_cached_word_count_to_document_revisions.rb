class AddCachedWordCountToDocumentRevisions < ActiveRecord::Migration[6.0]
  def change
    add_column :document_revisions, :cached_word_count, :integer
  end
end
