class AddPrivacyToScenes < ActiveRecord::Migration
  def change
    add_column :scenes, :privacy, :string
  end
end
