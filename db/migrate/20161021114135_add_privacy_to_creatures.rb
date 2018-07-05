class AddPrivacyToCreatures < ActiveRecord::Migration[4.2]
  def change
    add_column :creatures, :privacy, :string
  end
end
