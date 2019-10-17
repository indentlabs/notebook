class AddArchivedAtToCountries < ActiveRecord::Migration[5.2]
  def change
    add_column :countries, :archived_at, :datetime
  end
end
