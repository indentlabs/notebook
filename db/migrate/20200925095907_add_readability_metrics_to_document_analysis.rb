class AddReadabilityMetricsToDocumentAnalysis < ActiveRecord::Migration[6.0]
  def change
    add_column :document_analyses, :linsear_write_grade, :float
    add_column :document_analyses, :dale_chall_grade, :float
  end
end
