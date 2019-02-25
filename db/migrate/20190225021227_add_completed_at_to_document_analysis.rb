class AddCompletedAtToDocumentAnalysis < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :completed_at, :datetime
  end
end
