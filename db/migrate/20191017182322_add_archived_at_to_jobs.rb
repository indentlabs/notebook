class AddArchivedAtToJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :jobs, :archived_at, :datetime
  end
end
