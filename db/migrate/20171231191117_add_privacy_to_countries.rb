class AddPrivacyToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :privacy, :string
  end
end
