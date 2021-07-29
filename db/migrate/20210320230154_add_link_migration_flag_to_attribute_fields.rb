class AddLinkMigrationFlagToAttributeFields < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_column :attribute_fields, :migrated_from_legacy, :boolean, default: nil, null: true
    change_column :attribute_fields, :migrated_from_legacy, :boolean, default: false
  end
end
