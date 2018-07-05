class AddPrivacyToMagics < ActiveRecord::Migration[4.2]
  def change
    add_column :magics, :privacy, :string
  end
end
