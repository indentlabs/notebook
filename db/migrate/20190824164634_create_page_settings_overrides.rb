class CreatePageSettingsOverrides < ActiveRecord::Migration[5.2]
  def change
    create_table :page_settings_overrides do |t|
      t.string :page_type
      t.string :name_override
      t.string :icon_override
      t.string :hex_color_override
      t.references :user

      t.timestamps
    end
  end
end
