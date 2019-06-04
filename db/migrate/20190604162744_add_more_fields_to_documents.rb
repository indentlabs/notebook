class AddMoreFieldsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :progress, :int
  end
end
