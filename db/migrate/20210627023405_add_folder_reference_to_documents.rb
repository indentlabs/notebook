class AddFolderReferenceToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :folder, null: true, foreign_key: true
  end
end
