class AddArchivedAtToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :archived_at, :datetime
  end
end
