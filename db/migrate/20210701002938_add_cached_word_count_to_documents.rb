class AddCachedWordCountToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :cached_word_count, :integer
  end
end
