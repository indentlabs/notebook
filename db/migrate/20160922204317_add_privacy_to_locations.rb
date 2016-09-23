class AddPrivacyToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :privacy, :string, default: 'private', null: false
  end
end
