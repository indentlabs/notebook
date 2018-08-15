class AddPrivacyToRaces < ActiveRecord::Migration[4.2]
  def change
    add_column :races, :privacy, :string
  end
end
