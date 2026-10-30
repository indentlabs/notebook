class CreateBookDocuments < ActiveRecord::Migration[6.1]
  def change
    create_table :book_documents do |t|
      t.references :book, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end

    add_index :book_documents, [:book_id, :position]
    add_index :book_documents, [:document_id, :book_id], unique: true
  end
end
