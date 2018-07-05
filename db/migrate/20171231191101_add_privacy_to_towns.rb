class AddPrivacyToTowns < ActiveRecord::Migration[4.2]
  def change
    add_column :towns, :privacy, :string
  end
end
