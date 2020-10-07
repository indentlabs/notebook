class AddMostUsedWordsToDocumentAnalysis < ActiveRecord::Migration[6.0]
  def change
    add_column :document_analyses, :most_used_words, :json
    add_column :document_analyses, :most_used_adjectives, :json
    add_column :document_analyses, :most_used_nouns, :json
    add_column :document_analyses, :most_used_verbs, :json
    add_column :document_analyses, :most_used_adverbs, :json
  end
end
