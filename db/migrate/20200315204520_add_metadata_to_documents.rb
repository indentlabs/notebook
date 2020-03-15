class AddMetadataToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :format, :string
    add_column :documents, :word_count, :integer
    add_column :documents, :status, :string
  end
end
