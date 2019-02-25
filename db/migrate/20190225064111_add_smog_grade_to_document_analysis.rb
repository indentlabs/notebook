class AddSmogGradeToDocumentAnalysis < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :smog_grade, :float
  end
end
