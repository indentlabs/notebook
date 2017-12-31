class AddPrivacyToTowns < ActiveRecord::Migration
  def change
    add_column :towns, :privacy, :string
  end
end
