class AddUniverseToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :universe, foreign_key: true
  end
end
