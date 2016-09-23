class AddPrivacyToItems < ActiveRecord::Migration
  def change
    add_column :items, :privacy, :string, default: 'private', null: false
  end
end
