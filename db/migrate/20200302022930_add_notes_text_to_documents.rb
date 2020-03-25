class AddNotesTextToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :notes_text, :text
  end
end
