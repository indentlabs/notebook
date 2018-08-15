class AddPrivacyToLocations < ActiveRecord::Migration[4.2]
  def change
    add_column :locations, :privacy, :string, default: 'private', null: false
  end
end
