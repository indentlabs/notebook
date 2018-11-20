class AddPrivacyColumnsToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :privacy, :string, default: 'private'
    add_column :documents, :synopsis, :text
  end
end
