class AddPrivacyToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :privacy, :string
  end
end
