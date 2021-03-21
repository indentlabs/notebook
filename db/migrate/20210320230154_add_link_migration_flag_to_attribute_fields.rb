class AddLinkMigrationFlagToAttributeFields < ActiveRecord::Migration[6.0]
  def change
    add_column :attribute_fields, :migrated_from_legacy, :boolean
    change_column :attribute_fields, :migrated_from_legacy, :type, default: false
  end
end
