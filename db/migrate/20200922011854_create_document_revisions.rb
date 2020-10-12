class CreateDocumentRevisions < ActiveRecord::Migration[6.0]
  def change
    create_table :document_revisions do |t|
      t.references :document, null: false, foreign_key: true
      t.string :title
      t.string :body
      t.string :synopsis
      t.integer :universe_id
      t.string :notes_text
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
