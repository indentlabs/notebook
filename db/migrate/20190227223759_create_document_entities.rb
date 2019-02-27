class CreateDocumentEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :document_entities do |t|
      t.references :entity, polymorphic: true
      t.string :text
      t.float :relevance
      t.references :document_analysis, foreign_key: true

      t.timestamps
    end
  end
end
