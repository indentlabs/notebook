class AddMoreFieldsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :progress, :int
    add_column :document_analyses, :interrogative_count, :int
  end
end
