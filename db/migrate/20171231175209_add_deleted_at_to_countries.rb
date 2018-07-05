class AddDeletedAtToCountries < ActiveRecord::Migration[4.2]
  def change
    add_column :countries, :deleted_at, :datetime
  end
end
