class AddQueuedAtToDocumentAnalysis < ActiveRecord::Migration[5.2]
  def change
    add_column :document_analyses, :queued_at, :datetime
  end
end
