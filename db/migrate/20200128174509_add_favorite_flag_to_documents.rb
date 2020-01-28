class AddFavoriteFlagToDocuments < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :favorite, :boolean
  end
end
