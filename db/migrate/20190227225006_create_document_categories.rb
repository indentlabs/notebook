class CreateDocumentCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :document_categories do |t|
      t.references :document_analysis, foreign_key: true
      t.string :label
      t.float :score

      t.timestamps
    end
  end
end
