class CreateDocumentNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :document_notes do |t|
      t.references :document, null: false, foreign_key: true
      t.string :title
      t.string :notes

      t.timestamps
    end
  end
end
