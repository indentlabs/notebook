class AddPrivacyToCharacters < ActiveRecord::Migration[4.2]
  def change
    add_column :characters, :privacy, :string
  end
end
