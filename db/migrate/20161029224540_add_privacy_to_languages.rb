class AddPrivacyToLanguages < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :privacy, :string
  end
end
