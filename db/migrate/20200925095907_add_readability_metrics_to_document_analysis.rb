class AddReadabilityMetricsToDocumentAnalysis < ActiveRecord::Migration[6.0]
  def change
    add_column :document_analyses, :linsear_write_grade, :float
    add_column :document_analyses, :dale_chall_grade, :float

    add_column :document_analyses, :unique_complex_words_count, :integer
    add_column :document_analyses, :unique_simple_words_count, :integer
  end
end
