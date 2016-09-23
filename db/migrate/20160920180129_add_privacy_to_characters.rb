class AddPrivacyToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :privacy, :string
  end
end
