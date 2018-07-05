class AddPrivacyToScenes < ActiveRecord::Migration[4.2]
  def change
    add_column :scenes, :privacy, :string
  end
end
