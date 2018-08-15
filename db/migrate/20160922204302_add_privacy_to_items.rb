class AddPrivacyToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :privacy, :string, default: 'private', null: false
  end
end
