class AddArchivedAtToTechnologies < ActiveRecord::Migration[5.2]
  def change
    add_column :technologies, :archived_at, :datetime
  end
end
