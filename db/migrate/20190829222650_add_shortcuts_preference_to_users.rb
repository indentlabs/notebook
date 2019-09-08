class AddShortcutsPreferenceToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :keyboard_shortcuts_preference, :boolean
  end
end
