class AddPrivacyToCreatures < ActiveRecord::Migration
  def change
    add_column :creatures, :privacy, :string
  end
end
