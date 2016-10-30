class AddPrivacyToMagics < ActiveRecord::Migration
  def change
    add_column :magics, :privacy, :string
  end
end
