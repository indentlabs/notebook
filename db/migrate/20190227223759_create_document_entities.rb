class CreateDocumentEntities < ActiveRecord::Migration[5.2]
  def change
    create_table :document_entities do |t|
      t.references :entity, polymorphic: true
      t.string :text
      t.float :relevance
      t.references :document_analysis, foreign_key: true
      t.string :sentiment_label
      t.float :sentiment_score
      t.float :sadness_score
      t.float :joy_score
      t.float :fear_score
      t.float :disgust_score
      t.float :anger_score

      t.timestamps
    end
  end
end
