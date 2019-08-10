class AddProperNounCountToDocumentAnalyses < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :proper_noun_count, :integer
  end
end
