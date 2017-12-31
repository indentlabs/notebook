class AddDeletedAtToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :deleted_at, :datetime
  end
end
