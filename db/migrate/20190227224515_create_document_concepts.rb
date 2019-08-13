class CreateDocumentConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :document_concepts do |t|
      t.references :document_analysis, foreign_key: true
      t.string :text
      t.float :relevance
      t.string :reference_link

      t.timestamps
    end
  end
end
