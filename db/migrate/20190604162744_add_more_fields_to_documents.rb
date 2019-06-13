class AddMoreFieldsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :progress, :int, default: 0
    add_column :document_analyses, :interrogative_count, :int
  end
end
