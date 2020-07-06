class AddDarkModeEnabledFlagToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :dark_mode_enabled, :boolean
  end
end
