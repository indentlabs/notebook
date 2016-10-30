class AddPrivacyToRaces < ActiveRecord::Migration
  def change
    add_column :races, :privacy, :string
  end
end
