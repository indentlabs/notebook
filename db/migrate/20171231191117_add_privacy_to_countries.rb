class AddPrivacyToCountries < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :privacy, :string
  end
end
