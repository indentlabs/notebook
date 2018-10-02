class AddTitleToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :title, :string
  end
end
