class AddPrivacyToLanguages < ActiveRecord::Migration
  def change
    add_column :languages, :privacy, :string
  end
end
